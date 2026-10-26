/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/notification/domain/entities/app_notification.dart';
import '../../features/notification/presentation/pages/notifications_page.dart';
import '../../features/notification/presentation/providers/notification_providers.dart';
import '../../l10n/app_localizations.dart';
import '../auth/auth_controller.dart';
import '../../features/notification/presentation/notification_target.dart';
import '../router/app_router.dart';
import '../theme/app_theme.dart';

/// Gọi khi cần hỏi hộp thư ngay (FCM báo có tin lúc app đang mở)
final floatingNoticeRefresh = StreamController<void>.broadcast();

/// Thông báo mới hiện thẻ nổi trên cùng màn hình, ở mọi màn: tự ẩn sau 5 giây, vuốt lên để tắt, bấm để mở hộp thư
class FloatingNoticeHost extends ConsumerStatefulWidget {
  const FloatingNoticeHost({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<FloatingNoticeHost> createState() => _FloatingNoticeHostState();
}

class _FloatingNoticeHostState extends ConsumerState<FloatingNoticeHost> {
  final _seen = <String>{};
  bool _primed = false;
  Timer? _poll;
  Timer? _hide;
  StreamSubscription<void>? _refresh;
  List<AppNotification> _showing = const [];

  @override
  void initState() {
    super.initState();
    _refresh = floatingNoticeRefresh.stream.listen((_) => _check());
    ref.listenManual(authControllerProvider.select((s) => s.value?.subject), (_, subject) {
      _poll?.cancel();
      _seen.clear();
      _primed = false;
      setState(() => _showing = const []);
      if (subject == null) return;
      _check();
      _poll = Timer.periodic(inboxRefreshEvery, (_) => _check());
    }, fireImmediately: true);
  }

  Future<void> _check() async {
    if (ref.read(authControllerProvider).value == null) return;
    try {
      final inbox = await ref.read(notificationRepositoryProvider).inbox();
      final fresh = [for (final n in inbox.items) if (!n.read && !_seen.contains(n.id)) n];
      _seen.addAll(inbox.items.map((n) => n.id));
      // Lần đầu chỉ ghi nhớ thông báo cũ, không bật nổi lại
      if (!_primed) {
        _primed = true;
        return;
      }
      if (fresh.isEmpty || !mounted) return;
      ref.invalidate(inboxProvider);
      setState(() => _showing = fresh);
      _hide?.cancel();
      _hide = Timer(const Duration(seconds: 5), _dismiss);
    } on Object {
      // Mất mạng đã có thanh kết nối báo; lần hỏi sau thử lại
    }
  }

  void _dismiss() {
    if (mounted) setState(() => _showing = const []);
  }

  /// Một thông báo thì mở thẳng đơn liên quan, nhiều thông báo thì mở hộp thư
  void _open() {
    final items = _showing;
    _dismiss();
    final router = ref.read(appRouterProvider);
    final navigator = router.routerDelegate.navigatorKey.currentContext;
    if (items.length == 1 && navigator != null && navigator.mounted) {
      openNotification(navigator, ref, items.first);
    } else {
      router.push(Routes.notifications);
    }
  }

  @override
  void dispose() {
    _poll?.cancel();
    _hide?.cancel();
    _refresh?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned(
          left: 12,
          right: 12,
          top: 0,
          child: SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              transitionBuilder: (child, animation) => SlideTransition(
                position: Tween(begin: const Offset(0, -1.2), end: Offset.zero).animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: _showing.isEmpty
                  ? const SizedBox.shrink(key: ValueKey('empty'))
                  : _NoticeCard(key: ValueKey(_showing.first.id), items: _showing, onTap: _open, onDismiss: _dismiss),
            ),
          ),
        ),
      ],
    );
  }
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({super.key, required this.items, required this.onTap, required this.onDismiss});

  final List<AppNotification> items;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final accent = Theme.of(context).colorScheme.primary;
    final first = items.first;
    return Dismissible(
      key: const ValueKey('floating-notice'),
      direction: DismissDirection.up,
      onDismissed: (_) => onDismiss(),
      child: Material(
        color: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: InkWell(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                decoration: BoxDecoration(
                  color: context.tbt.glassTop,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: accent.withValues(alpha: 0.55)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.notifications_active, color: accent),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(notificationText(l10n, first, locale), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                          if (items.length > 1)
                            Text(l10n.moreNotifications(items.length - 1), style: TextStyle(color: context.tbt.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                    // Thẻ nằm ngoài Navigator (không có Overlay) nên không dùng nút có tooltip
                    InkResponse(onTap: onDismiss, radius: 20, child: Padding(padding: const EdgeInsets.all(8), child: Icon(Icons.close, size: 18, semanticLabel: l10n.close))),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
