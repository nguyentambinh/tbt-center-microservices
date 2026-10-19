/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-18
 */

import 'package:knowledge_service/src/graph/rdf.dart';

/// Tập con SPARQL 1.1: SELECT (DISTINCT, *, COUNT), mẫu bộ ba, đường thuộc tính
/// (/, |, ^, *, +, ?), FILTER, OPTIONAL, UNION, GROUP BY, ORDER BY, LIMIT, OFFSET
class SparqlError implements Exception {
  const SparqlError(this.message);

  final String message;

  @override
  String toString() => 'SparqlError: $message';
}

class SparqlResult {
  const SparqlResult(this.vars, this.rows, {this.truncated = false});

  final List<String> vars;
  final List<Map<String, Term>> rows;
  final bool truncated;
}

/// Kho bộ ba có chỉ mục để tìm nhanh theo chủ thể, quan hệ, đối tượng
class TripleStore {
  TripleStore(Iterable<(Term, Iri, Term)> triples) {
    for (final (s, p, o) in triples) {
      if (!((_spo[s] ??= {})[p] ??= {}).add(o)) continue;
      ((_pos[p] ??= {})[o] ??= {}).add(s);
      _all.add((s, p, o));
      _nodes
        ..add(s)
        ..add(o);
    }
  }

  final _spo = <Term, Map<Iri, Set<Term>>>{};
  final _pos = <Iri, Map<Term, Set<Term>>>{};
  final _all = <(Term, Iri, Term)>[];
  final _nodes = <Term>{};

  int get length => _all.length;

  Iterable<(Term, Term)> pairs(Iri p, Term? s, Term? o) sync* {
    if (s != null) {
      final objects = _spo[s]?[p] ?? const <Term>{};
      if (o != null) {
        if (objects.contains(o)) yield (s, o);
      } else {
        for (final x in objects) {
          yield (s, x);
        }
      }
    } else if (o != null) {
      for (final x in _pos[p]?[o] ?? const <Term>{}) {
        yield (x, o);
      }
    } else {
      for (final e in (_pos[p] ?? const <Term, Set<Term>>{}).entries) {
        for (final x in e.value) {
          yield (x, e.key);
        }
      }
    }
  }

  Iterable<(Term, Iri, Term)> match(Term? s, Iri? p, Term? o) sync* {
    if (p != null) {
      for (final (a, b) in pairs(p, s, o)) {
        yield (a, p, b);
      }
      return;
    }
    if (s != null) {
      for (final e in (_spo[s] ?? const <Iri, Set<Term>>{}).entries) {
        for (final x in e.value) {
          if (o == null || x == o) yield (s, e.key, x);
        }
      }
      return;
    }
    for (final t in _all) {
      if (o == null || t.$3 == o) yield t;
    }
  }

  Iterable<Term> get nodes => _nodes;
}

class SparqlEngine {
  SparqlEngine(this.store, {this.maxSolutions = 20000, this.maxRows = 500});

  final TripleStore store;
  final int maxSolutions;
  final int maxRows;

  SparqlResult query(String text) {
    final q = _Parser(_tokenize(text)).parseQuery();
    var solutions = _evalGroup(q.where, [<String, Term>{}]);
    if (q.aggregates.isNotEmpty || q.groupBy.isNotEmpty) {
      solutions = _aggregate(q, solutions);
    }
    if (q.orderBy.isNotEmpty) {
      solutions.sort((a, b) {
        for (final (key, desc) in q.orderBy) {
          final c = _compareTerms(a[key], b[key]);
          if (c != 0) return desc ? -c : c;
        }
        return 0;
      });
    }
    final vars = q.vars.isEmpty
        ? ({for (final s in solutions) ...s.keys}.toList()..sort())
        : q.vars;
    var rows = [
      for (final s in solutions)
        {
          for (final v in vars)
            if (s[v] case final t?) v: t,
        },
    ];
    if (q.distinct) {
      final seen = <String>{};
      rows = [
        for (final r in rows)
          if (seen.add([for (final v in vars) '${r[v]}'].join('\u0000'))) r,
      ];
    }
    rows = rows.skip(q.offset).toList();
    final limit = q.limit == null || q.limit! > maxRows ? maxRows : q.limit!;
    return SparqlResult(
      vars,
      rows.take(limit).toList(),
      truncated: rows.length > limit && (q.limit == null || q.limit! > maxRows),
    );
  }

