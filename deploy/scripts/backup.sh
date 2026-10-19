#!/bin/bash
# Sao lưu mọi database của một khu vực (hoặc Hub) từ Postgres primary (R44).
# Mỗi database một tệp pg_dump dạng custom (-Fc, đã nén), kèm SHA256SUMS để
# kiểm tệp không bị hỏng hay bị sửa trước khi khôi phục.
# Cách dùng: bash deploy/scripts/backup.sh vn      (hoặc de, us, br, za, au, hub)
# Tệp nằm ở deploy/backups/<khu vực>/<thời điểm>/, không đưa lên git.
set -euo pipefail

TARGET=${1:?Cách dùng: backup.sh <vn|de|us|br|za|au|hub>}
DIR=$(cd "$(dirname "$0")/../.." && (pwd -W 2>/dev/null || pwd))
export MSYS_NO_PATHCONV=1

if [ "$TARGET" = hub ]; then
  CONTAINER=tbt-hub-hub-postgres-1
  DATABASES="keycloak_db audit_db"
else
  CONTAINER=tbt-$TARGET-postgres-primary-1
  DATABASES="hr_db attendance_db payroll_db finance_db project_contract_db recruitment_db currency_db notification_db"
fi

STAMP=$(date +%Y%m%d-%H%M%S)
OUT="$DIR/deploy/backups/$TARGET/$STAMP"
mkdir -p "$OUT"

for db in $DATABASES; do
  # Database chưa có (ví dụ khu vực cũ chưa tạo notification_db) thì bỏ qua.
  exists=$(docker exec "$CONTAINER" sh -c "psql -tA -U \"\$POSTGRES_USER\" -d postgres -c \"select 1 from pg_database where datname = '$db'\"")
  if [ "$exists" != 1 ]; then
    echo "  $db: không có, bỏ qua"
    continue
  fi
  docker exec "$CONTAINER" sh -c "pg_dump -Fc -U \"\$POSTGRES_USER\" -d $db" > "$OUT/$db.dump"
  echo "  $db: $(du -h "$OUT/$db.dump" | cut -f1)"
done

(cd "$OUT" && sha256sum ./*.dump > SHA256SUMS)
echo "Đã sao lưu $TARGET vào deploy/backups/$TARGET/$STAMP"
