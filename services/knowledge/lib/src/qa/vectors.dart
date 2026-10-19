/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-17
 */

import 'dart:math';
import 'dart:typed_data';

/// Vector lưu thành bytea: 4 byte mỗi số (float32)
List<int> encodeVector(List<double> v) =>
    Float32List.fromList(v).buffer.asUint8List();

List<double> decodeVector(List<int> bytes) =>
    Float32List.view(Uint8List.fromList(bytes).buffer).toList();

/// Độ giống nhau về nghĩa, 1 là trùng hướng, 0 là không liên quan
double cosine(List<double> a, List<double> b) {
  var dot = 0.0;
  var na = 0.0;
  var nb = 0.0;
  for (var i = 0; i < min(a.length, b.length); i++) {
    dot += a[i] * b[i];
    na += a[i] * a[i];
    nb += b[i] * b[i];
  }
  return na == 0 || nb == 0 ? 0 : dot / (sqrt(na) * sqrt(nb));
}

/// Reciprocal Rank Fusion: gộp nhiều danh sách xếp hạng, bài đứng cao ở nhiều
/// danh sách thì lên đầu; không cần chuẩn hóa điểm giữa các cách tìm
List<String> fuseRankings(Map<String, List<String>> rankings, {int k = 60}) {
  final score = <String, double>{};
  for (final list in rankings.values) {
    for (var i = 0; i < list.length; i++) {
      score.update(
        list[i],
        (s) => s + 1 / (k + i + 1),
        ifAbsent: () => 1 / (k + i + 1),
      );
    }
  }
  final ids = score.keys.toList()
    ..sort((a, b) {
      final byScore = score[b]!.compareTo(score[a]!);
      return byScore != 0 ? byScore : a.compareTo(b);
    });
  return ids;
}
