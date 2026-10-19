/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-16
 */

/// Một kết quả tìm kiếm; đoạn trích có từ khớp bọc trong << >>
class ArticleHit {
  const ArticleHit({required this.id, required this.title, required this.category, required this.snippet});

  final String id;
  final String title;
  final String category;
  final String snippet;
}

class Article {
  const Article({required this.id, required this.title, required this.category, required this.body, this.source});

  final String id;
  final String title;
  final String category;
  final String body;
  final String? source;
}
