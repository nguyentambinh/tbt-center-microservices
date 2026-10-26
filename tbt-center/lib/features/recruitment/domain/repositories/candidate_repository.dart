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

  /// Nhận ứng viên đã phỏng vấn (có biên bản) vào làm, kèm thỏa thuận.
  Future<HireResult> hire(String id, {HireOffer? offer});

  /// Hồ sơ đã từ chối quay về bước trước lúc từ chối
  Future<Candidate> reconsider(String id);

  /// HR hẹn phỏng vấn lần đầu (hoặc hẹn lại khi lịch cũ đã hủy)
  Future<Candidate> scheduleInterview(String id, {required DateTime at, String? location, String? note});

  /// HR trả lời lịch: confirm, propose (kèm giờ mới), decline (từ chối ứng viên)
  Future<Candidate> respondInterview(String id, {required String action, DateTime? at, String? note});

  /// Ứng viên xác nhận giờ HR hẹn hoặc đề xuất giờ khác
  Future<Candidate> respondMyInterview({required String action, DateTime? at, String? note});

  /// Tải biên bản phỏng vấn (Word, Excel) lên kho, hồ sơ sang "đã phỏng vấn"
  Future<Candidate> uploadMinutes(String id, {required String fileName, required List<int> bytes});

  Future<Uri> minutesUrl(String id);

  Future<OfferSuggestion> offerSuggestion(String id, {required String language});
}
