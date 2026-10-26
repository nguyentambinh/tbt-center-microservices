# ADR 0035: Phân cấp tài khoản nước, tập đoàn; văn phòng quản lý làm thẳng; service quản trị dữ liệu

Ngày: 2026-10-26. Trạng thái: đã áp dụng cho cả 6 khu vực và Hub trên máy chủ thật.

## Bối cảnh
Trước đây một tài khoản mang cả vai trò điều hành và quản trị, vai trò `executive` được đọc dữ liệu mọi khu vực, quản trị (`admin`) làm được nghiệp vụ như HR. Doanh nghiệp cần tách rõ: mỗi nước có văn phòng quản lý và quản trị riêng; tập đoàn có văn phòng, quản trị, HR, tài chính xem được mọi nước; văn phòng quản lý chỉ duyệt và ra quyết định, không đề xuất; quản trị chỉ lo cấu hình, dữ liệu, không duyệt nghiệp vụ.

## Quyết định
- Vai trò đánh dấu `group` (Keycloak realm role) đi kèm vai trò nghiệp vụ. `requireClaims` trong `tbt_common` cho tài khoản `group` qua mọi khu vực; vai trò khác chỉ vào khu vực ghi trong token (`region`). Tài khoản: `executive.<kv>`, `admin.<kv>`, `hr.<kv>`, `finance.<kv>` cho từng nước; `anonymous1606` (văn phòng), `admin`, `hr.group`, `finance.group` cho tập đoàn.
- Văn phòng quản lý làm thẳng, có hiệu lực ngay, ghi outbox để lên sổ kiểm toán: đổi chức vụ (`POST /hr/employees/{id}/position`, thăng chức chỉ lên cấp cao hơn), đổi lương cơ bản (`PUT /payroll/salaries/{id}`), thưởng phạt (`POST /payroll/bonuses-penalties`). Duyệt được mọi đơn chờ, kể cả đề xuất tăng lương còn ở bước HR. Không ai làm thẳng cho chính mình (`self_approval`).
- Đề cử lên cấp tập đoàn (`promotion_nominations.scope = group`, chức vụ `GRP-HR`, `GRP-FIN`): HR một nước đề cử, chỉ văn phòng tập đoàn duyệt (`group_only`); duyệt xong hr gọi Keycloak Admin API cấp vai trò `hr`/`finance` + `group` cho tài khoản gắn mã nhân viên.
- Service `admin` mỗi khu vực (Kong `/admin`, CSDL `admin_db` chỉ chứa outbox): thống kê dung lượng, số dòng, hoạt động 14 ngày, tài khoản theo vai trò; quản lý tài khoản qua Keycloak (quản trị nước chỉ gán `employee`, `hr`, `finance`, `auditor` trong nước mình); ô SQL chạy trong giao dịch chỉ đọc mặc định, ghi phải bật `write`, tối đa 10 giây, 500 dòng, không được đụng `admin_db`; sao lưu logic mọi CSDL thành JSON nén lên Garage. Mọi thao tác ghi sự kiện `Admin*`, `BackupCreated`, `AccountChanged` lên sổ kiểm toán.
- Cấu hình nằm ở service sở hữu dữ liệu, chỉ `admin` gọi được: ngày lễ, giờ ca (attendance), danh mục chức vụ và cấp (hr).
- WAF khu vực có một ngoại lệ hẹp: luật SQL injection bỏ cho trường JSON `sql` trên đúng đường `/admin/sql` (`deploy/waf/region-exclusions.conf`); mọi đường khác giữ nguyên.
- Thông báo: quản trị chỉ nhận "nhật ký mới" cho thao tác quản trị, đổi cấu hình, việc văn phòng làm thẳng; không nhận việc cần duyệt. Nhân viên bị làm thẳng nhận thông báo kết quả.

## Hệ quả
- Một chỗ sửa (`requireClaims`) đổi phạm vi cho mọi service; thêm tài khoản cấp tập đoàn chỉ cần gán vai trò `group`.
- Ô SQL là công cụ mạnh: được bù bằng chỉ đọc mặc định, ghi sổ kiểm toán không xóa được ở Hub, và bảo vệ `admin_db` khỏi chính quản trị.
- App có `workRegionProvider`: tài khoản tập đoàn chọn nước đang xem, mọi màn nghiệp vụ gọi Kong của nước đó.
- Khoản phạt trước đây bị cộng vào lương khi chốt lương; đã sửa thành trừ.

Yêu cầu liên quan: R26, R44, R60, R88, R96.
