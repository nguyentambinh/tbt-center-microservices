/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

/// Địa chỉ các thành phần server. Mặc định trỏ về máy tính qua `adb reverse`,
/// đổi lúc build bằng `--dart-define=GEO_URL=...`.
abstract final class Env {
  static const geoUrl = String.fromEnvironment('GEO_URL', defaultValue: 'http://localhost:8190');
  static const keycloakUrl = String.fromEnvironment('KEYCLOAK_URL', defaultValue: 'http://localhost:8180');
  static const publicIpUrl = 'https://api.ipify.org';

  static const regions = ['vn', 'de', 'us', 'br', 'za', 'au'];
  static const _kongPorts = {'vn': 8000, 'de': 8100, 'us': 8200, 'br': 8300, 'za': 8400, 'au': 8500};

  /// Mẫu địa chỉ Kong khi chạy máy chủ thật, ví dụ `https://{region}.tbt.example`
  static const _kongTemplate = String.fromEnvironment('KONG_URL');

  static String kongUrl(String region) => _kongTemplate.isEmpty ? 'http://localhost:${_kongPorts[region] ?? 8000}' : _kongTemplate.replaceAll('{region}', region);

  /// Tiền tệ mặc định của khu vực
  static String currencyOf(String? region) => const {'vn': 'VND', 'de': 'EUR', 'us': 'USD', 'br': 'BRL', 'za': 'ZAR', 'au': 'AUD'}[region] ?? 'USD';

  /// Thư mục tệp mẫu (mẫu hợp đồng); để trống thì app ẩn nút tải mẫu
  static const filesUrl = String.fromEnvironment('FILES_URL');

  static String get contractTemplateUrl => '$filesUrl/hop-dong-mau.docx';

  /// Chỉ request tới Kong mới được gắn token, không bao giờ gửi token cho trang bên ngoài.
  static bool isKongUrl(Uri uri) => regions.any((region) => uri.toString().startsWith(kongUrl(region)));
}
