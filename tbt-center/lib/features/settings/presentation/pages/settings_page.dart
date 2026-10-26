/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/auth_controller.dart';
import '../../../../core/locale/l10n_names.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/locale/locale_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_mode.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../../core/widgets/input_rules.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final chosen = ref.watch(languageControllerProvider);
    final geo = ref.watch(geoProvider);
    final mode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      // Mở từ màn đăng nhập thì chưa có thanh điều hướng
      bottomNavigationBar: ref.watch(authControllerProvider).value == null ? null : const TbtBottomNav(current: Routes.settings),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(l10n.language, style: text.titleLarge),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                _LanguageTile(label: l10n.languageAuto, selected: chosen == null, onTap: () => _choose(ref, null)),
                for (final code in supportedLanguages)
                  _LanguageTile(
                    label: LocalizedNames.languageNames[code]!,
                    selected: chosen == code,
                    onTap: () => _choose(ref, code),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(l10n.appearance, style: text.titleLarge),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                for (final (value, label) in [
                  (ThemeMode.system, l10n.themeSystem),
                  (ThemeMode.light, l10n.themeLight),
                  (ThemeMode.dark, l10n.themeDark),
                ])
                  _LanguageTile(
                    label: label,
                    selected: mode == value,
                    onTap: () => ref.read(themeModeProvider.notifier).choose(value),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(l10n.dataRegion, style: text.titleLarge),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: Icon(Icons.public, color: context.tbt.brandGold),
              title: geo.when(
                loading: () => Text(l10n.detecting),
                error: (_, _) => Text(l10n.locationUnknown),
                data: (result) => Text(result == null ? l10n.locationUnknown : l10n.regionName(result.region)),
              ),
              subtitle: switch (geo.value) {
                final result? when result.country != null => Text(
                    '${l10n.detectedCountry(result.country!)}${result.ip == null ? '' : '  ·  ${result.ip}'}'),
                _ => null,
              },
              trailing: IconButton(
                tooltip: l10n.refreshLocation,
                icon: const Icon(Icons.refresh),
                onPressed: () => ref.invalidate(geoProvider),
              ),
            ),
          ),
          if (kDebugMode) ...[
            const SizedBox(height: 24),
            const _SimulationCard(),
            if (ref.watch(authControllerProvider).value case final session?) ...[
              const SizedBox(height: 16),
              RegionCheckCard(session: session),
            ],
          ],
        ],
      ),
    );
  }

  void _choose(WidgetRef ref, String? language) => ref.read(languageControllerProvider.notifier).choose(language);
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return ListTile(
      title: Text(label, style: selected ? TextStyle(color: color, fontWeight: FontWeight.w600) : null),
      trailing: selected ? Icon(Icons.check, color: color) : null,
      onTap: onTap,
    );
  }
}

class _SimulationCard extends ConsumerStatefulWidget {
  const _SimulationCard();

  @override
  ConsumerState<_SimulationCard> createState() => _SimulationCardState();
}

class _SimulationCardState extends ConsumerState<_SimulationCard> {
  late final _ip = TextEditingController(text: ref.read(locationSimulatorProvider).ip);
  late final _country = TextEditingController(text: ref.read(locationSimulatorProvider).country);

  @override
  void dispose() {
    _ip.dispose();
    _country.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final simulator = ref.read(locationSimulatorProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.simulateLocation, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(l10n.simulateHint, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            TextField(inputFormatters: InputRules.ip, controller: _ip, decoration: InputDecoration(labelText: l10n.simulateIp)),
            const SizedBox(height: 8),
            TextField(
              inputFormatters: InputRules.country,
              controller: _country,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(labelText: l10n.simulateCountry),
            ),
            Row(
              children: [
                FilledButton(
                  onPressed: () => simulator.simulate(ip: _ip.text.trim(), country: _country.text.trim()),
                  child: Text(l10n.apply),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () {
                    _ip.clear();
                    _country.clear();
                    simulator.clear();
                  },
                  child: Text(l10n.clearSimulation),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
