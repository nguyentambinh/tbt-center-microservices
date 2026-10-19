# IP công khai dùng để thử dò khu vực

Nhập ở màn đăng nhập: **Change Manual IP** (góc dưới bên trái), hoặc bấm tên nước để điền sẵn. App gửi IP này cho service `geo` ở Hub, nhận về khu vực lưu hồ sơ ứng viên và ngôn ngữ mặc định. Nhân viên đăng nhập vẫn dùng khu vực ghi trong tài khoản.

| Nước | Khu vực | Ngôn ngữ | IP 1 | IP 2 |
|---|---|---|---|---|
| Việt Nam | vn | vi | 113.161.0.1 | 14.161.0.1 |
| Đức | de | de | 85.214.0.1 | 46.4.0.1 |
| Hoa Kỳ | us | en | 8.8.8.8 | 23.0.0.1 |
| Brazil | br | pt | 200.160.0.1 | 177.0.0.1 |
| Nam Phi | za | en | 196.25.1.1 | 41.0.0.1 |
| Úc | au | en | 139.130.4.5 | 1.120.0.1 |

Kiểm lại một IP: `curl "http://localhost:8190/lookup?ip=<IP>"`.

Nộp hồ sơ ứng viên thì máy chủ của khu vực đó phải đang chạy.
