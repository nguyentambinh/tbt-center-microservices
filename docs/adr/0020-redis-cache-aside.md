# ADR 0020: Redis làm cache (cache-aside) cho dữ liệu đọc nhiều

Ngày: 2026-10-16. Trạng thái: đã áp dụng.

## Bối cảnh
Một số API đọc nhiều mà ít đổi: danh sách nhân viên, ngày lễ, tỷ giá, báo cáo tập đoàn (truy vấn Doris khoảng 300 ms). R46 yêu cầu mở rộng được khi người dùng tăng.

## Quyết định
- Mỗi khu vực một Redis 7.4, Hub một Redis: 64 MB, đầy thì bỏ key ít dùng (LRU), không lưu xuống đĩa.
- Client RESP tự viết trong `tbt_common` (chỉ GET, SET EX, INCR) và middleware `cachedGet` đặt **sau** bước kiểm token. Header `X-Cache: HIT/MISS`.
- Chỉ cache dữ liệu giống nhau cho mọi người được xem; dữ liệu riêng từng người không cache.
- Xóa cache bằng tăng số phiên bản nhóm (`INCR tbt:<nhóm>:version`): nhận người mới thì xóa danh sách nhân viên; report chiếu xong lô sự kiện mới thì xóa báo cáo.
- Redis hỏng thì bỏ qua cache, client nghỉ 10 giây sau lỗi.

## Hệ quả
- Đo qua Kong VN: báo cáo 301 → 9 ms, danh sách nhân viên 108 → 7 ms, ngày lễ 77 → 6 ms.
- Dữ liệu có thể cũ tối đa bằng TTL (60 giây đến 1 giờ tùy nhóm) nếu đổi bằng đường khác không xóa cache.

Yêu cầu liên quan: R46.
