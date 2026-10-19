/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

enum CircuitState { closed, open, halfOpen }

/// Mạch đang mở: dịch vụ ngoài vừa lỗi liên tục, tạm không gọi để khỏi chờ
/// vô ích và khỏi dồn thêm tải lên dịch vụ đang hỏng.
class CircuitOpenException implements Exception {
  const CircuitOpenException(this.name, this.retryAfter);

  final String name;
  final Duration retryAfter;

  @override
  String toString() =>
      'Circuit "$name" is open, retry after ${retryAfter.inSeconds}s';
}

/// Circuit Breaker bảo vệ lời gọi ra dịch vụ ngoài (ngân hàng, Claude API…).
///
/// - closed: gọi bình thường, đếm số lần lỗi liên tiếp.
/// - open: lỗi đủ [failureThreshold] lần thì ngắt, mọi lời gọi bị từ chối
///   ngay trong [openFor].
/// - halfOpen: hết thời gian ngắt thì cho thử một lời gọi; thành công thì
///   đóng mạch, lỗi thì ngắt tiếp.
class CircuitBreaker {
  CircuitBreaker(
    this.name, {
    this.failureThreshold = 3,
    this.openFor = const Duration(seconds: 30),
    DateTime Function()? clock,
  }) : _now = clock ?? DateTime.now;

  final String name;
  final int failureThreshold;
  final Duration openFor;
  final DateTime Function() _now;

  CircuitState _state = CircuitState.closed;
  int _failures = 0;
  DateTime? _openedAt;
  bool _trialRunning = false;

  CircuitState get state {
    final opened = _openedAt;
    if (_state == CircuitState.open &&
        opened != null &&
        !_now().isBefore(opened.add(openFor))) {
      _state = CircuitState.halfOpen;
    }
    return _state;
  }

  /// Chạy [action] qua mạch. [isFailure] quyết định lỗi nào tính là dịch vụ
  /// hỏng; mặc định mọi lỗi đều tính (lỗi do dữ liệu đầu vào thì nên loại ra).
  Future<T> call<T>(
    Future<T> Function() action, {
    bool Function(Object error)? isFailure,
  }) async {
    switch (state) {
      case CircuitState.open:
        final wait = _openedAt!.add(openFor).difference(_now());
        throw CircuitOpenException(name, wait);
      case CircuitState.halfOpen:
        // Chỉ một lời gọi thử, các lời gọi khác vẫn bị từ chối.
        if (_trialRunning) throw CircuitOpenException(name, Duration.zero);
        _trialRunning = true;
      case CircuitState.closed:
        break;
    }

    try {
      final result = await action();
      _onSuccess();
      return result;
    } on Object catch (error) {
      if (isFailure?.call(error) ?? true) {
        _onFailure();
      } else {
        _onSuccess();
      }
      rethrow;
    } finally {
      _trialRunning = false;
    }
  }

  void _onSuccess() {
    _state = CircuitState.closed;
    _failures = 0;
    _openedAt = null;
  }

  void _onFailure() {
    _failures++;
    if (_state == CircuitState.halfOpen || _failures >= failureThreshold) {
      _state = CircuitState.open;
      _openedAt = _now();
    }
  }
}
