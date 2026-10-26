/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Ảnh chữ nhật bo góc (ảnh công trình); lỗi tải hoặc chưa có ảnh thì hiện biểu tượng công trình
class RemotePhoto extends StatelessWidget {
  const RemotePhoto({
    super.key,
    required this.url,
    this.aspectRatio = 16 / 9,
    this.radius = 16,
    this.icon = Icons.apartment,
  });

  final String? url;
  final double aspectRatio;
  final double radius;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final fallback = ColoredBox(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
      child: Center(child: Icon(icon, size: 40, color: context.tbt.textSecondary)),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: url == null
            ? fallback
            : LayoutBuilder(
                builder: (context, box) => Image.network(
                  url!,
                  fit: BoxFit.cover,
                  cacheWidth: (box.maxWidth * MediaQuery.devicePixelRatioOf(context)).round(),
                  loadingBuilder: (context, child, progress) => progress == null ? child : const _Placeholder(),
                  errorBuilder: (_, _, _) => fallback,
                ),
              ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) => ColoredBox(color: context.tbt.textSecondary.withValues(alpha: 0.12));
}
