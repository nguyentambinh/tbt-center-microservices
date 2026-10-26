/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Một lựa chọn trong bộ lọc: giá trị và chữ hiển thị
typedef FilterOption<T> = ({T value, String label});

/// Bộ lọc dạng spinner (ô thả xuống), mục đầu là "Tất cả" ứng với null
class FilterSpinner<T> extends StatelessWidget {
  const FilterSpinner({super.key, required this.label, required this.options, required this.value, required this.onChanged, this.width = 170});

  final String label;
  final List<FilterOption<T>> options;
  final T? value;
  final ValueChanged<T?> onChanged;
  final double width;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final active = value != null && options.any((o) => o.value == value);
    return SizedBox(
      width: width,
      child: DropdownButtonFormField<T?>(
        initialValue: active ? value : null,
        isExpanded: true,
        isDense: true,
        decoration: InputDecoration(
          labelText: label,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          prefixIcon: active ? Icon(Icons.filter_alt, size: 18, color: Theme.of(context).colorScheme.primary) : null,
          prefixIconConstraints: const BoxConstraints(minWidth: 32),
        ),
        items: [
          DropdownMenuItem<T?>(child: Text(l10n.filterAll, overflow: TextOverflow.ellipsis)),
          for (final o in options) DropdownMenuItem<T?>(value: o.value, child: Text(o.label, overflow: TextOverflow.ellipsis)),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

/// Hàng bộ lọc cuộn ngang đặt trên danh sách
class FilterBar extends StatelessWidget {
  const FilterBar({super.key, required this.children, this.padding = const EdgeInsets.fromLTRB(16, 14, 16, 8)});

  final List<Widget> children;
  final EdgeInsets padding;

  // Nhãn nổi của ô lọc nằm trên viền: chừa lề trên và không cắt theo khung cuộn
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: padding,
        child: Row(children: [for (final (i, c) in children.indexed) Padding(padding: EdgeInsets.only(left: i == 0 ? 0 : 8), child: c)]),
      );
}
