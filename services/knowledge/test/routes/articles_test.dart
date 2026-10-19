/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-16
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:knowledge_service/src/knowledge_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tbt_common/tbt_common.dart';
import 'package:test/test.dart';

import '../../routes/articles/[id].dart' as detail;
import '../../routes/articles/index.dart' as search;

class _MockContext extends Mock implements RequestContext {}

class _MockRepository extends Mock implements KnowledgeRepository {}

void main() {
  late _MockContext context;
  late _MockRepository repository;

  setUp(() {
    context = _MockContext();
    repository = _MockRepository();
    when(() => context.read<KnowledgeRepository>()).thenReturn(repository);
    when(() => context.read<Claims>()).thenReturn(
      Claims({
        'region': 'de',
        'realm_access': {
          'roles': ['employee'],
        },
      }),
    );
  });

  void request(String path, {String method = 'GET'}) => when(
    () => context.request,
  ).thenReturn(Request(method, Uri.parse('http://localhost$path')));

  test('tìm theo từ khóa, lọc theo khu vực của người hỏi', () async {
    when(
      () => repository.search('tang ca', lang: 'vi', region: 'de'),
    ).thenAnswer(
      (_) async => [
        {'id': 'overtime'},
      ],
    );
    request('/articles?q=tang%20ca&lang=vi');
    final body = await (await search.onRequest(context)).json() as Map;
    expect((body['items'] as List).single, {'id': 'overtime'});
  });

  test('chưa có bài tiếng Đức thì trả bài tiếng Anh', () async {
    when(
      () => repository.search('urlaub', lang: 'de', region: 'de'),
    ).thenAnswer((_) async => []);
    when(
      () => repository.search('urlaub', lang: 'en', region: 'de'),
    ).thenAnswer(
      (_) async => [
        {'id': 'leave'},
      ],
    );
    request('/articles?q=urlaub&lang=de');
    final body = await (await search.onRequest(context)).json() as Map;
    expect((body['items'] as List).single, {'id': 'leave'});
  });

  test('câu tìm quá 200 ký tự thì 400', () async {
    request('/articles?q=${'a' * 201}');
    expect((await search.onRequest(context)).statusCode, 400);
  });

  test('không phải GET thì 405', () async {
    request('/articles', method: 'POST');
    expect((await search.onRequest(context)).statusCode, 405);
  });

  test('bài không có thì 404', () async {
    when(
      () => repository.find(any(), lang: any(named: 'lang')),
    ).thenAnswer((_) async => null);
    request('/articles/khong-co?lang=vi');
    expect((await detail.onRequest(context, 'khong-co')).statusCode, 404);
  });
}