  List<Map<String, Term>> _evalGroup(
    _Group g,
    List<Map<String, Term>> input,
  ) {
    var sols = input;
    final pending = [...g.triples];
    // Mẫu có nhiều vị trí đã biết làm trước để tập kết quả nhỏ
    while (pending.isNotEmpty && sols.isNotEmpty) {
      final known = sols.isEmpty ? <String>{} : sols.first.keys.toSet();
      pending.sort(
        (a, b) => b.boundCount(known).compareTo(a.boundCount(known)),
      );
      sols = _join(sols, pending.removeAt(0));
    }
    for (final part in g.parts) {
      switch (part) {
        case _SubGroup(:final group):
          sols = _evalGroup(group, sols);
        case _Optional(:final group):
          final out = <Map<String, Term>>[];
          for (final s in sols) {
            final extended = _evalGroup(group, [s]);
            out.addAll(extended.isEmpty ? [s] : extended);
          }
          sols = out;
        case _Union(:final branches):
          sols = [for (final b in branches) ..._evalGroup(b, sols)];
      }
      _check(sols);
    }
    for (final f in g.filters) {
      sols = [
        for (final s in sols)
          if (_truthy(_eval(f, s))) s,
      ];
    }
    return sols;
  }

  List<Map<String, Term>> _join(List<Map<String, Term>> sols, _Pattern p) {
    final out = <Map<String, Term>>[];
    for (final sol in sols) {
      final s = p.subject.resolve(sol);
      final o = p.object.resolve(sol);
      final verb = p.verb;
      if (verb is _VarNode) {
        final bound = sol[verb.name];
        if (bound != null && bound is! Iri) continue;
        for (final (a, pred, b) in store.match(s, bound as Iri?, o)) {
          final next = _bind(sol, [
            (p.subject, a),
            (verb, pred),
            (p.object, b),
          ]);
          if (next != null) out.add(next);
        }
      } else {
        for (final (a, b) in _path((verb as _PathVerb).path, s, o)) {
          final next = _bind(sol, [(p.subject, a), (p.object, b)]);
          if (next != null) out.add(next);
        }
      }
      _check(out);
    }
    return out;
  }

  Map<String, Term>? _bind(
    Map<String, Term> sol,
    List<(_Node, Term)> pairs,
  ) {
    final next = {...sol};
    for (final (node, value) in pairs) {
      if (node is _VarNode) {
        final had = next[node.name];
        if (had != null && had != value) return null;
        next[node.name] = value;
      }
    }
    return next;
  }

  void _check(List<Object> list) {
    if (list.length > maxSolutions) {
      throw const SparqlError('query_too_big');
    }
  }

  Iterable<(Term, Term)> _path(_Path path, Term? s, Term? o) {
    switch (path) {
      case _PathIri(:final iri):
        return store.pairs(iri, s, o);
      case _PathInverse(:final inner):
        return _path(inner, o, s).map((p) => (p.$2, p.$1));
      case _PathAlt(:final options):
        return {for (final x in options) ..._path(x, s, o)};
      case _PathSeq(:final items):
        return _seq(items, s, o).toSet();
      case _PathMod(:final inner, :final mod):
        return _closure(inner, mod, s, o);
    }
  }

  Iterable<(Term, Term)> _seq(List<_Path> items, Term? s, Term? o) sync* {
    if (items.length == 1) {
      yield* _path(items.first, s, o);
      return;
    }
    for (final (a, mid) in _path(items.first, s, null)) {
      for (final (_, b) in _seq(items.sublist(1), mid, o)) {
        yield (a, b);
      }
    }
  }

