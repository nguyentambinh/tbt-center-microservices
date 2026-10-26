/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/error/app_failure.dart';
import '../../core/error/error_reporter.dart';
import '../../core/locale/l10n_names.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/async_states.dart';
import '../../core/widgets/motion.dart';
import '../../l10n/app_localizations.dart';
import '../organization/presentation/pages/org_tree_page.dart' show levelName;
import '../organization/presentation/widgets/org_actions.dart' show showDone;
import 'admin_repository.dart';
import '../../core/widgets/input_rules.dart';

/// Vai trò quản trị một nước được gán; quản trị tập đoàn gán thêm vai trò quản lý
const _regionRoles = ['employee', 'hr', 'finance', 'auditor'];
const _groupRoles = [..._regionRoles, 'executive', 'admin', 'group'];

/// Cơ sở dữ liệu mở trong ô SQL (không có admin_db: nhật ký quản trị không sửa được)
const _databases = ['hr_db', 'attendance_db', 'payroll_db', 'finance_db', 'project_contract_db', 'recruitment_db', 'notification_db', 'currency_db'];

String _bytes(int? b) => switch (b) {
      null => '-',
      < 1024 * 1024 => '${(b / 1024).toStringAsFixed(0)} KB',
      < 1024 * 1024 * 1024 => '${(b / 1024 / 1024).toStringAsFixed(1)} MB',
      _ => '${(b / 1024 / 1024 / 1024).toStringAsFixed(2)} GB',
    };

/// Quản trị dữ liệu: tổng quan, tài khoản, lịch làm việc, chức vụ, SQL và sao lưu
class AdminConsolePage extends StatelessWidget {
  const AdminConsolePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.adminConsole),
          bottom: TabBar(isScrollable: true, tabAlignment: TabAlignment.start, tabs: [
            Tab(text: l10n.adminTabOverview),
            Tab(text: l10n.adminTabAccounts),
            Tab(text: l10n.adminTabCalendar),
            Tab(text: l10n.adminTabPositions),
            Tab(text: l10n.adminTabData),
          ]),
        ),
        body: const TabBarView(children: [_OverviewTab(), _AccountsTab(), _CalendarTab(), _PositionsTab(), _DataTab()]),
      ),
    );
  }
}

