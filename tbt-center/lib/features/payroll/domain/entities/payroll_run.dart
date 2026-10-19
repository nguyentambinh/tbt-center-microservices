/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

class SagaStep {
  const SagaStep({required this.step, required this.status, this.detail, required this.at});

  final String step;
  final String status;
  final String? detail;
  final DateTime at;
}

class PayrollRun {
  const PayrollRun({
    required this.id,
    required this.period,
    required this.status,
    this.error,
    this.steps = const [],
    this.paidCount = 0,
    this.paidUsd,
  });

  final String id;
  final String period;

  /// running, completed hoặc failed.
  final String status;
  final String? error;
  final List<SagaStep> steps;
  final int paidCount;
  final double? paidUsd;

  bool get isRunning => status == 'running';
}
