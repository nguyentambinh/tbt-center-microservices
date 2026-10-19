/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-18
 */

import 'package:meta/meta.dart';

/// Một cạnh dạng bộ ba: chủ thể, quan hệ, đối tượng
@immutable
class Triple {
  const Triple(this.source, this.relation, this.target);

  factory Triple.fromJson(List<dynamic> j) =>
      Triple(j[0] as String, j[1] as String, j[2] as String);

  final String source;
  final String relation;
  final String target;

  List<String> toJson() => [source, relation, target];

  @override
  bool operator ==(Object other) =>
      other is Triple &&
      other.source == source &&
      other.relation == relation &&
      other.target == target;

  @override
  int get hashCode => Object.hash(source, relation, target);

  @override
  String toString() => '($source $relation $target)';
}

class KgClass {
  const KgClass(this.id, this.parent, this.labels);

  final String id;
  final String? parent;
  final Map<String, String> labels;
}

class KgRelation {
  const KgRelation({
    required this.id,
    required this.labels,
    required this.domain,
    required this.range,
    this.summaries = const {},
    this.transitive = false,
    this.symmetric = false,
    this.inverseOf,
    this.subPropertyOf,
    this.derived = false,
  });

  final String id;
  final Map<String, String> labels;
  final Map<String, String> summaries;
  final List<String> domain;
  final List<String> range;
  final bool transitive;
  final bool symmetric;
  final String? inverseOf;
  final String? subPropertyOf;

  /// Chỉ do suy luận sinh ra, người và AI không ghi trực tiếp
  final bool derived;
}

enum RuleKind { transitive, symmetric, inverse, subproperty, chain }

/// Luật suy luận; [second] bắt đầu bằng ^ là đi ngược cạnh
class KgRule {
  const KgRule({
    required this.id,
    required this.kind,
    required this.first,
    required this.result,
    this.second,
    this.visible = true,
    this.labels = const {},
  });

  final String id;
  final RuleKind kind;
  final String first;
  final String? second;
  final String result;
  final bool visible;
  final Map<String, String> labels;
}

/// Bản thể học: cây lớp, quan hệ kèm miền và phạm vi, luật suy luận
class Ontology {
  Ontology({
    required List<KgClass> classes,
    required List<KgRelation> relations,
    this.rules = const [],
  }) : classes = {for (final c in classes) c.id: c},
       relations = {for (final r in relations) r.id: r};

  final Map<String, KgClass> classes;
  final Map<String, KgRelation> relations;
  final List<KgRule> rules;

  /// Lớp [id] và mọi lớp cha của nó, gần nhất trước
  List<String> ancestors(String id) {
    final out = <String>[];
    String? c = id;
    while (c != null && classes.containsKey(c) && !out.contains(c)) {
      out.add(c);
      c = classes[c]!.parent;
    }
    return out;
  }

  bool isA(String cls, String ancestor) => ancestors(cls).contains(ancestor);

  bool conforms(String cls, List<String> allowed) =>
      allowed.any((a) => isA(cls, a));

  /// Lý do cạnh không hợp lệ, null là hợp lệ
  String? violation(Triple t, String? Function(String node) classOf) {
    final rel = relations[t.relation];
    if (rel == null) return 'unknown_relation';
    final s = classOf(t.source);
    final o = classOf(t.target);
    if (s == null) return 'unknown_source';
    if (o == null) return 'unknown_target';
    if (t.source == t.target) return 'self_loop';
    if (!conforms(s, rel.domain)) return 'domain:$s';
    if (!conforms(o, rel.range)) return 'range:$o';
    return null;
  }
}
