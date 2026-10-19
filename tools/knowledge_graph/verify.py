"""
Họ tên: Nguyễn Tâm Bình
MSSV:   2324801030003
Môn:    Kiến trúc và thiết kế phần mềm
Bài:    Đồ án TBT Center đa quốc gia
Ngày:   2026-10-18

Kiểm chéo đồ thị tri thức bằng công cụ chuẩn (ADR 0030):
rdflib đọc Turtle service xuất ra, owlrl (OWL 2 RL) suy luận lại, so với bộ suy luận của service;
cùng câu SPARQL chạy trên service và trên rdflib phải ra cùng kết quả.
Cần: pip install rdflib owlrl. Chạy: python tools/knowledge_graph/verify.py
"""
import json
import time
import urllib.parse
import urllib.request
from pathlib import Path

import owlrl
import rdflib

SECRETS = Path(__file__).resolve().parents[2] / 'deploy/secrets/keycloak.env'
BASE = 'http://localhost:8000/knowledge'
KG = 'http://tbt-center.local/kg/'
KGO = 'http://tbt-center.local/ontology#'
QUERIES = {
    'Chốt lương cần những service nào': 'SELECT ?s WHERE { kg:payroll-closing kgo:involves ?s } ORDER BY ?s',
    'Ai được xem lương thực nhận': 'SELECT ?r WHERE { ?r kgo:can_view kg:net-pay } ORDER BY ?r',
    'Bước nào trước bước chi ngân hàng': 'SELECT ?b WHERE { ?b kgo:next_step+ kg:step-pay } ORDER BY ?b',
    'Service nào dùng RabbitMQ': 'SELECT ?s WHERE { ?s kgo:uses kg:tech-rabbitmq ; a kgo:service } ORDER BY ?s',
    'Số service mỗi nơi': 'SELECT ?place (COUNT(?s) AS ?n) WHERE { ?s a kgo:service ; kgo:runs_in ?place } '
                          'GROUP BY ?place ORDER BY ?place',
}


def token(user='hr.vn'):
    password = next(line.split('=', 1)[1].strip() for line in SECRETS.read_text(encoding='utf-8').splitlines()
                    if line.startswith('TBT_DEFAULT_PASSWORD='))
    data = urllib.parse.urlencode({'grant_type': 'password', 'client_id': 'tbt-dev-cli',
                                   'username': user, 'password': password}).encode()
    r = urllib.request.urlopen('http://localhost:8180/realms/tbt/protocol/openid-connect/token', data=data, timeout=30)
    return json.load(r)['access_token']


def call(tok, path, body=None):
    req = urllib.request.Request(BASE + path, method='GET' if body is None else 'POST',
                                 data=None if body is None else json.dumps(body).encode(),
                                 headers={'Authorization': 'Bearer ' + tok, 'Content-Type': 'application/json'})
    raw = urllib.request.urlopen(req, timeout=60).read()
    return raw.decode() if path.endswith('turtle') or 'format=turtle' in path else json.loads(raw)


def edges(graph):
    return {(str(s), str(p), str(o)) for s, p, o in graph
            if str(p).startswith(KGO) and str(s).startswith(KG) and str(o).startswith(KG)}


def main():
    tok = token()
    stats = call(tok, '/reasoner', {})
    print(f"Service suy luận: {stats['inferred']} cạnh mới từ {stats['asserted']} cạnh, "
          f"{len(stats['rejected'])} cạnh bị loại, {stats['ms']} ms")

    asserted = rdflib.Graph().parse(data=call(tok, '/ontology?format=turtle'), format='turtle')
    print(f'rdflib đọc Turtle: {len(asserted)} bộ ba')
    before = edges(asserted)
    t = time.time()
    owlrl.DeductiveClosure(owlrl.OWLRL_Semantics).expand(asserted)
    closure = edges(asserted)
    print(f'owlrl (OWL 2 RL): {len(closure) - len(before)} cạnh mới, {time.time() - t:.1f} s')

    full_ttl = call(tok, '/ontology?format=turtle&inferred=true')
    ours = edges(rdflib.Graph().parse(data=full_ttl, format='turtle'))
    print(f'Khớp hoàn toàn: {closure == ours} (chỉ owlrl có: {len(closure - ours)}, chỉ service có: {len(ours - closure)})')

    full = rdflib.Graph().parse(data=full_ttl, format='turtle')
    owlrl.DeductiveClosure(owlrl.RDFS_Semantics).expand(full)
    prefix = f'PREFIX kg: <{KG}> PREFIX kgo: <{KGO}> '
    for name, q in QUERIES.items():
        mine = call(tok, '/sparql', {'query': q, 'lang': 'vi'})
        rows = [tuple(r[v]['value'] for v in mine['vars']) for r in mine['rows']]
        theirs = [tuple(str(x).replace(KG, 'kg:') for x in row) for row in full.query(prefix + q)]
        print(f'SPARQL "{name}": {len(rows)} dòng, khớp rdflib: {rows == theirs}')


if __name__ == '__main__':
    main()
