#!/bin/bash
# Lần đầu chép toàn bộ dữ liệu từ primary, sau đó chạy ở chế độ chỉ đọc và nhận WAL liên tục.
set -e

if [ ! -s "$PGDATA/PG_VERSION" ]; then
  until pg_isready -h postgres-primary -U "$POSTGRES_USER" -q; do
    sleep 1
  done
  PGPASSWORD="$REPLICATION_PASSWORD" pg_basebackup \
    -h postgres-primary -U replicator -D "$PGDATA" -R -X stream
  chmod 700 "$PGDATA"
fi

exec postgres -c hot_standby=on