  Set<(Term, Term)> _closure(_Path inner, String mod, Term? s, Term? o) {
    final out = <(Term, Term)>{};
    Set<Term> reach(Term start, {required bool forward}) {
      final seen = <Term>{};
      var frontier = {start};
      var depth = 0;
      while (frontier.isNotEmpty && (mod != '?' || depth < 1)) {
        depth++;
        final next = <Term>{};
        for (final x in frontier) {
          final step = forward ? _path(inner, x, null) : _path(inner, null, x);
          for (final (a, b) in step) {
            final y = forward ? b : a;
            if (seen.add(y)) next.add(y);
          }
        }
        frontier = next;
      }
      if (mod != '+') seen.add(start);
      return seen;
    }

    if (s != null) {
      for (final y in reach(s, forward: true)) {
        if (o == null || y == o) out.add((s, y));
      }
    } else if (o != null) {
      for (final x in reach(o, forward: false)) {
        out.add((x, o));
      }
    } else {
      for (final n in store.nodes) {
        for (final y in reach(n, forward: true)) {
          out.add((n, y));
        }
        if (out.length > maxSolutions) throw const SparqlError('query_too_big');
      }
    }
    return out;
  }

  List<Map<String, Term>> _aggregate(
    _Query q,
    List<Map<String, Term>> sols,
  ) {
    final groups = <String, List<Map<String, Term>>>{};
    for (final s in sols) {
      final key = [for (final v in q.groupBy) '${s[v]}'].join('\u0000');
      (groups[key] ??= []).add(s);
    }
    if (groups.isEmpty && q.groupBy.isEmpty) groups[''] = [];
    return [
      for (final g in groups.values)
        {
          for (final v in q.groupBy)
            if (g.first[v] case final t?) v: t,
          for (final a in q.aggregates) a.alias: Lit('${_count(g, a)}'),
        },
    ];
  }

  static int _count(List<Map<String, Term>> group, _Aggregate a) {
    final v = a.variable;
    final rows = v == null ? group : group.where((s) => s[v] != null);
    if (!a.distinct) return rows.length;
    return {
      for (final s in rows)
        if (v == null) '$s' else '${s[v]}',
    }.length;
  }

  Object? _eval(_Expr e, Map<String, Term> s) {
    switch (e) {
      case _Const(:final value):
        return value;
      case _VarRef(:final name):
        return s[name];
      case _Not(:final inner):
        return !_truthy(_eval(inner, s));
      case _Logic(:final and, :final left, :final right):
        return and
            ? _truthy(_eval(left, s)) && _truthy(_eval(right, s))
            : _truthy(_eval(left, s)) || _truthy(_eval(right, s));
      case _Compare(:final op, :final left, :final right):
        final a = _eval(left, s);
        final b = _eval(right, s);
        if (a == null || b == null) return false;
        if (op == '=' || op == '!=') {
          final same = a is Term && b is Term ? a == b : _str(a) == _str(b);
          return op == '=' ? same : !same;
        }
        final c = _compareValues(a, b);
        return switch (op) {
          '<' => c < 0,
          '>' => c > 0,
          '<=' => c <= 0,
          _ => c >= 0,
        };
      case _Call(:final name, :final args):
        final v = [for (final a in args) _eval(a, s)];
        String arg(int i) => _str(v[i]);
        return switch (name) {
          'BOUND' =>
            args.first is _VarRef &&
                s.containsKey((args.first as _VarRef).name),
          'STR' => arg(0),
          'LCASE' => arg(0).toLowerCase(),
          'UCASE' => arg(0).toUpperCase(),
          'LANG' => v[0] is Lit ? ((v[0]! as Lit).lang ?? '') : '',
          'CONTAINS' => arg(0).contains(arg(1)),
          'STRSTARTS' => arg(0).startsWith(arg(1)),
          'STRENDS' => arg(0).endsWith(arg(1)),
          'ISIRI' || 'ISURI' => v[0] is Iri,
          'ISLITERAL' => v[0] is Lit,
          'REGEX' => _regex(arg(0), arg(1), args.length > 2 ? arg(2) : ''),
          _ => throw SparqlError('unknown_function:$name'),
        };
    }
  }

  static bool _regex(String text, String pattern, String flags) {
    try {
      return RegExp(
        pattern,
        caseSensitive: !flags.contains('i'),
      ).hasMatch(text);
    } on FormatException {
      throw const SparqlError('bad_regex');
    }
  }

  static String _str(Object? v) => switch (v) {
    Iri(:final value) => value,
    Lit(:final value) => value,
    null => '',
    _ => '$v',
  };

