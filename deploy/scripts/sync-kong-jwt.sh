#!/bin/bash
# Lấy public key của realm tbt từ Keycloak, sinh deploy/kong/kong.yml từ template.
# Chạy lại mỗi khi Keycloak tạo realm mới (xóa volume Hub), sau đó restart Kong các khu vực.
set -euo pipefail

KEYCLOAK_URL=${KEYCLOAK_URL:-http://localhost:8180}
ISSUER="$KEYCLOAK_URL/realms/tbt"
DIR=$(cd "$(dirname "$0")/.." && pwd)

key=$(curl -sf "$ISSUER" | python -c "import json,sys; print(json.load(sys.stdin)['public_key'])")
pem=$(printf '%s\n' "-----BEGIN PUBLIC KEY-----" $(echo "$key" | fold -w 64) "-----END PUBLIC KEY-----" | sed 's/^/          /')

python - "$DIR/kong/kong.template.yml" "$DIR/kong/kong.yml" "$ISSUER" "$pem" <<'EOF'
import sys
src, dst, issuer, pem = sys.argv[1:]
text = open(src, encoding='utf-8').read()
text = text.replace('__ISSUER__', f'"{issuer}"').replace('__PUBLIC_KEY__', pem)
text = text.replace('# Template. Chạy deploy/scripts/sync-kong-jwt.sh để sinh kong.yml kèm public key của Keycloak.',
                    '# File sinh tự động từ kong.template.yml, đừng sửa tay.')
open(dst, 'w', encoding='utf-8', newline='\n').write(text)
EOF

echo "Đã sinh kong.yml với issuer $ISSUER"
