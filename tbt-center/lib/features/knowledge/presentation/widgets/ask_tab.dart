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
import '../../../../core/widgets/motion.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/answer.dart';
import '../providers/knowledge_providers.dart';
import 'article_sheet.dart';

/// Hỏi đáp với trợ lý AI, câu trả lời có trích dẫn nguồn
class AskTab extends ConsumerStatefulWidget {
  const AskTab({super.key});

  @override
  ConsumerState<AskTab> createState() => _AskTabState();
}

class _AskTabState extends ConsumerState<AskTab> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send([String? text]) {
    final question = (text ?? _input.text).trim();
    if (question.isEmpty) return;
    _input.clear();
    // Bỏ focus ô nhập để bàn phím không bật lại khi đóng bảng bài viết
    FocusManager.instance.primaryFocus?.unfocus();
    ref.read(knowledgeChatProvider.notifier).send(question);
  }

  // Có lượt mới thì cuộn xuống cuối
  void _scrollToEnd() => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.animateTo(_scroll.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
        }
      });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final chat = ref.watch(knowledgeChatProvider);
    ref.listen(knowledgeChatProvider, (prev, next) {
      if (prev?.length != next.length || (prev?.lastOrNull?.pending ?? false)) _scrollToEnd();
    });
    final busy = chat.any((e) => e.pending);
    return Column(
      children: [
        Expanded(
          child: chat.isEmpty
              ? _Welcome(onPick: _send)
              : ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  itemCount: chat.length + 1,
                  itemBuilder: (context, i) {
                    if (i == chat.length) {
                      return busy
                          ? const SizedBox.shrink()
                          : Center(
                              child: TextButton.icon(
                                onPressed: ref.read(knowledgeChatProvider.notifier).clear,
                                icon: const Icon(Icons.refresh, size: 18),
                                label: Text(l10n.askNewChat),
                              ),
                            );
                    }
                    return _Turn(index: i, entry: chat[i], onFollowUp: busy ? null : _send);
                  },
                ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 8, 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _input,
                    enabled: !busy,
                    minLines: 1,
                    maxLines: 4,
                    maxLength: 500,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(hintText: l10n.askHint, counterText: ''),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton.filled(
                  tooltip: l10n.askSend,
                  onPressed: busy ? null : _send,
                  icon: const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Welcome extends StatelessWidget {
  const _Welcome({required this.onPick});

  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final accent = Theme.of(context).colorScheme.primary;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      children: [
        Icon(Icons.auto_awesome, size: 44, color: accent),
        const SizedBox(height: 14),
        Text(l10n.askIntro,
            textAlign: TextAlign.center, style: TextStyle(color: context.tbt.textSecondary, height: 1.4)),
        const SizedBox(height: 24),
        for (final q in [l10n.askExample1, l10n.askExample2, l10n.askExample3, l10n.askExample4])
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: PressableScale(
              child: Card(
                child: ListTile(
                  leading: Icon(Icons.chat_bubble_outline, color: accent, size: 20),
                  title: Text(q),
                  onTap: () => onPick(q),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Turn extends ConsumerWidget {
  const _Turn({required this.index, required this.entry, required this.onFollowUp});

  final int index;
  final ChatEntry entry;
  final ValueChanged<String>? onFollowUp;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final accent = Theme.of(context).colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.8),
            margin: const EdgeInsets.only(bottom: 8, top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16).copyWith(bottomRight: const Radius.circular(4)),
            ),
            child: Text(entry.question),
          ),
        ),
        FadeSlideIn(
          child: Card(
            margin: const EdgeInsets.only(bottom: 14),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: switch (entry) {
                ChatEntry(pending: true) => _Thinking(label: l10n.askThinking),
                ChatEntry(:final answer?) => _AnswerBody(
                    index: index, answer: answer, helpful: entry.helpful, onFollowUp: onFollowUp),
                _ => Row(
                    children: [
                      Icon(Icons.error_outline, color: context.tbt.textSecondary),
                      const SizedBox(width: 10),
                      Expanded(child: Text(l10n.askFailed)),
                      TextButton(
                        onPressed: () => ref.read(knowledgeChatProvider.notifier).retry(index),
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _Thinking extends StatelessWidget {
  const _Thinking({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(color: context.tbt.textSecondary)),
          ],
        ),
      );
}

class _AnswerBody extends ConsumerWidget {
  const _AnswerBody({required this.index, required this.answer, required this.helpful, required this.onFollowUp});

  final int index;
  final Answer answer;
  final bool? helpful;
  final ValueChanged<String>? onFollowUp;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final accent = Theme.of(context).colorScheme.primary;
    final sourceByN = {for (final s in answer.sources) s.n: s};
    final provider = switch (answer.provider) {
      'claude' => l10n.askAnsweredBy('Claude${answer.model == null ? '' : ' · ${answer.model}'}'),
      'gemini' => l10n.askAnsweredBy('Gemini${answer.model == null ? '' : ' · ${answer.model}'}'),
      _ => l10n.askNoAi,
    };
    final via = {'keyword': l10n.askViaKeyword, 'semantic': l10n.askViaSemantic, 'graph': l10n.askViaGraph};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CitedText(text: answer.answer, sources: sourceByN, accent: accent),
        if (answer.sources.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(l10n.askSources, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
          const SizedBox(height: 6),
          for (final s in answer.sources)
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => showArticleSheet(context, s.id),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    _Badge(n: s.n, color: accent),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                          if (s.via.isNotEmpty)
                            Text([for (final v in s.via) via[v] ?? v].join(' · '),
                                style: TextStyle(color: context.tbt.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: context.tbt.textSecondary, size: 20),
                  ],
                ),
              ),
            ),
        ],
        if (answer.facts.isNotEmpty)
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(bottom: 8),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              expandedAlignment: Alignment.centerLeft,
              leading: Icon(Icons.hub_outlined, color: accent, size: 20),
              title: Text(l10n.askGraphFacts, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              children: [
                for (final f in answer.facts)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Text.rich(
                      TextSpan(children: [
                        TextSpan(text: f.source, style: const TextStyle(fontWeight: FontWeight.w600)),
                        TextSpan(
                          text: '  ${f.relation}${f.note == null ? '' : ' ${f.note}'} →  ',
                          style: TextStyle(color: accent),
                        ),
                        TextSpan(text: f.target, style: const TextStyle(fontWeight: FontWeight.w600)),
                      ]),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
              ],
            ),
          ),
        if (answer.followUps.isNotEmpty) ...[
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              for (final q in answer.followUps)
                ActionChip(
                  label: Text(q, style: const TextStyle(fontSize: 12)),
                  onPressed: onFollowUp == null ? null : () => onFollowUp!(q),
                ),
            ],
          ),
        ],
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Text(
                answer.cached ? '$provider · ${l10n.askCached}' : provider,
                style: TextStyle(color: context.tbt.textSecondary, fontSize: 11),
              ),
            ),
            if (answer.id != null)
              if (helpful != null)
                Text(l10n.askThanks, style: TextStyle(color: context.tbt.textSecondary, fontSize: 12))
              else ...[
                IconButton(
                  tooltip: l10n.askHelpful,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.thumb_up_alt_outlined, size: 18),
                  onPressed: () => ref.read(knowledgeChatProvider.notifier).rate(index, helpful: true),
                ),
                IconButton(
                  tooltip: l10n.askNotHelpful,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.thumb_down_alt_outlined, size: 18),
                  onPressed: () => ref.read(knowledgeChatProvider.notifier).rate(index, helpful: false),
                ),
              ],
          ],
        ),
      ],
    );
  }
}

