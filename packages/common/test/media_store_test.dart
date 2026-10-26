/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:tbt_common/tbt_common.dart';
import 'package:test/test.dart';

void main() {
  MediaStore store(DateTime now) => MediaStore(
    presigner: S3Presigner(
      accessKeyId: 'GKtest',
      secretAccessKey: 'secret',
      bucket: 'tbt-media',
    ),
    publicEndpoint: Uri.parse('https://s3-vn.example.com'),
    clock: () => now,
  );

  test('URL trỏ đúng bucket, object và hạn 2 ngày', () {
    final url = Uri.parse(
      store(DateTime.utc(2026, 10, 25, 9)).url('employees/E1.jpg')!,
    );
    expect(url.host, 's3-vn.example.com');
    expect(url.path, '/tbt-media/employees/E1.jpg');
    expect(url.queryParameters['X-Amz-Expires'], '172800');
    expect(url.queryParameters['X-Amz-Date'], '20261025T000000Z');
  });

  test('trong cùng một ngày URL không đổi, sang ngày khác thì đổi', () {
    final morning = store(DateTime.utc(2026, 10, 25, 1)).url('projects/P1.jpg');
    final evening = store(DateTime.utc(2026, 10, 25, 23))
        .url('projects/P1.jpg');
    final next = store(DateTime.utc(2026, 10, 26, 1)).url('projects/P1.jpg');
    expect(morning, evening);
    expect(next, isNot(morning));
  });

  test('không có ảnh thì null, địa chỉ http có sẵn thì giữ nguyên', () {
    final media = store(DateTime.utc(2026, 10, 25));
    expect(media.url(null), isNull);
    expect(media.url(''), isNull);
    expect(media.url('https://cdn/a.jpg'), 'https://cdn/a.jpg');
  });

  test('thiếu khóa S3 thì không tạo MediaStore', () {
    expect(
      MediaStore.fromEnvironment({'S3_PUBLIC_ENDPOINT': 'https://x'}),
      isNull,
    );
  });
}
