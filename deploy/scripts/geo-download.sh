#!/bin/bash
# Tải bảng IP → quốc gia DB-IP Lite (CC BY 4.0, https://db-ip.com) của tháng hiện tại về deploy/geo/data.
set -euo pipefail

DIR=$(cd "$(dirname "$0")/.." && pwd)
MONTH=${1:-$(date +%Y-%m)}
mkdir -p "$DIR/geo/data"
curl -sfL -o "$DIR/geo/data/dbip-country-lite.csv.gz" \
  "https://download.db-ip.com/free/dbip-country-lite-$MONTH.csv.gz"
echo "Đã tải bảng IP tháng $MONTH."
