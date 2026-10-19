#!/bin/bash
# Nạp schema (services/*/migrations) và dữ liệu mẫu (deploy/seed/<khu vực>) vào Postgres primary của một khu vực.
# Chạy lại được: file seed tự xóa dữ liệu cũ trong các bảng trước khi nạp.
# Cách dùng: bash deploy/scripts/db-init.sh vn
set -euo pipefail

REGION=${1:?Cách dùng: db-init.sh <vn|de|us|br|za|au>}
# Trên Git Bash dùng đường dẫn kiểu D:/... để docker hiểu được khi tắt chuyển đổi đường dẫn.
DIR=$(cd "$(dirname "$0")/../.." && (pwd -W 2>/dev/null || pwd))
export MSYS_NO_PATHCONV=1
COMPOSE=(docker compose -p "tbt-$REGION" --env-file "$DIR/deploy/regions/$REGION.env" -f "$DIR/deploy/compose.region.yml")

psql_db() {
  "${COMPOSE[@]}" exec -T -e PGOPTIONS='-c client_min_messages=warning' postgres-primary \
    sh -c "psql -v ON_ERROR_STOP=1 -q -U \"\$POSTGRES_USER\" -d $1"
}

for svc in hr attendance payroll project_contract finance recruitment currency; do
  for f in "$DIR"/services/$svc/migrations/*.sql; do
    psql_db "${svc}_db" < "$f"
  done
  psql_db "${svc}_db" < "$DIR/deploy/seed/$REGION/$svc.sql" > /dev/null
  echo "  $svc: xong"
done
# notification không có dữ liệu mẫu: chỉ tạo bảng, thông báo tự sinh từ sổ sự kiện ở Hub.
for f in "$DIR"/services/notification/migrations/*.sql; do
  psql_db notification_db < "$f"
done
echo "  notification: xong"
echo "Đã nạp dữ liệu khu vực $REGION."