/// Câu trả lời; mỗi dấu [n] thành nút số, chạm vào mở bài nguồn
class _CitedText extends StatelessWidget {
  const _CitedText({required this.text, required this.sources, required this.accent});

  final String text;
  final Map<int, AnswerSource> sources;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final spans = <InlineSpan>[];
    var last = 0;
    for (final m in RegExp(r'\s?\[(\d+)\]').allMatches(text)) {
      spans.add(TextSpan(text: text.substring(last, m.start)));
      final source = sources[int.parse(m[1]!)];
      if (source != null) {
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.only(left: 3),
            child: Semantics(
              button: true,
              label: source.title,
              child: InkWell(
                onTap: () => showArticleSheet(context, source.id),
                child: _Badge(n: source.n, color: accent, small: true),
              ),
            ),
          ),
        ));
      }
      last = m.end;
    }
    spans.add(TextSpan(text: text.substring(last)));
    return Text.rich(TextSpan(children: spans), style: const TextStyle(height: 1.5, fontSize: 15));
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.n, required this.color, this.small = false});

  final int n;
  final Color color;
  final bool small;

  @override
  Widget build(BuildContext context) => Container(
        width: small ? 18 : 22,
        height: small ? 18 : 22,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
        child: Text('$n',
            style: TextStyle(color: color, fontSize: small ? 11 : 12, fontWeight: FontWeight.w800)),
      );
}