class _OverviewTab extends ConsumerWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final overview = ref.watch(adminOverviewProvider);
    return switch (overview) {
      AsyncValue(:final value?) => RefreshIndicator(onRefresh: () => ref.refresh(adminOverviewProvider.future), child: _overview(context, l10n, value)),
      AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(adminOverviewProvider)),
      _ => const SkeletonList(),
    };
  }

  Widget _overview(BuildContext context, AppLocalizations l10n, DataOverview data) {
    final number = NumberFormat.decimalPattern(Localizations.localeOf(context).toString());
    final accent = Theme.of(context).colorScheme.primary;
    final style = TextStyle(fontSize: 10, color: context.tbt.textSecondary);
    final days = <String, int>{};
    for (final db in data.databases) {
      for (final a in db.activity) {
        days[a.day] = (days[a.day] ?? 0) + a.events;
      }
    }
    final dayKeys = days.keys.toList()..sort();
    final available = [for (final db in data.databases) if (db.available) db];
    int rows(DbInfo db) => db.tables.fold(0, (s, t) => s + t.rows);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        if (data.accounts case final accounts?)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l10n.adminAccountsByRole, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(l10n.adminAccountsTotal(accounts['total'] ?? 0), style: TextStyle(color: context.tbt.textSecondary)),
                const SizedBox(height: 8),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final e in accounts.entries)
                    if (e.key != 'total' && e.value > 0) Chip(label: Text('${l10n.roleName(e.key)}: ${e.value}')),
                ]),
              ]),
            ),
          ),
        if (dayKeys.isNotEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l10n.adminActivity, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 160,
                  child: BarChart(BarChartData(
                    gridData: FlGridData(drawVerticalLine: false, getDrawingHorizontalLine: (_) => FlLine(color: context.tbt.glassBorder, strokeWidth: 1)),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(),
                      rightTitles: const AxisTitles(),
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32, getTitlesWidget: (v, _) => Text(number.format(v), style: style))),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true, reservedSize: 22, interval: 2, getTitlesWidget: (v, _) => Text(dayKeys[v.toInt()].substring(8), style: style)),
                      ),
                    ),
                    barGroups: [
                      for (final (i, d) in dayKeys.indexed)
                        BarChartGroupData(x: i, barRods: [BarChartRodData(toY: days[d]!.toDouble(), width: 10, color: accent, borderRadius: const BorderRadius.vertical(top: Radius.circular(2)))]),
                    ],
                  )),
                ),
              ]),
            ),
          ),
        if (available.isNotEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l10n.adminRowsByDb, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                for (final db in available) ...[
                  Row(children: [
                    SizedBox(width: 130, child: Text(db.name.replaceAll('_db', ''), style: style.copyWith(fontSize: 12), overflow: TextOverflow.ellipsis)),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: rows(db) / available.map(rows).fold(1, (a, b) => a > b ? a : b),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(number.format(rows(db)), style: style.copyWith(fontSize: 12)),
                  ]),
                  const SizedBox(height: 8),
                ],
              ]),
            ),
          ),
        const SizedBox(height: 4),
        Text(l10n.adminDatabases, style: const TextStyle(fontWeight: FontWeight.bold)),
        for (final db in data.databases)
          Card(
            child: ListTile(
              leading: Icon(db.available ? Icons.storage_outlined : Icons.error_outline),
              title: Text(db.name),
              subtitle: Text(db.available ? l10n.adminDbLine(db.tables.length, number.format(rows(db)), _bytes(db.sizeBytes)) : l10n.adminDbUnavailable),
              trailing: db.available ? const Icon(Icons.chevron_right) : null,
              onTap: db.available ? () => _showTables(context, db, number) : null,
            ),
          ),
      ],
    );
  }

  void _showTables(BuildContext context, DbInfo db, NumberFormat number) => showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (context) => DraggableScrollableSheet(
          expand: false,
          builder: (context, scroll) => ListView(
            controller: scroll,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            children: [
              Text(db.name, style: Theme.of(context).textTheme.titleLarge),
              for (final t in [...db.tables]..sort((a, b) => b.rows.compareTo(a.rows)))
                ListTile(dense: true, title: Text(t.name), trailing: Text(number.format(t.rows))),
            ],
          ),
        ),
      );
}

class _AccountsTab extends ConsumerStatefulWidget {
  const _AccountsTab();

  @override
  ConsumerState<_AccountsTab> createState() => _AccountsTabState();
}

class _AccountsTabState extends ConsumerState<_AccountsTab> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final users = ref.watch(adminUsersProvider(_query));
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: TextField(
          inputFormatters: InputRules.search,
          decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: l10n.adminSearchAccounts, isDense: true),
          onSubmitted: (v) => setState(() => _query = v.trim()),
        ),
      ),
      Expanded(
        child: switch (users) {
          AsyncValue(:final value?) => ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
              children: [
                for (final u in value)
                  Card(
                    child: ListTile(
                      leading: Icon(u.enabled ? Icons.person_outline : Icons.person_off_outlined, color: u.enabled ? null : context.tbt.danger),
                      title: Text(u.name.isEmpty ? u.username : '${u.name} · ${u.username}', overflow: TextOverflow.ellipsis),
                      subtitle: Text(
                        [if (!u.enabled) l10n.adminAccountDisabled, ...u.roles.map(l10n.roleName), ?u.email].join(' · '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.edit_outlined),
                      onTap: () => _edit(u),
                    ),
                  ),
              ],
            ),
          AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(adminUsersProvider(_query))),
          _ => const SkeletonList(),
        },
      ),
    ]);
  }

  Future<void> _edit(AdminUser user) async {
    final l10n = AppLocalizations.of(context);
    final group = ref.read(authControllerProvider).value?.isGroup ?? false;
    final assignable = group ? _groupRoles : _regionRoles;
    final roles = {...user.roles};
    var enabled = user.enabled;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.adminEditAccount(user.username)),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              SwitchListTile(contentPadding: EdgeInsets.zero, title: Text(l10n.adminAccountEnabled), value: enabled, onChanged: (v) => setState(() => enabled = v)),
              Text(l10n.adminRoles, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final r in assignable)
                  FilterChip(
                    label: Text(r == 'group' ? l10n.roleGroup : l10n.roleName(r)),
                    selected: roles.contains(r),
                    onSelected: (on) => setState(() => on ? roles.add(r) : roles.remove(r)),
                  ),
              ]),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.save)),
          ],
        ),
      ),
    );
    if (ok != true) return;
    final add = {for (final r in roles) if (!user.roles.contains(r)) r};
    final remove = {for (final r in user.roles) if (assignable.contains(r) && !roles.contains(r)) r};
    try {
      await ref.read(adminRepositoryProvider).updateUser(user.id, enabled: enabled == user.enabled ? null : enabled, add: add, remove: remove);
      ref.invalidate(adminUsersProvider(_query));
      showDone(l10n.adminSaved);
    } on Object catch (e) {
      reportFailure(e);
    }
  }
}

