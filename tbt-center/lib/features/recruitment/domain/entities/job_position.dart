/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

/// Số vị trí tối đa một ứng viên chọn, khớp service recruitment
const maxPositionsPerCandidate = 5;

/// Ứng viên trong một vị trí, xếp theo điểm phù hợp
class PositionApplicant {
  const PositionApplicant({required this.id, required this.fullName, required this.status, this.matchScore, this.matchVerdict, this.matched = false});

  final String id;
  final String fullName;
  final String status;
  final int? matchScore;
  final String? matchVerdict;
  final bool matched;
}

/// Vị trí HR mở tuyển, kèm số người cần và đã tuyển
class JobPosition {
  const JobPosition({
    required this.id,
    required this.title,
    required this.headcount,
    required this.status,
    this.department,
    this.description = '',
    this.requirements = '',
    this.applicants = 0,
    this.hired = 0,
    this.candidates = const [],
  });

  final int id;
  final String title;
  final String? department;
  final String description;
  final String requirements;
  final int headcount;

  /// open, closed
  final String status;
  final int applicants;
  final int hired;
  final List<PositionApplicant> candidates;

  int get remaining => headcount - hired;
  bool get open => status == 'open';
  bool get acceptsApplicants => open && remaining > 0;
}

/// Vị trí ứng viên đã chọn, kèm kết quả AI so khớp CV
class PositionMatch {
  const PositionMatch({required this.id, required this.title, this.score, this.verdict, this.strengths, this.gaps, this.matched = false});

  final int id;
  final String title;
  final int? score;
  final String? verdict;
  final String? strengths;
  final String? gaps;
  final bool matched;
}

class JobPositionInput {
  const JobPositionInput({required this.title, required this.headcount, this.department, this.description = '', this.requirements = '', this.status = 'open'});

  final String title;
  final int headcount;
  final String? department;
  final String description;
  final String requirements;
  final String status;
}
