#!/bin/bash
# Kéo dữ liệu một khu vực (hoặc Hub) từ máy chủ về Docker ở máy dev, để máy dev
# chạy thay được khi máy chủ hỏng. Image không cần kéo: máy dev là nơi build.
# Các bước: dump mọi database trên máy chủ → sao lưu database local đang có →
# xóa, tạo lại, nạp bản của máy chủ. Chỉ bật Postgres primary của khu vực đó.
# Cách dùng: bash deploy/scripts/pull-vps.sh root@<máy chủ> <vn|us|de|br|za|au|hub>
# Tệp nằm ở deploy/backups/<khu vực>/vps-<thời điểm>/ và local-<thời điểm>/, không lên git.
set -euo pipefail

HOST=${1:?Cách dùng: pull-vps.sh root@<máy chủ> <khu vực|hub>}
TARGET=${2:?Cách dùng: pull-vps.sh root@<máy chủ> <khu vực|hub>}
DIR=$(cd "$(dirname "$0")/../.." && (pwd -W 2>/dev/null || pwd))
export MSYS_NO_PATHCONV=1
STAMP=$(date +%Y%m%d-%H%M%S)

if [ "$TARGET" = hub ]; then
  LOCAL=tbt-hub-hub-postgres-1
  REMOTE="docker exec -i tbt-hub-hub-postgres-1"
elif [ "$TARGET" = de ]; then
  # Khu vực Đức trên máy chủ chạy k3s, ở máy dev dùng chung volume với Compose DE
  LOCAL=tbt-de-postgres-primary-1
  REMOTE="kubectl -n tbt-de exec -i postgres-primary-0 --"
else
  LOCAL=tbt-$TARGET-postgres-primary-1
  REMOTE="docker exec -i tbt-$TARGET-postgres-primary-1"
fi

remote() { ssh "$HOST" "$REMOTE sh -c '$1'"; }
# Câu SQL đi qua stdin để không phải lồng dấu nháy qua ssh và docker exec
remote_sql() { printf '%s' "$1" | ssh "$HOST" "$REMOTE sh -c 'psql -tA -U \"\$POSTGRES_USER\" -d postgres'"; }
local_psql() { docker exec -i "$LOCAL" sh -c "$1"; }

VPS_DIR="$DIR/deploy/backups/$TARGET/vps-$STAMP"
LOCAL_DIR="$DIR/deploy/backups/$TARGET/local-$STAMP"
mkdir -p "$VPS_DIR" "$LOCAL_DIR"

DATABASES=$(remote_sql "select datname from pg_database where datname like '%\_db' order by 1")
echo "Database trên máy chủ: $(echo $DATABASES)"
for db in $DATABASES; do
  remote "pg_dump -Fc -U \"\$POSTGRES_USER\" -d $db" > "$VPS_DIR/$db.dump"
  echo "  kéo $db: $(du -h "$VPS_DIR/$db.dump" | cut -f1)"
done

docker start "$LOCAL" >/dev/null
until local_psql 'pg_isready -q -U "$POSTGRES_USER"' 2>/dev/null; do sleep 2; done

for db in $DATABASES; do
  exists=$(local_psql "psql -tA -U \"\$POSTGRES_USER\" -d postgres -c \"select 1 from pg_database where datname = '$db'\"")
  if [ "$exists" = 1 ]; then
    local_psql "pg_dump -Fc -U \"\$POSTGRES_USER\" -d $db" > "$LOCAL_DIR/$db.dump"
  fi
  local_psql "dropdb --if-exists --force -U \"\$POSTGRES_USER\" $db && createdb -U \"\$POSTGRES_USER\" $db"
  local_psql "pg_restore --no-owner --exit-on-error -U \"\$POSTGRES_USER\" -d $db" < "$VPS_DIR/$db.dump"
  echo "  nạp $db xong"
done

docker stop "$LOCAL" >/dev/null
(cd "$VPS_DIR" && sha256sum *.dump > SHA256SUMS)
echo "Xong $TARGET. Bản local cũ: deploy/backups/$TARGET/local-$STAMP"