class _CalendarTab extends ConsumerStatefulWidget {
  const _CalendarTab();

  @override
  ConsumerState<_CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends ConsumerState<_CalendarTab> {
  int _year = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final holidays = ref.watch(adminHolidaysProvider(_year));
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.schedule),
            title: Text(l10n.adminShift, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(l10n.adminShiftHint),
            trailing: FilledButton.tonal(onPressed: _shift, child: Text(l10n.adminShiftChange)),
            isThreeLine: true,
          ),
        ),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: Text(l10n.adminHolidays, style: const TextStyle(fontWeight: FontWeight.bold))),
          IconButton(onPressed: () => setState(() => _year--), icon: const Icon(Icons.chevron_left)),
          Text('$_year'),
          IconButton(onPressed: () => setState(() => _year++), icon: const Icon(Icons.chevron_right)),
          FilledButton.icon(onPressed: _add, icon: const Icon(Icons.add), label: Text(l10n.adminAddHoliday)),
        ]),
        switch (holidays) {
          AsyncValue(:final value?) when value.isEmpty => Padding(padding: const EdgeInsets.all(24), child: Text(l10n.adminNoHolidays, textAlign: TextAlign.center)),
          AsyncValue(:final value?) => Card(
              child: Column(children: [
                for (final h in value)
                  ListTile(
                    leading: const Icon(Icons.celebration_outlined),
                    title: Text(h.name),
                    subtitle: Text(DateFormat.yMMMMEEEEd(locale).format(h.date)),
                    trailing: IconButton(icon: Icon(Icons.delete_outline, color: context.tbt.danger), onPressed: () => _remove(h)),
                  ),
              ]),
            ),
          AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(adminHolidaysProvider(_year))),
          _ => const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator())),
        },
      ],
    );
  }

  Future<void> _add() async {
    final l10n = AppLocalizations.of(context);
    final date = await showDatePicker(context: context, firstDate: DateTime(_year), lastDate: DateTime(_year, 12, 31), initialDate: DateTime(_year, DateTime.now().month, DateTime.now().day));
    if (date == null || !mounted) return;
    final name = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.adminAddHoliday),
        content: TextField(inputFormatters: InputRules.shortText, controller: name, autofocus: true, decoration: InputDecoration(labelText: l10n.adminHolidayName)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          FilledButton(onPressed: () => Navigator.pop(context, name.text.trim().isNotEmpty), child: Text(l10n.save)),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(adminRepositoryProvider).addHoliday(date, name.text.trim());
      ref.invalidate(adminHolidaysProvider(_year));
      showDone(l10n.adminSaved);
    } on Object catch (e) {
      reportFailure(e);
    }
  }

  Future<void> _remove(Holiday h) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.adminHolidayRemove(h.name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.adminRemove)),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(adminRepositoryProvider).removeHoliday(h.date);
      ref.invalidate(adminHolidaysProvider(_year));
      showDone(l10n.adminSaved);
    } on Object catch (e) {
      reportFailure(e);
    }
  }

  Future<void> _shift() async {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final range = await showDateRangePicker(context: context, firstDate: DateTime(now.year, now.month, now.day), lastDate: DateTime(now.year + 1, 12, 31), helpText: l10n.adminShiftRange);
    if (range == null || !mounted) return;
    final start = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 8, minute: 0), helpText: l10n.adminShiftStart);
    if (start == null || !mounted) return;
    final end = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 17, minute: 0), helpText: l10n.adminShiftEnd);
    if (end == null) return;
    String hm(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    try {
      final changed = await ref.read(adminRepositoryProvider).setShift(from: range.start, to: range.end, start: hm(start), end: hm(end));
      showDone(l10n.adminShiftDone(changed));
    } on Object catch (e) {
      reportFailure(e);
    }
  }
}

