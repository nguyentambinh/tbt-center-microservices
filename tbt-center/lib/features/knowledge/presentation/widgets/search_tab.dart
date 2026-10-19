/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-16
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_states.dart';
import '../../../../core/widgets/motion.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/knowledge_providers.dart';
import 'article_sheet.dart';

/// Tìm bài theo từ khóa, gõ không dấu vẫn ra
class SearchTab extends ConsumerStatefulWidget {
  const SearchTab({super.key});

  @override
  ConsumerState<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends ConsumerState<SearchTab> {
  String _query = '';
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  // Gõ xong 300 ms mới tìm, không gọi server mỗi phím
  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () => setState(() => _query = value.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final results = ref.watch(knowledgeSearchProvider(_query));
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            onChanged: _onChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: l10n.knowledgeSearchHint),
          ),
        ),
        Expanded(
          child: switch (results) {
            AsyncValue(:final value?) when value.isEmpty => EmptyView(message: l10n.knowledgeEmpty),
            AsyncValue(:final value?) => ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                itemCount: value.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) => FadeSlideIn(
                  index: i,
                  child: PressableScale(
                    child: Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        title: Text(value[i].title),
                        subtitle: _Snippet(value[i].snippet),
                        trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                        onTap: () => showArticleSheet(context, value[i].id),
                      ),
                    ),
                  ),
                ),
              ),
            AsyncValue(:final error?) =>
              ErrorView(error: error, onRetry: () => ref.invalidate(knowledgeSearchProvider(_query))),
            _ => const SkeletonList(),
          },
        ),
      ],
    );
  }
}

/// Đoạn trích, từ khớp (trong << >>) in đậm màu nhấn
class _Snippet extends StatelessWidget {
  const _Snippet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final parts = text.split(RegExp('<<|>>'));
    return Text.rich(
      TextSpan(
        style: const TextStyle(color: AppColors.textSecondary),
        children: [
          for (var i = 0; i < parts.length; i++)
            TextSpan(
              text: parts[i],
              style: i.isOdd ? TextStyle(color: color, fontWeight: FontWeight.w800) : null,
            ),
        ],
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }
}