  static bool _truthy(Object? v) => switch (v) {
    final bool b => b,
    final num n => n != 0,
    final String s => s.isNotEmpty,
    Lit(:final value) => value.isNotEmpty && value != 'false' && value != '0',
    null => false,
    _ => true,
  };

  static int _compareValues(Object a, Object b) {
    final x = num.tryParse(_str(a));
    final y = num.tryParse(_str(b));
    if (x != null && y != null) return x.compareTo(y);
    return _str(a).compareTo(_str(b));
  }

  static int _compareTerms(Term? a, Term? b) {
    if (a == null || b == null) return a == null ? (b == null ? 0 : -1) : 1;
    return _compareValues(a, b);
  }
}

// ---- Cây cú pháp ----

sealed class _Node {
  const _Node();

  Term? resolve(Map<String, Term> sol);
}

class _VarNode extends _Node {
  const _VarNode(this.name);

  final String name;

  @override
  Term? resolve(Map<String, Term> sol) => sol[name];
}

class _TermNode extends _Node {
  const _TermNode(this.term);

  final Term term;

  @override
  Term? resolve(Map<String, Term> sol) => term;
}

class _PathVerb extends _Node {
  const _PathVerb(this.path);

  final _Path path;

  @override
  Term? resolve(Map<String, Term> sol) => null;
}

sealed class _Path {
  const _Path();
}

class _PathIri extends _Path {
  const _PathIri(this.iri);

  final Iri iri;
}

class _PathInverse extends _Path {
  const _PathInverse(this.inner);

  final _Path inner;
}

class _PathSeq extends _Path {
  const _PathSeq(this.items);

  final List<_Path> items;
}

class _PathAlt extends _Path {
  const _PathAlt(this.options);

  final List<_Path> options;
}

class _PathMod extends _Path {
  const _PathMod(this.inner, this.mod);

  final _Path inner;
  final String mod;
}

class _Pattern {
  const _Pattern(this.subject, this.verb, this.object);

  final _Node subject;
  final _Node verb;
  final _Node object;

  int boundCount(Set<String> known) {
    int score(_Node n) => switch (n) {
      _VarNode(:final name) => known.contains(name) ? 1 : 0,
      _ => 1,
    };
    return score(subject) * 2 + score(object) * 2 + score(verb);
  }
}

sealed class _Part {
  const _Part();
}

class _SubGroup extends _Part {
  const _SubGroup(this.group);

  final _Group group;
}

class _Optional extends _Part {
  const _Optional(this.group);

  final _Group group;
}

class _Union extends _Part {
  const _Union(this.branches);

  final List<_Group> branches;
}

class _Group {
  final triples = <_Pattern>[];
  final parts = <_Part>[];
  final filters = <_Expr>[];
}

class _Aggregate {
  const _Aggregate(this.alias, this.variable, {required this.distinct});

  final String alias;
  final String? variable;
  final bool distinct;
}

class _Query {
  _Query();

  final vars = <String>[];
  final aggregates = <_Aggregate>[];
  bool distinct = false;
  late _Group where;
  final groupBy = <String>[];
  final orderBy = <(String, bool)>[];
  int? limit;
  int offset = 0;
}

sealed class _Expr {
  const _Expr();
}

class _Const extends _Expr {
  const _Const(this.value);

  final Object value;
}

class _VarRef extends _Expr {
  const _VarRef(this.name);

  final String name;
}

class _Not extends _Expr {
  const _Not(this.inner);

  final _Expr inner;
}

class _Logic extends _Expr {
  const _Logic(this.left, this.right, {required this.and});

  final _Expr left;
  final _Expr right;
  final bool and;
}

class _Compare extends _Expr {
  const _Compare(this.op, this.left, this.right);

  final String op;
  final _Expr left;
  final _Expr right;
}

class _Call extends _Expr {
  const _Call(this.name, this.args);

  final String name;
  final List<_Expr> args;
}

// ---- Tách từ ----

enum _T { iri, pname, variable, string, number, word, punct, eof }

class _Tok {
  const _Tok(this.type, this.text, [this.lang]);

  final _T type;
  final String text;
  final String? lang;

  bool isWord(String w) => type == _T.word && text.toUpperCase() == w;
  bool isPunct(String p) => type == _T.punct && text == p;

