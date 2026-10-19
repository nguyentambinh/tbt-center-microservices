/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-16
 */

import 'dart:io';

import 'package:datastore_service/src/ingestor.dart';
import 'package:tbt_common/tbt_common.dart';

final _env = Platform.environment;

final firestore = FirestoreClient.fromFile(_env['FIRESTORE_SA']);

final ingestor = Ingestor(
  FieldCipher.fromEnvironment(),
  (buckets) => firestore!.mergeBuckets(buckets),
);

/// Mỗi nước một token: token nào thì chỉ được ghi dữ liệu của nước đó
final regionTokens = <String, String>{
  for (final e in _env.entries)
    if (RegExp(r'^DATASTORE_TOKEN_([A-Z]{2})$').firstMatch(e.key) case final m?)
      e.value: m[1]!.toLowerCase(),
};
