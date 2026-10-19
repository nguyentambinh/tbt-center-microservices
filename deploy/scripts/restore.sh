#!/bin/bash
# Khôi phục một database từ bản sao lưu của backup.sh (R44).
# Mặc định khôi phục vào database thử <db>_restore_check để kiểm tra bản sao lưu
# dùng được, KHÔNG đụng tới database thật. Thêm --replace để ghi đè database
# thật (xóa và tạo lại); service dùng database đó nên dừng trước.
#
# Cách dùng:
#   bash deploy/scripts/restore.sh vn 20261015-140500 hr_db            # thử
#   bash deploy/scripts/restore.sh vn 20261015-140500 hr_db --replace  # thật
set -euo pipefail

TARGET=${1:?Cách dùng: restore.sh <khu vực|hub> <thời điểm> <database> [--replace]}
STAMP=${2:?Thiếu thời điểm sao lưu (tên thư mục trong deploy/backups/<khu vực>)}
DB=${3:?Thiếu tên database, ví dụ hr_db}
MODE=${4:-check}
DIR=$(cd "$(dirname "$0")/../.." && (pwd -W 2>/dev/null || pwd))
export MSYS_NO_PATHCONV=1

if [ "$TARGET" = hub ]; then CONTAINER=tbt-hub-hub-postgres-1; else CONTAINER=tbt-$TARGET-postgres-primary-1; fi
SRC="$DIR/deploy/backups/$TARGET/$STAMP"
[ -f "$SRC/$DB.dump" ] || { echo "Không có $SRC/$DB.dump"; exit 1; }

echo "Kiểm mã SHA-256 của bản sao lưu..."
# Git Bash ghi dấu * (chế độ nhị phân) trước tên tệp, Linux ghi dấu cách.
(cd "$SRC" && grep -E "[ *]\./$DB\.dump\$" SHA256SUMS | sha256sum -c -)

psql_admin() { docker exec "$CONTAINER" sh -c "psql -v ON_ERROR_STOP=1 -q -U \"\$POSTGRES_USER\" -d postgres -c \"$1\""; }

if [ "$MODE" = --drop-check ]; then
  psql_admin "drop database if exists ${DB}_restore_check with (force)"
  echo "Đã xóa database thử ${DB}_restore_check."
  exit 0
fi

if [ "$MODE" = --replace ]; then
  NAME=$DB
  echo "Ghi đè database thật $DB trên $CONTAINER"
else
  NAME=${DB}_restore_check
fi

psql_admin "drop database if exists $NAME with (force)"
psql_admin "create database $NAME"
docker exec -i "$CONTAINER" sh -c "pg_restore --no-owner -U \"\$POSTGRES_USER\" -d $NAME" < "$SRC/$DB.dump"

# Số dòng thật từng bảng (đếm count(*), không dựa vào thống kê).
COUNT_SQL="select table_name || '=' || (xpath('/row/c/text()', query_to_xml(format('select count(*) as c from %I', table_name), false, true, '')))[1]::text from information_schema.tables where table_schema = 'public' and table_type = 'BASE TABLE' order by 1"
counts() { docker exec "$CONTAINER" sh -c "psql -tA -U \"\$POSTGRES_USER\" -d $1 -c \"$COUNT_SQL\""; }

echo "Bảng: bản khôi phục | đang chạy"
paste -d'|' <(counts "$NAME") <(counts "$DB")
echo "Đã khôi phục vào $NAME."
if [ "$MODE" != --replace ]; then
  echo "Kiểm xong thì xóa database thử: bash deploy/scripts/restore.sh $TARGET $STAMP $DB --drop-check"
fi
