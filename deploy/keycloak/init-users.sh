#!/bin/bash
# Tạo tài khoản mặc định và tài khoản thử cho từng vai trò. Chạy lại nhiều lần không sao.
set -e
KC=/opt/keycloak/bin/kcadm.sh

until $KC config credentials --server http://keycloak:8080 --realm master \
  --user "$KC_BOOTSTRAP_ADMIN_USERNAME" --password "$KC_BOOTSTRAP_ADMIN_PASSWORD" >/dev/null 2>&1; do
  sleep 2
done

# Lúc import realm, Keycloak bỏ qua composites của defaultRole, nên gán ở đây:
# ai tự đăng ký đều nhận role candidate.
$KC add-roles -r tbt --rname default-roles-tbt --rolename candidate

# Trang đăng nhập, đăng ký hiện theo ngôn ngữ app gửi qua ui_locales
# (vi, en, de, pt-BR); không gửi thì dùng tiếng Anh.
$KC update realms/tbt -s internationalizationEnabled=true \
  -s 'supportedLocales=["vi","en","de","pt-BR"]' -s defaultLocale=en

# Client cho recruitment cấp tài khoản nhân viên mới
if [ -n "$KEYCLOAK_IDENTITY_SECRET" ]; then
  if [ -z "$($KC get clients -r tbt -q clientId=tbt-identity --fields id --format csv --noquotes)" ]; then
    $KC create clients -r tbt -s clientId=tbt-identity -s enabled=true -s publicClient=false \
      -s serviceAccountsEnabled=true -s standardFlowEnabled=false -s directAccessGrantsEnabled=false \
      -s "secret=$KEYCLOAK_IDENTITY_SECRET"
  fi
  $KC add-roles -r tbt --uusername service-account-tbt-identity --cclientid realm-management \
    --rolename manage-users --rolename view-users --rolename query-users --rolename view-realm
fi

# Vai trò kiểm toán (R88), thêm sau khi realm đã import.
$KC get roles/auditor -r tbt >/dev/null 2>&1 || \
  $KC create roles -r tbt -s name=auditor -s 'description=Kiểm toán, chỉ đọc sổ kiểm toán'

# Realm tạo trước khi có claim employee_id, access_until thì thêm mapper vào hai client.
for client in tbt-mobile tbt-dev-cli; do
  cid=$($KC get clients -r tbt -q clientId=$client --fields id --format csv --noquotes)
  for claim in employee_id access_until; do
    if ! $KC get clients/$cid/protocol-mappers/models -r tbt --fields name --format csv --noquotes | grep -qx $claim; then
      $KC create clients/$cid/protocol-mappers/models -r tbt -s name=$claim -s protocol=openid-connect \
        -s protocolMapper=oidc-usermodel-attribute-mapper \
        -s "config.\"user.attribute\"=$claim" -s "config.\"claim.name\"=$claim" \
        -s 'config."jsonType.label"=String' -s 'config."access.token.claim"=true' \
        -s 'config."id.token.claim"=true' -s 'config."userinfo.token.claim"=true'
    fi
  done
done

create_user() {
  local user=$1 first=$2 last=$3 region=$4 country=$5 employee=$6
  shift 6
  local id
  id=$($KC get users -r tbt -q username="$user" -q exact=true --fields id --format csv --noquotes)
  if [ -z "$id" ]; then
    $KC create users -r tbt -s username="$user" -s enabled=true -s emailVerified=true
    $KC set-password -r tbt --username "$user" --new-password "$TBT_DEFAULT_PASSWORD"
    id=$($KC get users -r tbt -q username="$user" -q exact=true --fields id --format csv --noquotes)
    echo "Đã tạo $user"
  fi
  # Ghi lại thông tin mỗi lần chạy để tài khoản tạo từ trước cũng có employee_id.
  $KC update "users/$id" -r tbt -s email="$user@tbt.local" -s firstName="$first" -s lastName="$last" \
    -s "attributes.region=[\"$region\"]" -s "attributes.country_code=[\"$country\"]" \
    -s "attributes.employee_id=[\"$employee\"]"
  for role in "$@"; do
    $KC add-roles -r tbt --uusername "$user" --rolename "$role"
  done
  not_candidate "$user"
}

# Nhân viên không mang role candidate
not_candidate() {
  $KC remove-roles -r tbt --uusername "$1" --rolename default-roles-tbt --rolename candidate >/dev/null 2>&1 || true
  # default-roles có offline_access; thiếu nó app không xin được refresh token lâu dài
  $KC add-roles -r tbt --uusername "$1" --rolename offline_access
}

# Mã nhân viên lấy từ dữ liệu mẫu (deploy/seed) của khu vực tương ứng.
create_user anonymous1606 Binh Nguyen vn VN Binh2657Y executive admin
create_user hr.vn Nhan Su vn VN ANH98191KH hr employee
create_user finance.vn Tai Chinh vn VN BAO11031CF finance employee
create_user employee.vn Nhan Vien vn VN Anh8715OP employee
create_user hr.de Anna Braun de DE ANN62037BER hr employee
create_user finance.de Andreas Wagner de DE AND90006HAM finance employee
create_user employee.de Lena Koch de DE LEN84001BER employee
create_user hr.us David Wilson us US DAV76001NYC hr employee
create_user employee.us Michael Garcia us US MIC88002CHI employee
create_user hr.br Rafael Costa br BR RAF87001SAO hr employee
create_user employee.br Beatriz Ferreira br BR BEA78002RIO employee
create_user hr.za Mandla Venter za ZA MAN64001JNB hr employee
create_user employee.za Johan Pretorius za ZA JOH91002CPT employee
create_user hr.au William Smith au AU WIL67001SYD hr employee
create_user employee.au James Brown au AU JAM84002MEL employee
create_user finance.us William Jackson us US WIL68003LAX finance employee
create_user finance.br Ana Costa br BR ANA75003BHZ finance employee
create_user finance.za Ruan Nkosi za ZA RUA80003DUR finance employee
create_user finance.au Matilda Brown au AU MAT69003BNE finance employee

# Kiểm toán độc lập (R88): không thuộc khu vực nào, chỉ đọc sổ kiểm toán tới hết
# ngày access_until. Gia hạn: đổi ngày ở đây hoặc trong Keycloak rồi chạy lại.
auditor_id=$($KC get users -r tbt -q username=auditor.ext -q exact=true --fields id --format csv --noquotes)
if [ -z "$auditor_id" ]; then
  $KC create users -r tbt -s username=auditor.ext -s enabled=true -s emailVerified=true
  $KC set-password -r tbt --username auditor.ext --new-password "$TBT_DEFAULT_PASSWORD"
  auditor_id=$($KC get users -r tbt -q username=auditor.ext -q exact=true --fields id --format csv --noquotes)
  echo "Đã tạo auditor.ext"
fi
$KC update "users/$auditor_id" -r tbt -s email=auditor.ext@tbt.local -s firstName=Kiem -s lastName=Toan \
  -s 'attributes.access_until=["2026-12-31"]'
$KC add-roles -r tbt --uusername auditor.ext --rolename auditor
not_candidate auditor.ext
echo "Xong tài khoản Keycloak."
