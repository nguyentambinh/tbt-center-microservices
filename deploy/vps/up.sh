#!/bin/bash
# Bật hệ thống trên máy chủ thật: Hub và các khu vực bằng Docker Compose, DE trên k3s, Caddy làm cổng HTTPS.
# Chạy trên máy chủ, trong /opt/tbt: bash deploy/vps/up.sh <hub|edge|region <kv>|regions|de|all|status>
set -euo pipefail
cd "$(dirname "$0")/../.."
set -a; . deploy/vps/vps.env; set +a
WHAT=${1:-status}
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

DE_IMAGES="tbt/hr tbt/attendance tbt/payroll tbt/finance tbt/project_contract tbt/currency tbt/notification tbt/integration tbt/recruitment tbt/bank_mock tbt/sync_worker tbt/admin"
BASE_IMAGES="postgres:17 redis:7.4-alpine kong:3.9 owasp/modsecurity-crs:nginx-alpine dxflrs/garage:v2.3.0 prom/prometheus:v3.15.0"

hub() {
  docker compose -p tbt-hub --env-file deploy/vps/vps.env -f deploy/compose.hub.yml up -d --no-build
}

edge() {
  docker compose -p tbt-edge --env-file deploy/vps/vps.env -f deploy/vps/compose.edge.yml up -d
  # Caddyfile gắn từng file: chép bản mới thì container vẫn giữ inode cũ, phải restart
  docker compose -p tbt-edge --env-file deploy/vps/vps.env -f deploy/vps/compose.edge.yml restart caddy
}

# Khu vực chạy Docker Compose (DE chạy k3s)
COMPOSE_REGIONS="vn us br za au"

region() {
  local r=${1:?Thiếu khu vực: vn, us, br, za, au}
  S3_PUBLIC_ENDPOINT=https://s3-$r.$DOMAIN docker compose -p "tbt-$r" --env-file "deploy/regions/$r.env" --env-file deploy/vps/vps.env \
    -f deploy/compose.region.yml up -d --no-build
}

de() {
  if ! command -v k3s >/dev/null; then
    # traefik, servicelb không cần: Caddy là cổng vào, Service dùng NodePort
    curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable=traefik --disable=servicelb --write-kubeconfig-mode 600" sh -
    systemctl restart tbt-docker-user.service
  fi
  for i in $DE_IMAGES; do list="${list:-} $i:latest"; done
  # shellcheck disable=SC2086
  docker save --platform linux/amd64 $list $BASE_IMAGES | k3s ctr images import - >/dev/null
  # Pod gọi Hub (chạy Docker trên cùng máy) qua host.docker.internal = địa chỉ docker0
  kubectl apply -f - <<'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns-custom
  namespace: kube-system
data:
  docker.server: |
    host.docker.internal:53 {
      hosts {
        172.17.0.1 host.docker.internal
      }
    }
EOF
  kubectl -n kube-system rollout restart deploy/coredns >/dev/null
  # Overlay riêng máy chủ: issuer công khai, địa chỉ S3 công khai của DE
  mkdir -p deploy/k8s/de-vps
  cat > deploy/k8s/de-vps/kustomization.yaml <<EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources: [../de]
configMapGenerator:
  - name: service-env
    behavior: merge
    literals: [JWT_ISSUER=$JWT_ISSUER]
  - name: region
    behavior: merge
    literals: [S3_PUBLIC_ENDPOINT=https://s3-de.$DOMAIN]
EOF
  kubectl kustomize --load-restrictor LoadRestrictionsNone deploy/k8s/de-vps | kubectl apply -f - >/dev/null
  # Tag latest không đổi nên apply không thay pod: restart để nhận image vừa nạp
  kubectl -n tbt-de get deploy -o jsonpath='{range .items[*]}{.metadata.name} {.spec.template.spec.containers[0].image}{"\n"}{end}' \
    | awk '$2 ~ /^tbt\// {print "deploy/" $1}' | xargs -r kubectl -n tbt-de rollout restart >/dev/null
  kubectl -n tbt-de rollout status deploy --timeout=300s
}

status() {
  docker ps --format '{{.Names}}\t{{.Status}}' | sort
  command -v k3s >/dev/null && kubectl -n tbt-de get pods,hpa
  free -h | sed -n 2p
}

case $WHAT in
  hub) hub ;; edge) edge ;; de) de ;; status) status ;;
  region) region "${2:-}" ;;
  regions) for r in $COMPOSE_REGIONS; do region "$r"; done ;;
  all) hub; for r in $COMPOSE_REGIONS; do region "$r"; done; de; edge ;;
  *) echo "Không có lệnh $WHAT" >&2; exit 1 ;;
esac
