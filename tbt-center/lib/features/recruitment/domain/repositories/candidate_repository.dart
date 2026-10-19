/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import '../entities/candidate.dart';

abstract interface class CandidateRepository {
  /// Hồ sơ của chính ứng viên; `null` nếu chưa nộp.
  Future<Candidate?> myApplication();

  Future<Candidate> saveMyApplication(CandidateInput input);

  /// Tải CV (PDF) thẳng lên kho của khu vực bằng URL ký sẵn, rồi báo service.
  Future<Candidate> uploadCv(List<int> pdf);

  /// URL tạm (5 phút) để HR mở CV của ứng viên.
  Future<Uri> cvDownloadUrl(String candidateId);

  Future<List<Candidate>> candidates({String? status});

  Future<Candidate> candidate(String id);

  Future<Candidate> changeStage(String id, {required String status, String? note});

  /// Nhận ứng viên đã có offer vào làm.
  Future<HireResult> hire(String id);
}
