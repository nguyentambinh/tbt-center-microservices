#!/bin/bash
# Chạy một khu vực trên Kubernetes (k3s trong Docker, dựng bằng k3d).
# Cụm dùng lại volume dữ liệu của bản Docker Compose cùng khu vực, nên hai bản không được chạy cùng lúc.
# Cách dùng: bash deploy/k8s/cluster.sh <khu vực> <up|apply|images|start|stop|status|down>
#   up      tạo cụm (nếu chưa có), nạp image, áp manifest
#   apply   áp lại manifest sau khi sửa YAML hoặc khóa
#   images  nạp lại image tbt/* sau khi build, rồi khởi động lại các Deployment
#   start   bật lại cụm đã dừng; stop: dừng cụm, giữ nguyên dữ liệu
#   down    xóa cụm (dữ liệu Postgres, Garage vẫn còn trong volume Docker)
set -euo pipefail

REGION=${1:?Cách dùng: cluster.sh <khu vực> <up|apply|images|start|stop|status|down>}
ACTION=${2:-status}
DIR=$(cd "$(dirname "$0")/.." && (pwd -W 2>/dev/null || pwd))
CLUSTER=tbt-$REGION
NS=tbt-$REGION
export MSYS_NO_PATHCONV=1
set -a; . "$DIR/regions/$REGION.env"; set +a

APP_IMAGES="hr attendance payroll finance project_contract currency notification integration recruitment bank_mock sync_worker admin"
BASE_IMAGES="postgres:17 redis:7.4-alpine kong:3.9 owasp/modsecurity-crs:nginx-alpine dxflrs/garage:v2.3.0 prom/prometheus:v3.15.0"

compose_running() {
  docker ps --format '{{.Names}}' | grep -q "^tbt-$REGION-postgres-primary-1$"
}

create() {
  k3d cluster list "$CLUSTER" >/dev/null 2>&1 && return
  if compose_running; then
    echo "Khu vực $REGION đang chạy bằng Docker Compose. Dừng trước: docker compose -p tbt-$REGION stop" >&2
    exit 1
  fi
  # Cổng của máy giữ như bản Compose để app, Grafana ở Hub không phải đổi
  k3d cluster create "$CLUSTER" --servers 1 --agents 1 \
    --k3s-arg "--disable=traefik@server:0" \
    -p "$KONG_PORT:30800@server:0" -p "$PG_PORT:30543@server:0" -p "$S3_PORT:30900@server:0" \
    -p "$BANK_PORT:30890@server:0" -p "$PROM_PORT:30909@server:0" \
    -v "tbt-${REGION}_pg-primary:/var/lib/tbt/pg-primary@server:0" \
    -v "tbt-${REGION}_pg-replica:/var/lib/tbt/pg-replica@server:0" \
    -v "tbt-${REGION}_garage-meta:/var/lib/tbt/garage-meta@server:0" \
    -v "tbt-${REGION}_garage-data:/var/lib/tbt/garage-data@server:0" \
    --wait
}

import_images() {
  local list=$BASE_IMAGES tar="$DIR/backups/k3d-images-$REGION.tar"
  for s in $APP_IMAGES; do list="$list tbt/$s:latest"; done
  # Image tải về có nhiều nền tảng; chỉ lưu bản linux/amd64 để containerd của node nạp đủ lớp
  # shellcheck disable=SC2086
  docker save --platform linux/amd64 -o "$tar" $list
  k3d image import -c "$CLUSTER" "$tar"
  rm -f "$tar"
}

apply() {
  kubectl config use-context "k3d-$CLUSTER" >/dev/null
  kubectl kustomize --load-restrictor LoadRestrictionsNone "$DIR/k8s/$REGION" | kubectl apply -f -
}

case $ACTION in
  up) create; import_images; apply; kubectl -n "$NS" rollout status deploy --timeout=300s ;;
  apply) apply ;;
  images) import_images; kubectl --context "k3d-$CLUSTER" -n "$NS" rollout restart deploy ;;
  start)
    if compose_running; then echo "Dừng bản Docker Compose của $REGION trước" >&2; exit 1; fi
    k3d cluster start "$CLUSTER" ;;
  stop) k3d cluster stop "$CLUSTER" ;;
  status) kubectl --context "k3d-$CLUSTER" -n "$NS" get pods,svc,hpa -o wide ;;
  down) k3d cluster delete "$CLUSTER" ;;
  *) echo "Không có lệnh $ACTION" >&2; exit 1 ;;
esac