  @override
  String toString() => text;
}

final _name = RegExp(r'[A-Za-z0-9_\-]');

List<_Tok> _tokenize(String src) {
  final out = <_Tok>[];
  var i = 0;
  bool at(String s) => src.startsWith(s, i);
  while (i < src.length) {
    final c = src[i];
    if (c.trim().isEmpty) {
      i++;
    } else if (c == '#') {
      while (i < src.length && src[i] != '\n') {
        i++;
      }
    } else if (c == '<') {
      final end = src.indexOf('>', i);
      final inner = end < 0 ? '' : src.substring(i + 1, end);
      if (end > i && !inner.contains(RegExp(r'\s')) && inner.contains(':')) {
        out.add(_Tok(_T.iri, inner));
        i = end + 1;
      } else if (at('<=')) {
        out.add(const _Tok(_T.punct, '<='));
        i += 2;
      } else {
        out.add(const _Tok(_T.punct, '<'));
        i++;
      }
    } else if ((c == '?' || c == r'$') &&
        i + 1 < src.length &&
        RegExp('[A-Za-z_]').hasMatch(src[i + 1])) {
      var j = i + 1;
      while (j < src.length && RegExp(r'\w').hasMatch(src[j])) {
        j++;
      }
      out.add(_Tok(_T.variable, src.substring(i + 1, j)));
      i = j;
    } else if (c == '"' || c == "'") {
      final b = StringBuffer();
      var j = i + 1;
      while (j < src.length && src[j] != c) {
        if (src[j] == r'\' && j + 1 < src.length) {
          j++;
          b.write(switch (src[j]) {
            'n' => '\n',
            't' => '\t',
            _ => src[j],
          });
        } else {
          b.write(src[j]);
        }
        j++;
      }
      if (j >= src.length) throw const SparqlError('unterminated_string');
      j++;
      String? lang;
      if (j < src.length && src[j] == '@') {
        var k = j + 1;
        while (k < src.length && RegExp(r'[A-Za-z\-]').hasMatch(src[k])) {
          k++;
        }
        lang = src.substring(j + 1, k);
        j = k;
      } else if (src.startsWith('^^', j)) {
        // Bỏ kiểu dữ liệu, so sánh theo chuỗi hoặc số
        j += 2;
        if (j < src.length && src[j] == '<') {
          j = src.indexOf('>', j) + 1;
        } else {
          while (j < src.length && RegExp(r'[\w:]').hasMatch(src[j])) {
            j++;
          }
        }
      }
      out.add(_Tok(_T.string, b.toString(), lang));
      i = j;
    } else if (RegExp('[0-9]').hasMatch(c)) {
      var j = i;
      while (j < src.length && RegExp('[0-9]').hasMatch(src[j])) {
        j++;
      }
      out.add(_Tok(_T.number, src.substring(i, j)));
      i = j;
    } else if (RegExp('[A-Za-z]').hasMatch(c)) {
      var j = i;
      while (j < src.length && _name.hasMatch(src[j])) {
        j++;
      }
      if (j < src.length && src[j] == ':') {
        // Tên rút gọn kg:x; dấu chấm cuối là hết câu, không thuộc tên
        var k = j + 1;
        while (k < src.length && (_name.hasMatch(src[k]) || src[k] == '.')) {
          k++;
        }
        while (k > j + 1 && src[k - 1] == '.') {
          k--;
        }
        out.add(_Tok(_T.pname, src.substring(i, k)));
        i = k;
      } else {
        out.add(_Tok(_T.word, src.substring(i, j)));
        i = j;
      }
    } else {
      final two = i + 1 < src.length ? src.substring(i, i + 2) : '';
      if (const ['!=', '>=', '&&', '||', '^^'].contains(two)) {
        out.add(_Tok(_T.punct, two));
        i += 2;
      } else if ('{}().;,|/^+*?!=>'.contains(c)) {
        out.add(_Tok(_T.punct, c));
        i++;
      } else {
        throw SparqlError('unexpected_char:$c');
      }
    }
  }
  out.add(const _Tok(_T.eof, ''));
  return out;
}

// ---- Phân tích cú pháp ----

