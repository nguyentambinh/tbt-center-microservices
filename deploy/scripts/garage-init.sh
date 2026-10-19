#!/bin/bash
# Khởi tạo Garage của một khu vực: gán dung lượng cho nút, nhập khóa truy cập, tạo bucket tbt-cv.
# Chạy lại nhiều lần không sao. Cách dùng: bash deploy/scripts/garage-init.sh vn
set -euo pipefail
REGION=${1:?Cách dùng: garage-init.sh <vn|de|us|br|za|au>}
DIR=$(cd "$(dirname "$0")/.." && pwd)
set -a; . "$DIR/secrets/garage.env"; set +a
export MSYS_NO_PATHCONV=1
G="docker exec -e RUST_LOG=warn tbt-$REGION-garage-1 /garage"

node=$($G status 2>/dev/null | awk '/NO ROLE ASSIGNED|garage/ && $1 ~ /^[0-9a-f]+$/ {print $1; exit}')
if $G layout show 2>/dev/null | grep -q "No nodes currently have a role"; then
  $G layout assign -z "$REGION" -c 2G "$node" >/dev/null
  $G layout apply --version 1 >/dev/null
  echo "Đã gán layout cho nút $node"
fi
$G key info cv-service >/dev/null 2>&1 || $G key import --yes -n cv-service "$S3_ACCESS_KEY_ID" "$S3_SECRET_ACCESS_KEY" >/dev/null
$G bucket info tbt-cv >/dev/null 2>&1 || $G bucket create tbt-cv >/dev/null
$G bucket allow --read --write tbt-cv --key cv-service >/dev/null
echo "Garage $REGION sẵn sàng: bucket tbt-cv, khóa cv-service."
