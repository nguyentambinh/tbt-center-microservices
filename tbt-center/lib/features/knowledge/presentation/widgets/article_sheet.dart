/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-17
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_states.dart';
import '../../../../core/widgets/motion.dart';
import '../providers/knowledge_providers.dart';

/// Mở bài viết ở bảng trượt từ dưới lên
Future<void> showArticleSheet(BuildContext context, String id) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => ArticleSheet(id: id),
    );

class ArticleSheet extends ConsumerWidget {
  const ArticleSheet({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final article = ref.watch(articleProvider(id));
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.7,
      child: switch (article) {
        AsyncValue(:final value?) => ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              Text(value.title, style: text.headlineSmall),
              const SizedBox(height: 12),
              Text(value.body, style: text.bodyLarge?.copyWith(height: 1.5)),
              if (value.source case final source?) ...[
                const SizedBox(height: 16),
                Text(source, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ],
          ),
        AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(articleProvider(id))),
        _ => const SkeletonList(rows: 3),
      },
    );
  }
}
