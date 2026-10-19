#!/bin/bash
# Chạy một lần khi primary khởi tạo dữ liệu lần đầu.
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname postgres <<-EOSQL
  CREATE ROLE replicator WITH REPLICATION LOGIN PASSWORD '$REPLICATION_PASSWORD';
EOSQL

for db in $SERVICE_DATABASES; do
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname postgres -c "CREATE DATABASE $db;"
done

echo "host replication replicator all scram-sha-256" >> "$PGDATA/pg_hba.conf"