class _PositionsTab extends ConsumerWidget {
  const _PositionsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final positions = ref.watch(adminPositionsProvider);
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(heroTag: 'admin-position', onPressed: () => _edit(context, ref, null), icon: const Icon(Icons.add), label: Text(l10n.adminAddPosition)),
      body: switch (positions) {
        AsyncValue(:final value?) => ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
            children: [
              for (final p in value)
                Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${p.level}')),
                    title: Text(p.name),
                    subtitle: Text('${levelName(l10n, p.level)} · ${l10n.adminCoefficient} ${p.coefficient} · ${l10n.adminHolders(p.holders)}'),
                    trailing: const Icon(Icons.edit_outlined),
                    onTap: () => _edit(context, ref, p),
                  ),
                ),
            ],
          ),
        AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(adminPositionsProvider)),
        _ => const SkeletonList(),
      },
    );
  }

  Future<void> _edit(BuildContext context, WidgetRef ref, PositionItem? position) async {
    final l10n = AppLocalizations.of(context);
    final name = TextEditingController(text: position?.name);
    final coefficient = TextEditingController(text: '${position?.coefficient ?? 1}');
    var level = position?.level ?? 1;
    final action = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(position == null ? l10n.adminAddPosition : l10n.adminEditPosition),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(inputFormatters: InputRules.shortText, controller: name, decoration: InputDecoration(labelText: l10n.adminPositionName)),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: level,
                decoration: InputDecoration(labelText: l10n.adminPositionLevel),
                items: [for (var lv = 1; lv <= 6; lv++) DropdownMenuItem(value: lv, child: Text('$lv · ${levelName(l10n, lv)}'))],
                onChanged: (v) => setState(() => level = v ?? level),
              ),
              const SizedBox(height: 12),
              TextField(
                inputFormatters: InputRules.decimal,
                controller: coefficient,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: l10n.adminCoefficient),
              ),
            ]),
          ),
          actions: [
            if (position != null && position.holders == 0)
              TextButton(onPressed: () => Navigator.pop(context, 'delete'), child: Text(l10n.adminDeletePosition, style: TextStyle(color: context.tbt.danger))),
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
            FilledButton(onPressed: () => Navigator.pop(context, 'save'), child: Text(l10n.save)),
          ],
        ),
      ),
    );
    if (action == null) return;
    final repository = ref.read(adminRepositoryProvider);
    try {
      if (action == 'delete') {
        await repository.deletePosition(position!.id);
      } else {
        await repository.savePosition(
          id: position?.id,
          name: name.text.trim(),
          level: level,
          coefficient: double.tryParse(coefficient.text.replaceAll(',', '.')) ?? 1,
        );
      }
      ref.invalidate(adminPositionsProvider);
      showDone(l10n.adminSaved);
    } on Object catch (e) {
      reportFailure(e);
    }
  }
}

class _DataTab extends ConsumerStatefulWidget {
  const _DataTab();

  @override
  ConsumerState<_DataTab> createState() => _DataTabState();
}

class _DataTabState extends ConsumerState<_DataTab> {
  final _sql = TextEditingController(text: 'select * from employees limit 20');
  String _database = _databases.first;
  bool _write = false;
  bool _running = false;
  bool _backingUp = false;
  SqlResult? _result;
  AppFailure? _failure;

