#!/bin/bash
# Đưa cấu hình, image tbt/* và khóa cần thiết từ máy dev lên máy chủ thật.
# Cách dùng: bash deploy/vps/push.sh root@<máy chủ> [config|images|secrets|all]
# Chỉ đẩy vài image: IMAGES="hr payroll" bash deploy/vps/push.sh root@<máy chủ> images
# Khóa Anthropic, mật khẩu Gmail, payOS không tự chép: trên máy chủ chỉ tạo file trống (AI dùng Gemini, chi lương qua bank_mock).
set -euo pipefail

HOST=${1:?Cách dùng: push.sh root@<máy chủ> [config|images|secrets|all]}
WHAT=${2:-all}
DIR=$(cd "$(dirname "$0")/../.." && pwd)
REMOTE=/opt/tbt
SSH="ssh -o BatchMode=yes $HOST"

IMAGES=${IMAGES:-"hr attendance payroll finance project_contract currency notification integration recruitment bank_mock sync_worker audit report datastore knowledge geo eureka"}
SECRETS="postgres.env internal.env sync.env rabbitmq.env gemini.env garage.env identity.env keycloak.env grafana.env datastore-hub.env datakey-vn.env datakey-de.env datakey-us.env datakey-br.env datakey-za.env datakey-au.env firebase-sa.json firestore-hub-writer.json firestore-region-reader.json"
PLACEHOLDERS="anthropic.env payos-vn.env payos-de.env payos-us.env payos-br.env payos-za.env payos-au.env gmail-app-password.txt"

push_config() {
  $SSH "mkdir -p $REMOTE"
  # kong.yml trên máy chủ sinh riêng (issuer công khai), ảnh đã ở Garage: không chép đè
  tar -C "$DIR" --exclude='deploy/backups' --exclude='deploy/secrets' --exclude='deploy/vps/vps.env' \
    --exclude='deploy/kong/kong.yml' --exclude='deploy/media' --exclude='deploy/k8s/de-vps' -czf - deploy | $SSH "tar -C $REMOTE -xzf -"
  echo "Đã chép deploy/ lên $HOST:$REMOTE"
}

push_images() {
  local list=""
  for s in $IMAGES; do list="$list tbt/$s:latest"; done
  # shellcheck disable=SC2086
  docker save --platform linux/amd64 $list | gzip -1 | $SSH "gunzip | docker load" | tail -3
}

push_secrets() {
  $SSH "mkdir -p $REMOTE/deploy/secrets && chmod 700 $REMOTE/deploy/secrets"
  # shellcheck disable=SC2086
  (cd "$DIR/deploy/secrets" && tar -czf - $SECRETS) | $SSH "tar -C $REMOTE/deploy/secrets -xzf - && chmod 600 $REMOTE/deploy/secrets/*"
  for f in $PLACEHOLDERS; do $SSH "test -e $REMOTE/deploy/secrets/$f || install -m 600 /dev/null $REMOTE/deploy/secrets/$f"; done
  echo "Đã chép khóa; file trống: $PLACEHOLDERS"
}

case $WHAT in
  config) push_config ;;
  images) push_images ;;
  secrets) push_secrets ;;
  all) push_config; push_secrets; push_images ;;
  *) echo "Không có lệnh $WHAT" >&2; exit 1 ;;
esac