class _Parser {
  _Parser(this._toks);

  final List<_Tok> _toks;
  var _i = 0;
  final _prefixes = Map<String, String>.of(prefixes);

  _Tok get _peek => _toks[_i];
  _Tok _next() => _toks[_i++];

  void _expectPunct(String p) {
    if (!_peek.isPunct(p)) {
      throw SparqlError('expected "$p" near "${_peek.text}"');
    }
    _i++;
  }

  bool _acceptPunct(String p) {
    if (_peek.isPunct(p)) {
      _i++;
      return true;
    }
    return false;
  }

  bool _acceptWord(String w) {
    if (_peek.isWord(w)) {
      _i++;
      return true;
    }
    return false;
  }

  _Query parseQuery() {
    final q = _Query();
    while (_peek.isWord('PREFIX')) {
      _i++;
      final name = _next();
      final iri = _next();
      if (name.type != _T.pname || iri.type != _T.iri) {
        throw const SparqlError('bad_prefix');
      }
      _prefixes[name.text.substring(0, name.text.length - 1)] = iri.text;
    }
    if (!_acceptWord('SELECT')) {
      throw const SparqlError('only_select_supported');
    }
    q.distinct = _acceptWord('DISTINCT') || _acceptWord('REDUCED');
    if (!_acceptPunct('*')) {
      while (true) {
        if (_peek.type == _T.variable) {
          q.vars.add(_next().text);
        } else if (_acceptPunct('(')) {
          if (!_acceptWord('COUNT')) {
            throw const SparqlError('only_count_supported');
          }
          _expectPunct('(');
          final distinct = _acceptWord('DISTINCT');
          String? variable;
          if (!_acceptPunct('*')) {
            final v = _next();
            if (v.type != _T.variable) throw const SparqlError('bad_count');
            variable = v.text;
          }
          _expectPunct(')');
          if (!_acceptWord('AS')) throw const SparqlError('expected AS');
          final alias = _next();
          if (alias.type != _T.variable) throw const SparqlError('bad_alias');
          _expectPunct(')');
          q.aggregates.add(
            _Aggregate(alias.text, variable, distinct: distinct),
          );
          q.vars.add(alias.text);
        } else {
          break;
        }
      }
      if (q.vars.isEmpty) throw const SparqlError('no_variables');
    }
    _acceptWord('WHERE');
    q.where = _group();
    while (true) {
      if (_acceptWord('GROUP')) {
        if (!_acceptWord('BY')) throw const SparqlError('expected BY');
        while (_peek.type == _T.variable) {
          q.groupBy.add(_next().text);
        }
      } else if (_acceptWord('ORDER')) {
        if (!_acceptWord('BY')) throw const SparqlError('expected BY');
        while (true) {
          if (_peek.type == _T.variable) {
            q.orderBy.add((_next().text, false));
          } else if (_peek.isWord('ASC') || _peek.isWord('DESC')) {
            final desc = _next().isWord('DESC');
            _expectPunct('(');
            final v = _next();
            if (v.type != _T.variable) throw const SparqlError('bad_order');
            _expectPunct(')');
            q.orderBy.add((v.text, desc));
          } else {
            break;
          }
        }
      } else if (_acceptWord('LIMIT')) {
        q.limit = int.parse(_number());
      } else if (_acceptWord('OFFSET')) {
        q.offset = int.parse(_number());
      } else {
        break;
      }
    }
    if (_peek.type != _T.eof) throw SparqlError('unexpected "${_peek.text}"');
    return q;
  }

  String _number() {
    final t = _next();
    if (t.type != _T.number) throw const SparqlError('expected number');
    return t.text;
  }

  _Group _group() {
    _expectPunct('{');
    final g = _Group();
    while (!_acceptPunct('}')) {
      if (_peek.type == _T.eof) throw const SparqlError('expected "}"');
      if (_acceptWord('FILTER')) {
        g.filters.add(_primary());
      } else if (_acceptWord('OPTIONAL')) {
        g.parts.add(_Optional(_group()));
      } else if (_peek.isPunct('{')) {
        final branches = [_group()];
        while (_acceptWord('UNION')) {
          branches.add(_group());
        }
        g.parts.add(
          branches.length == 1 ? _SubGroup(branches.first) : _Union(branches),
        );
      } else if (_acceptPunct('.')) {
        continue;
      } else {
        _triples(g);
      }
    }
    return g;
  }

