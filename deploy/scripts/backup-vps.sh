#!/bin/bash
# Kéo bản sao lưu đầy đủ từ máy chủ về máy dev, không nạp vào đâu.
# Gồm mọi CSDL của Hub và 6 khu vực (pg_dump -Fc) và kho tệp Garage (dữ liệu + bản chụp metadata).
# Doris dựng lại được từ sổ audit; log Elasticsearch, hàng đợi RabbitMQ là dữ liệu tạm nên không lấy.
# Cách dùng: bash deploy/scripts/backup-vps.sh root@<máy chủ> [thư mục lưu]
set -euo pipefail

HOST=${1:?Cách dùng: backup-vps.sh root@<máy chủ> [thư mục lưu]}
DIR=$(cd "$(dirname "$0")/../.." && (pwd -W 2>/dev/null || pwd))
export MSYS_NO_PATHCONV=1
OUT="${2:-$DIR/deploy/backups}/vps-$(date +%Y%m%d-%H%M%S)"

dump_databases() {
  local target=$1 exec=$2 folder="$OUT/$1"
  mkdir -p "$folder"
  local databases
  databases=$(printf '%s' "select datname from pg_database where datname like '%\_db' order by 1" |
    ssh "$HOST" "$exec sh -c 'psql -tA -U \"\$POSTGRES_USER\" -d postgres'")
  for db in $databases; do
    ssh "$HOST" "$exec sh -c 'pg_dump -Fc -U \"\$POSTGRES_USER\" -d $db'" > "$folder/$db.dump"
    echo "  $target/$db: $(du -h "$folder/$db.dump" | cut -f1)"
  done
}

# Bản chụp metadata lấy trước để nhất quán, khối dữ liệu Garage không đổi sau khi ghi
archive_garage() {
  local target=$1 snapshot=$2 data=$3 meta=$4
  ssh "$HOST" "$snapshot" >/dev/null 2>&1
  ssh "$HOST" "tar -C '$data' -czf - ." > "$OUT/$target/garage-data.tar.gz"
  ssh "$HOST" "tar -C '$meta' -czf - --exclude='./db.sqlite*' --exclude='./db.lmdb' ." > "$OUT/$target/garage-meta.tar.gz"
  echo "  $target/garage: $(du -h "$OUT/$target/garage-data.tar.gz" | cut -f1) + $(du -h "$OUT/$target/garage-meta.tar.gz" | cut -f1) metadata"
}

dump_databases hub "docker exec -i tbt-hub-hub-postgres-1"
for region in vn us br za au; do
  dump_databases "$region" "docker exec -i tbt-$region-postgres-primary-1"
  archive_garage "$region" "docker exec tbt-$region-garage-1 /garage meta snapshot" \
    "/var/lib/docker/volumes/tbt-${region}_garage-data/_data" "/var/lib/docker/volumes/tbt-${region}_garage-meta/_data"
done

# Khu vực Đức chạy k3s, ổ Garage là PersistentVolume
dump_databases de "kubectl -n tbt-de exec -i postgres-primary-0 --"
path() { ssh "$HOST" "kubectl get pv $1 -o jsonpath='{.spec.hostPath.path}{.spec.local.path}'"; }
archive_garage de "kubectl -n tbt-de exec garage-0 -- /garage meta snapshot" "$(path tbt-garage-data)" "$(path tbt-garage-meta)"

(cd "$OUT" && find . -type f ! -name SHA256SUMS -print0 | sort -z | xargs -0 sha256sum > SHA256SUMS)
echo "Xong: $OUT ($(du -sh "$OUT" | cut -f1))"