  @override
  void dispose() {
    _sql.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    final l10n = AppLocalizations.of(context);
    if (_write) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          content: Text(l10n.adminSqlWriteConfirm),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.adminSqlRun)),
          ],
        ),
      );
      if (ok != true) return;
    }
    setState(() {
      _running = true;
      _failure = null;
    });
    try {
      final result = await ref.read(adminRepositoryProvider).runSql(_database, _sql.text, write: _write);
      if (mounted) setState(() => _result = result);
    } on AppFailure catch (e) {
      if (mounted) setState(() => _failure = e);
    } on Object catch (e) {
      reportFailure(e);
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  Future<void> _backup() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _backingUp = true);
    try {
      await ref.read(adminRepositoryProvider).createBackup();
      ref.invalidate(adminBackupsProvider);
      showDone(l10n.adminBackupDone);
    } on Object catch (e) {
      reportFailure(e);
    } finally {
      if (mounted) setState(() => _backingUp = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final backups = ref.watch(adminBackupsProvider);
    final mono = TextStyle(fontFamily: 'monospace', fontSize: 13, color: context.tbt.textMain);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text(l10n.adminSql, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(l10n.adminSqlHint, style: TextStyle(fontSize: 12, color: context.tbt.textSecondary)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _database,
                decoration: InputDecoration(labelText: l10n.adminDatabases, isDense: true),
                items: [for (final d in _databases) DropdownMenuItem(value: d, child: Text(d))],
                onChanged: (v) => setState(() => _database = v ?? _database),
              ),
              const SizedBox(height: 12),
              TextField(inputFormatters: InputRules.sql, key: const Key('admin-sql'), controller: _sql, minLines: 3, maxLines: 8, style: mono, decoration: const InputDecoration(alignLabelWithHint: true)),
              SwitchListTile(contentPadding: EdgeInsets.zero, title: Text(l10n.adminSqlWrite), value: _write, onChanged: (v) => setState(() => _write = v)),
              FilledButton.icon(
                onPressed: _running ? null : _run,
                icon: _running ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.play_arrow),
                label: Text(l10n.adminSqlRun),
              ),
              if (_failure case final f?) ...[
                const SizedBox(height: 12),
                Text(f.message(l10n), style: TextStyle(color: context.tbt.danger)),
                if (f.serverMessage case final detail?)
                  ExpansionTile(tilePadding: EdgeInsets.zero, title: Text(l10n.adminTechnical, style: const TextStyle(fontSize: 13)), children: [SelectableText(detail, style: mono)]),
              ],
              if (_result case final r? when _failure == null) ...[
                const SizedBox(height: 12),
                Text(r.columns.isEmpty ? l10n.adminSqlAffected(r.affected) : l10n.adminSqlRows(r.rows.length), style: const TextStyle(fontWeight: FontWeight.bold)),
                if (r.truncated) Text(l10n.adminSqlTruncated, style: TextStyle(fontSize: 12, color: context.tbt.caution)),
                if (r.columns.isNotEmpty)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowHeight: 36,
                      dataRowMinHeight: 32,
                      dataRowMaxHeight: 48,
                      columns: [for (final c in r.columns) DataColumn(label: Text(c, style: mono.copyWith(fontWeight: FontWeight.bold)))],
                      rows: [
                        for (final row in r.rows)
                          DataRow(cells: [
                            for (final v in row)
                              DataCell(ConstrainedBox(constraints: const BoxConstraints(maxWidth: 260), child: Text('${v ?? 'null'}', style: mono, overflow: TextOverflow.ellipsis))),
                          ]),
                      ],
                    ),
                  ),
              ],
            ]),
          ),
        ),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: Text(l10n.adminBackups, style: const TextStyle(fontWeight: FontWeight.bold))),
          FilledButton.icon(
            onPressed: _backingUp ? null : _backup,
            icon: _backingUp ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.backup_outlined),
            label: Text(l10n.adminBackupNow),
          ),
        ]),
        switch (backups) {
          AsyncValue(:final value?) when value.isEmpty => Padding(padding: const EdgeInsets.all(24), child: Text(l10n.adminBackupNone, textAlign: TextAlign.center)),
          AsyncValue(:final value?) => Card(
              child: Column(children: [
                for (final b in value)
                  ListTile(
                    leading: const Icon(Icons.inventory_2_outlined),
                    title: Text(DateFormat.yMMMd(locale).add_Hm().format(b.createdAt.toLocal())),
                    subtitle: Text('${b.name} · ${_bytes(b.sizeBytes)}'),
                    trailing: IconButton(
                      tooltip: l10n.adminDownload,
                      icon: const Icon(Icons.download_outlined),
                      onPressed: b.downloadUrl.isEmpty ? null : () => launchUrl(Uri.parse(b.downloadUrl), mode: LaunchMode.externalApplication),
                    ),
                  ),
              ]),
            ),
          AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(adminBackupsProvider)),
          _ => const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator())),
        },
      ],
    );
  }
}