  void _triples(_Group g) {
    final subject = _node();
    while (true) {
      final verb = _verb();
      while (true) {
        g.triples.add(_Pattern(subject, verb, _node()));
        if (!_acceptPunct(',')) break;
      }
      if (!_acceptPunct(';')) break;
      if (_peek.isPunct('.') || _peek.isPunct('}')) break;
    }
  }

  _Node _verb() {
    if (_peek.type == _T.variable) return _VarNode(_next().text);
    return _PathVerb(_pathAlt());
  }

  _Path _pathAlt() {
    final options = [_pathSeq()];
    while (_acceptPunct('|')) {
      options.add(_pathSeq());
    }
    return options.length == 1 ? options.first : _PathAlt(options);
  }

  _Path _pathSeq() {
    final items = [_pathElt()];
    while (_acceptPunct('/')) {
      items.add(_pathElt());
    }
    return items.length == 1 ? items.first : _PathSeq(items);
  }

  _Path _pathElt() {
    final inverse = _acceptPunct('^');
    _Path p;
    if (_acceptPunct('(')) {
      p = _pathAlt();
      _expectPunct(')');
    } else if (_peek.type == _T.word && _peek.text == 'a') {
      _i++;
      p = const _PathIri(Iri(rdfType));
    } else {
      p = _PathIri(_iri(_next()));
    }
    for (final mod in const ['*', '+', '?']) {
      if (_acceptPunct(mod)) {
        p = _PathMod(p, mod);
        break;
      }
    }
    return inverse ? _PathInverse(p) : p;
  }

  _Node _node() {
    final t = _next();
    return switch (t.type) {
      _T.variable => _VarNode(t.text),
      _T.string => _TermNode(Lit(t.text, t.lang)),
      _T.number => _TermNode(Lit(t.text)),
      _ => _TermNode(_iri(t)),
    };
  }

  Iri _iri(_Tok t) {
    if (t.type == _T.iri) return Iri(t.text);
    if (t.type == _T.pname) {
      final colon = t.text.indexOf(':');
      final ns = _prefixes[t.text.substring(0, colon)];
      if (ns == null) {
        throw SparqlError('unknown_prefix:${t.text.substring(0, colon)}');
      }
      return Iri(ns + t.text.substring(colon + 1));
    }
    throw SparqlError('expected IRI near "${t.text}"');
  }

  _Expr _expr() => _or();

  _Expr _or() {
    var left = _and();
    while (_acceptPunct('||')) {
      left = _Logic(left, _and(), and: false);
    }
    return left;
  }

  _Expr _and() {
    var left = _cmp();
    while (_acceptPunct('&&')) {
      left = _Logic(left, _cmp(), and: true);
    }
    return left;
  }

  _Expr _cmp() {
    final left = _unary();
    for (final op in const ['=', '!=', '<=', '>=', '<', '>']) {
      if (_acceptPunct(op)) return _Compare(op, left, _unary());
    }
    return left;
  }

  _Expr _unary() => _acceptPunct('!') ? _Not(_unary()) : _primary();

  _Expr _primary() {
    if (_acceptPunct('(')) {
      final e = _expr();
      _expectPunct(')');
      return e;
    }
    final t = _next();
    switch (t.type) {
      case _T.variable:
        return _VarRef(t.text);
      case _T.string:
        return _Const(t.lang == null ? t.text : Lit(t.text, t.lang));
      case _T.number:
        return _Const(num.parse(t.text));
      case _T.iri || _T.pname:
        return _Const(_iri(t));
      case _T.word:
        final name = t.text.toUpperCase();
        if (name == 'TRUE' || name == 'FALSE') return _Const(name == 'TRUE');
        _expectPunct('(');
        final args = <_Expr>[];
        if (!_acceptPunct(')')) {
          do {
            args.add(_expr());
          } while (_acceptPunct(','));
          _expectPunct(')');
        }
        return _Call(name, args);
      case _T.punct || _T.eof:
        throw SparqlError('unexpected "${t.text}" in FILTER');
    }
  }
}
