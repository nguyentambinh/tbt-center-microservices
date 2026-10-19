/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

/// Server gửi loại thông báo và tham số, app tự ghép câu theo ngôn ngữ đang chọn.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.kind,
    required this.createdAt,
    this.params = const {},
    this.read = false,
  });

  final String id;
  final String kind;
  final Map<String, dynamic> params;
  final DateTime createdAt;
  final bool read;
}

class Inbox {
  const Inbox({this.items = const [], this.unread = 0});

  final List<AppNotification> items;
  final int unread;
}
