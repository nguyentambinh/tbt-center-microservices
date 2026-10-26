# Họ tên: Nguyễn Tâm Bình
# MSSV:   2324801030003
# Môn:    Kiến trúc và thiết kế phần mềm
# Bài:    Đồ án TBT Center đa quốc gia
# Ngày:   2026-10-15
"""Sinh file SQL dữ liệu mẫu cho 6 khu vực vào deploy/seed/<region>/<service>.sql.

VN đọc từ tệp SQLite nguồn (chỉ đọc), các nước còn lại sinh theo ngôn ngữ từng nước.
Chạy: python tools/seed_data/generate.py [đường dẫn tệp SQLite]
"""

import datetime as dt
import json
import random
import sqlite3
import sys
import unicodedata
from decimal import ROUND_HALF_UP, Decimal
from pathlib import Path

from locales import HOLIDAYS_2026, RATE_PATH, REGIONS

ROOT = Path(__file__).resolve().parents[2]
LEGACY_DB = sys.argv[1] if len(sys.argv) > 1 else 'D:/Android/QLNSVATC.db'  # tệp SQLite nguồn
TODAY = dt.date(2026, 10, 15)
RATE_START = dt.date(2023, 1, 1)
TIMESHEET_FROM = dt.date(2026, 8, 1)
EMPLOYEES_PER_REGION = 40

TABLES = {
    'hr': ['contacts', 'insurances', 'health_records', 'relatives', 'employees', 'positions', 'departments',
           'specialty_languages', 'specialty_skills', 'specialty_degrees', 'languages', 'skills', 'degrees',
           'specialties', 'companies', 'outbox'],
    'attendance': ['leave_requests', 'timesheets', 'work_schedules', 'holidays', 'outbox'],
    'payroll': ['payslips', 'bonuses_penalties', 'coefficients', 'salaries', 'outbox'],
    'project_contract': ['project_members', 'project_contracts', 'projects', 'contracts', 'customers', 'outbox'],
    'finance': ['project_costs', 'material_shipments', 'material_imports', 'suppliers', 'service_revenues',
                'project_revenues', 'risks', 'revenue_categories', 'revenue_areas', 'market_fluctuations', 'outbox'],
    'recruitment': ['candidate_status_history', 'candidate_documents', 'cv_summaries', 'candidate_import_rows',
                    'candidate_imports', 'candidates', 'outbox'],
    'currency': ['exchange_rates'],
}

PIPELINE = ['submitted', 'analyzed', 'screening', 'interview', 'interviewed', 'rejected']

# Chức vụ thứ i (theo thứ tự trong locales.py) thuộc phòng ban nào: quản lý dự án, kỹ sư → thiết kế,
# an toàn, nhân sự, kế toán → tài chính, giám sát → thi công, hành chính.
POSITION_TO_DEPARTMENT = [0, 5, 5, 1, 2, 3, 6, 7]


def sql_value(v):
    if v is None:
        return 'null'
    if isinstance(v, bool):
        return 'true' if v else 'false'
    if isinstance(v, (int, float, Decimal)):
        return str(v)
    if isinstance(v, (dict, list)):
        v = json.dumps(v, ensure_ascii=False)
    if isinstance(v, (dt.date, dt.time)):
        v = v.isoformat()
    return "'" + str(v).replace("'", "''") + "'"


class SeedFile:
    def __init__(self, service):
        self.service = service
        self.lines = []

    def insert(self, table, rows):
        if not rows:
            return
        cols = list(rows[0].keys())
        self.lines.append(f'insert into {table} ({", ".join(cols)}) values')
        values = [f'  ({", ".join(sql_value(r[c]) for c in cols)})' for r in rows]
        self.lines.append(',\n'.join(values) + ';\n')

    def write(self, region):
        out = ROOT / 'deploy' / 'seed' / region / f'{self.service}.sql'
        out.parent.mkdir(parents=True, exist_ok=True)
        header = [f'-- Sinh tự động bởi tools/seed_data/generate.py, khu vực {region}. Không sửa tay.',
                  'begin;',
                  f'truncate table {", ".join(TABLES[self.service])} restart identity cascade;', '']
        out.write_text('\n'.join(header + self.lines + ['commit;', '']), encoding='utf-8', newline='\n')


def ascii_fold(text):
    text = text.replace('đ', 'd').replace('Đ', 'D')
    text = unicodedata.normalize('NFD', text)
    return ''.join(c for c in text if unicodedata.category(c) != 'Mn')


def money(value):
    return Decimal(str(value)).quantize(Decimal('0.01'), rounding=ROUND_HALF_UP)


def working_days(start, end, holidays):
    day = start
    while day <= end:
        if day.weekday() < 5 and day not in holidays:
            yield day
        day += dt.timedelta(days=1)


class Rates:
    """Tỷ giá mô phỏng theo ngày: đi tuyến tính từ đầu kỳ tới cuối kỳ, cộng dao động nhỏ."""

    def __init__(self):
        rnd = random.Random(2026)
        self.table = {}
        span = (TODAY - RATE_START).days
        for quote, (start, end) in RATE_PATH.items():
            for i in range(span + 1):
                day = RATE_START + dt.timedelta(days=i)
                base = start + (end - start) * i / span
                noise = 1 if quote == 'USD' else 1 + rnd.uniform(-0.008, 0.008)
                self.table[(day, quote)] = Decimal(str(base * noise)).quantize(Decimal('0.00000001'))

    def convert(self, amount, currency, on):
        on = min(max(on, RATE_START), TODAY)
        rate = self.table[(on, currency)]
        return {'amount_original': money(amount), 'currency_original': currency, 'rate_applied': rate,
                'rate_date': on, 'amount_base': money(Decimal(str(amount)) / rate)}

    def rows(self):
        return [{'rate_date': d, 'quote': q, 'rate': r, 'source': 'mo_phong'} for (d, q), r in self.table.items()]


def candidate_history(rnd, candidate_id, status, created, actor):
    steps = PIPELINE[:PIPELINE.index(status) + 1] if status != 'rejected' else ['submitted', 'analyzed', 'rejected']
    rows, when = [], created
    for step in steps:
        rows.append({'candidate_id': candidate_id, 'status': step, 'note': None,
                     'changed_by': 'system' if step in ('submitted', 'analyzed') else actor,
                     'changed_at': when.isoformat(sep=' ')})
        when += dt.timedelta(days=rnd.randint(1, 6), hours=rnd.randint(1, 8))
    return rows


def uuid_from(rnd):
    return '%08x-%04x-4%03x-%04x-%012x' % (rnd.getrandbits(32), rnd.getrandbits(16), rnd.getrandbits(12),
                                           0x8000 | rnd.getrandbits(14), rnd.getrandbits(48))


# ---------------------------------------------------------------- Việt Nam (từ dữ liệu cũ)

VN_TEXT = {
    'relations': ['Vợ', 'Chồng', 'Ba', 'Mẹ', 'Anh', 'Chị', 'Em'],
    'labor_contracts': ['Không xác định thời hạn', 'Xác định thời hạn 12 tháng', 'Xác định thời hạn 36 tháng'],
    'leave_types': [('Nghỉ phép năm', 'Về quê thăm gia đình'), ('Nghỉ ốm', 'Sốt siêu vi'),
                    ('Nghỉ phép năm', 'Việc riêng')],
    'streets': ['Nguyễn Trãi', 'Lê Lợi', 'Trần Hưng Đạo', 'Hai Bà Trưng', 'Lý Thường Kiệt', 'Nguyễn Huệ',
                'Điện Biên Phủ', 'Võ Văn Tần'],
    'cities': ['Hà Nội', 'TP Hồ Chí Minh', 'Đà Nẵng', 'Hải Phòng', 'Cần Thơ', 'Bình Dương'],
    'family': ['Nguyễn Văn', 'Trần Thị', 'Lê Văn', 'Phạm Thị', 'Hoàng Văn', 'Võ Thị', 'Đặng Văn', 'Bùi Thị'],
    'given': ['An', 'Bình', 'Chi', 'Dũng', 'Hà', 'Khánh', 'Linh', 'Minh', 'Nam', 'Phương', 'Quân', 'Trang'],
    'suppliers': ['Công ty TNHH Vật liệu Xây dựng Phú Thành', 'Công ty CP Thép Minh An',
                  'Công ty TNHH Bê tông Sao Việt'],
}


def vn_phone(rnd):
    return f'09{rnd.randint(10000000, 99999999)}'


def build_vn(legacy, rates):
    rnd = random.Random('vn')
    q = lambda sql: [dict(r) for r in legacy.execute(sql)]
    files = {s: SeedFile(s) for s in TABLES}

    # hr
    hr = files['hr']
    companies = q('select * from THONGTINDOANHNGHIEP')
    hr.insert('companies', [{'id': c['MADN'], 'country_code': 'VN', 'name': c['TENDN'], 'tier': c['PHANCAP'],
                             'address': c['DIACHI']} for c in companies])
    for table, key, name, target in [('DSCHUYENMON', 'MACM', 'TENCM', 'specialties'),
                                     ('DSBANGCAP', 'MABC', 'TENBC', 'degrees'),
                                     ('DSKYNANG', 'MAKN', 'TENKN', 'skills'),
                                     ('DSNNNGU', 'MANN', 'TENNN', 'languages')]:
        hr.insert(target, [{'id': r[key], 'name': r[name]} for r in q(f'select * from {table}')])

    # Bảng nối chuyên môn đang trống trong dữ liệu cũ: gán ngẫu nhiên có kiểm soát.
    spec_ids = [r['MACM'] for r in q('select MACM from DSCHUYENMON')]
    degree_ids = [r['MABC'] for r in q('select MABC from DSBANGCAP')]
    skill_ids = [r['MAKN'] for r in q('select MAKN from DSKYNANG')]
    lang_ids = [r['MANN'] for r in q('select MANN from DSNNNGU')]
    hr.insert('specialty_degrees', [{'specialty_id': s, 'degree_id': d} for s in spec_ids
                                    for d in rnd.sample(degree_ids, 2)])
    hr.insert('specialty_skills', [{'specialty_id': s, 'skill_id': k} for s in spec_ids
                                   for k in rnd.sample(skill_ids, 3)])
    hr.insert('specialty_languages', [{'specialty_id': s, 'language_id': lang} for s in spec_ids
                                      for lang in rnd.sample(lang_ids, 1)])

    employees = q('select * from NHANVIEN')
    dept_company = {}
    for e in employees:
        dept_company.setdefault(e['MAPB'], e['MADN'])
    hr.insert('departments', [{'id': d['MAPB'], 'company_id': dept_company.get(d['MAPB'], 'TBTHN'),
                               'country_code': 'VN', 'name': d['TENPB'], 'manager_id': d['MATRG_PHG'],
                               'location_code': None if d['DIADIEM'] is None else str(d['DIADIEM'])}
                              for d in q('select * from PHONGBAN')])
    positions = q('select * from VITRICONGVIEC')
    coefficient_of = {p['MACV']: p['HESOLUONG'] for p in positions}
    hr.insert('positions', [{'id': p['MACV'], 'name': p['TENCV'], 'specialty_id': p['MACM'],
                             'salary_coefficient': p['HESOLUONG']} for p in positions])

    emp_ids = [e['MANV'] for e in employees]
    hr.insert('employees', [{
        'id': e['MANV'], 'company_id': e['MADN'], 'country_code': 'VN', 'family_name': e['HOLOT'],
        'given_name': e['TENNV'], 'birth_year': e['NAMSINH'], 'gender': e['GIOITINH'], 'department_id': e['MAPB'],
        'position_id': e['MACV'],
        'email': ascii_fold(f"{e['TENNV']}.{e['HOLOT'].split()[0]}.{e['MANV'][3:8]}").lower() + '@vn.tbt.local',
        'photo_url': e['ANH'], 'labor_contract': e['HDLD'] or rnd.choice(VN_TEXT['labor_contracts']),
        'hired_on': dt.date(rnd.randint(2015, 2025), rnd.randint(1, 12), rnd.randint(1, 28)),
    } for e in employees])

    relatives = q('select * from NHANTHAN')
    have_relative = {r['MANV'] for r in relatives}
    rows = [{'employee_id': r['MANV'], 'full_name': r['TENNT'], 'phone': r['DIENTHOAI'], 'address': r['DIACHI'],
             'relationship': r['QUANHE']} for r in relatives]
    for emp in emp_ids:
        if emp not in have_relative:
            rows.append({'employee_id': emp,
                         'full_name': f"{rnd.choice(VN_TEXT['family'])} {rnd.choice(VN_TEXT['given'])}",
                         'phone': vn_phone(rnd),
                         'address': f"{rnd.randint(1, 300)} {rnd.choice(VN_TEXT['streets'])}, "
                                    f"{rnd.choice(VN_TEXT['cities'])}",
                         'relationship': rnd.choice(VN_TEXT['relations'])})
    hr.insert('relatives', rows)
    hr.insert('health_records', [{'employee_id': h['MANV'], 'height_cm': h['CHIEUCAO'], 'weight_kg': h['CANNANG'],
                                  'medical_history': h['TIENSUBENH'], 'vision_score': h['THILUCTREN10'],
                                  'updated_on': h['NGAYCAPNHAT']} for h in q('select * from THONGTINSUCKHOE')])
    hr.insert('insurances', [{'employee_id': i['MANV'], 'insurance_type': i['LOAIBAOHIEM'],
                              'insurance_number': i['SOBAOHIEM'], 'expires_on': i['THOIHAN']}
                             for i in q('select * from THONGTINBAOHIEM')])

    area_codes = [r['MAKV'] for r in q('select MAKV from DTTHEOKV')]
    contacts = {c['MANV']: c for c in q('select * from THONGTINLIENHE')}
    hr.insert('contacts', [{
        'employee_id': emp,
        'phone': contacts[emp]['SODT'] if emp in contacts else vn_phone(rnd),
        'address': contacts[emp]['DIACHI'] if emp in contacts else
        f"{rnd.randint(1, 300)} {rnd.choice(VN_TEXT['streets'])}, {rnd.choice(VN_TEXT['cities'])}",
        'facebook': contacts[emp]['FB'] if emp in contacts else None,
        'x_handle': contacts[emp]['X'] if emp in contacts else None,
        'hometown_code': str(contacts[emp]['QUEQUAN']) if emp in contacts else rnd.choice(area_codes),
    } for emp in emp_ids])

    # attendance
    att = files['attendance']
    holidays = q('select * from DSNGAYLE')
    att.insert('holidays', [{'country_code': 'VN', 'holiday_date': h['NGAYLE'], 'name': h['NOIDUNG']}
                            for h in holidays])
    holiday_days = {dt.date.fromisoformat(h['NGAYLE']) for h in holidays}
    legacy_ts = q('select * from CHAMCONG')
    sheets = [{'employee_id': t['MANV'], 'work_date': t['NGAYCC'], 'check_in': t['GIOVAO'], 'check_out': t['GIORA'],
               'work_hours': t['GIOCONG'], 'overtime_hours': t['TANGCA'], 'total_hours': t['TONGCA']}
              for t in legacy_ts]
    att.insert('timesheets', sheets + generated_timesheets(rnd, emp_ids, holiday_days))
    att.insert('work_schedules', generated_schedules(rnd, emp_ids, holiday_days, 'Thi công công trình'))
    att.insert('leave_requests', generated_leaves(rnd, emp_ids, VN_TEXT['leave_types']))

    # payroll
    pay = files['payroll']
    legacy_salary = {s['MANV']: s for s in q('select * from LUONG')}
    salaries = {}
    for e in employees:
        if e['MANV'] in legacy_salary:
            salaries[e['MANV']] = legacy_salary[e['MANV']]['LUONGCOBAN']
        else:
            # Hệ số cũ của nhân viên là 10 hoặc 20 (vị trí quản lý), nhân thẳng ra lương quá cao,
            # nên bám theo mức 11–13 triệu của 4 người đã có lương, vị trí hệ số 20 cao hơn 20%.
            bonus = 1.2 if coefficient_of.get(e['MACV'], 10) >= 20 else 1
            salaries[e['MANV']] = round(rnd.uniform(10_500_000, 13_500_000) * bonus, -5)
    pay.insert('salaries', [{'employee_id': emp, 'employment_type': legacy_salary.get(emp, {}).get('LOAINV', 'FT'),
                             'base_salary': money(amount), 'currency': 'VND'} for emp, amount in salaries.items()])
    pay.insert('coefficients', [{'id': c['MAHSO'], 'coefficient': c['HESOTIEN'], 'reason': c['LYDO']}
                                for c in q('select * from DSHESO')])
    bonuses = [bonus_row(rates, b['MANV'], dt.date.fromisoformat(b['NGAY']),
                         'penalty' if b['HINHTHUC'] == 'KL' else 'bonus', b['SOTIEN'], b['HESOTIEN'], 'VND')
               for b in q('select * from DSTHUONGPHAT')]
    bonuses += generated_bonuses(rnd, rates, emp_ids, 'VND', 2_000_000, {(b['employee_id'], b['occurred_on'])
                                                                         for b in bonuses})
    pay.insert('bonuses_penalties', bonuses)
    pay.insert('payslips', generated_payslips(rnd, rates, salaries, 'VND', 0.105))

    # project_contract
    pc = files['project_contract']
    pc.insert('customers', [{'id': c['MAKH'], 'country_code': 'VN',
                             'customer_type': 'individual' if c['LOAIKH'] == 'CN' else 'business',
                             'name': c['THONGTIN'], 'contact': c['LIENHE'], 'address': c['DIACHI']}
                            for c in q('select * from KHACHHANG')])
    pc.insert('contracts', [{'id': c['MAHD'], 'country_code': 'VN', 'name': c['TENHD'], 'contract_type': c['LOAI'],
                             'start_date': c['NGAYBD'], 'expected_end_date': c['NGAYKT_DUTINH']}
                            for c in q('select * from HOPDONG')])
    company_ids = [c['MADN'] for c in companies]
    pc.insert('projects', [{'id': p['MADA'], 'company_id': rnd.choice(company_ids), 'country_code': 'VN',
                            'customer_id': p['MAKH'], 'deposit_amount': money(p['TIENCOC']),
                            'expected_acceptance_amount': money(p['TIENNGHIEMTHU_DUTINH']), 'currency': 'VND'}
                           for p in q('select * from DUAN')])
    project_contracts = q('select * from DUANTHEOHOPDONG')
    pc.insert('project_contracts', [{'id': p['MADAHD'], 'project_id': p['MADA'], 'contract_id': p['MAHD'],
                                     'end_date': p['NGAYKT']} for p in project_contracts])
    members = [{'project_contract_id': m['MADAHD'], 'employee_id': m['MANV'], 'total_hours': m['TONGTGLAMVIEC'],
                'project_salary': money(m['LUONGTHEODUAN'])} for m in q('select * from NVTHAMGIADA')]
    taken = {(m['project_contract_id'], m['employee_id']) for m in members}
    for p in project_contracts:
        for emp in rnd.sample(emp_ids, 3):
            if (p['MADAHD'], emp) not in taken:
                taken.add((p['MADAHD'], emp))
                members.append({'project_contract_id': p['MADAHD'], 'employee_id': emp,
                                'total_hours': rnd.randint(80, 220),
                                'project_salary': money(rnd.randint(15, 40) * 1_000_000)})
    pc.insert('project_members', members)

    # finance
    fin = files['finance']
    areas = q('select * from DTTHEOKV')
    categories = q('select * from DTTHEOLHCT')
    risks = q('select * from RUIRO')
    fin.insert('revenue_areas', [{'id': a['MAKV'], 'province_name': a['TENTINH'], 'coefficient': a['HESOKV']}
                                 for a in areas])
    fin.insert('revenue_categories', [{'id': c['MALH'], 'name': c['TENLH']} for c in categories])
    fin.insert('risks', [{'id': r['MARR'], 'name': r['TENRR'], 'coefficient': r['HESORR']} for r in risks])
    area_set, cat_set, risk_set = {a['MAKV'] for a in areas}, {c['MALH'] for c in categories}, {r['MARR'] for r in risks}
    revenues, skipped = [], 0
    for r in q('select * from DTDUAN'):
        if r['MAKV'] not in area_set or r['MALH'] not in cat_set or (r['MARR'] and r['MARR'] not in risk_set):
            skipped += 1
            continue
        revenues.append({'project_id': r['MADA'], 'category_id': r['MALH'], 'area_id': r['MAKV'],
                         'risk_id': r['MARR'], 'change_coefficient': r['HSTHAYDOI'],
                         **rates.convert(r['TIENNGHIEMTHU_TONG'], 'VND', rnd_date(rnd, 2024, 2025))})
    fin.insert('project_revenues', revenues)
    fin.insert('service_revenues', [{'id': s['MADV'], 'customer_id': s['MAKH'], 'service_type': s['LHDICHVU'],
                                     'used_on': s['NGAYSDDV'], 'expected_price': money(s['GIACADUTINH']),
                                     **rates.convert(s['GIACATONG'], 'VND', dt.date.fromisoformat(s['NGAYSDDV']))}
                                    for s in q('select * from DTDICHVU')])
    suppliers = [{'id': f'NCC{i + 1:02d}', 'name': name, 'contact': vn_phone(rnd),
                  'address': f"{rnd.randint(1, 300)} {rnd.choice(VN_TEXT['streets'])}, "
                             f"{rnd.choice(VN_TEXT['cities'])}"}
                 for i, name in enumerate(VN_TEXT['suppliers'])]
    fin.insert('suppliers', suppliers)
    imports = q('select * from NHAPNVL')
    shipments = q('select * from VANCHUYENNVL')
    fin.insert('material_imports', [{'id': m['MANHAP'], 'supplier_id': rnd.choice(suppliers)['id'],
                                     'material_name': m['TENNVL'], 'imported_on': m['NGAYNHAP'],
                                     **rates.convert(m['CPNHAP'], 'VND', dt.date.fromisoformat(m['NGAYNHAP']))}
                                    for m in imports])
    fin.insert('material_shipments', [{'id': s['MAVC'], 'shipped_on': s['NGAYVC'],
                                       **rates.convert(s['CPVC'], 'VND', dt.date.fromisoformat(s['NGAYVC']))}
                                      for s in shipments])
    import_set, ship_set = {m['MANHAP'] for m in imports}, {s['MAVC'] for s in shipments}
    costs = []
    for c in q('select * from CPDUAN'):
        if c['MANHAP'] not in import_set or c['MAVC'] not in ship_set:
            skipped += 1
            continue
        costs.append({'project_id': c['MADA'], 'import_id': c['MANHAP'], 'shipment_id': c['MAVC'],
                      'change_coefficient': c['HSTHAYDOI'],
                      **rates.convert(c['CHIPHITONG'], 'VND', rnd_date(rnd, 2025, 2025))})
    fin.insert('project_costs', costs)
    fin.insert('market_fluctuations', [{'observed_on': m['THOIGIAN'], 'coefficient': m['HSTHITRUONG']}
                                       for m in q('select * from BIENDONGTHITRUONG')])
    if skipped:
        print(f'  vn: bỏ {skipped} dòng tài chính trỏ tới mã không tồn tại')

    # recruitment
    rec = files['recruitment']
    candidates, docs, history, seen_emails = [], [], [], set()
    position_names = [p['TENCV'] for p in positions]
    for h in q('select * from HOSOVIECLAM'):
        cid = uuid_from(rnd)
        email = h['EMAIL']
        if not email or email.lower() in seen_emails:
            email = ascii_fold(h['TENUNGVIEN']).lower().replace(' ', '.') + '@example.com'
        seen_emails.add(email.lower())
        status = rnd.choice(PIPELINE)
        created = dt.datetime(2025, rnd.randint(4, 12), rnd.randint(1, 28), rnd.randint(8, 17))
        candidates.append({'id': cid, 'country_code': 'VN', 'full_name': h['TENUNGVIEN'], 'email': email,
                           'phone': vn_phone(rnd), 'applied_position': rnd.choice(position_names), 'status': status,
                           'source': 'legacy', 'cv_object_key': f"legacy/{h['FILETHONGTIN']}",
                           'consent_ai': False, 'created_at': created.isoformat(sep=' ')})
        for kind, name in [('degree', h['FILEBANGCAP']), ('other', h['FILEKHAC'])]:
            if name:
                docs.append({'candidate_id': cid, 'kind': kind, 'object_key': f'legacy/{name}',
                             'sha256': '0' * 64})
        history += candidate_history(rnd, cid, status, created, 'hr.vn')
    rec.insert('candidates', candidates)
    rec.insert('candidate_documents', docs)
    rec.insert('candidate_status_history', history)

    files['currency'].insert('exchange_rates', rates.rows())
    return files


# ---------------------------------------------------------------- 5 nước còn lại

def rnd_date(rnd, year_from, year_to):
    return dt.date(rnd.randint(year_from, year_to), rnd.randint(1, 12), rnd.randint(1, 28))


def generated_timesheets(rnd, emp_ids, holidays):
    rows = []
    for emp in emp_ids:
        for day in working_days(TIMESHEET_FROM, TODAY - dt.timedelta(days=1), holidays):
            if rnd.random() < 0.04:
                continue
            check_in = dt.time(7, 30) if rnd.random() < 0.5 else dt.time(8, rnd.choice([0, 5, 10, 15, 30, 45]))
            overtime = rnd.choice([0, 0, 0, 0.5, 1, 1.5, 2])
            out_minutes = (check_in.hour * 60 + check_in.minute) + 9 * 60 + int(overtime * 60)
            rows.append({'employee_id': emp, 'work_date': day, 'check_in': check_in,
                         'check_out': dt.time(out_minutes // 60, out_minutes % 60), 'work_hours': 8,
                         'overtime_hours': overtime, 'total_hours': 8 + overtime})
    return rows


def generated_schedules(rnd, emp_ids, holidays, note):
    rows = []
    for emp in emp_ids:
        for i in range(14):
            day = TODAY + dt.timedelta(days=i)
            if day.weekday() == 5:
                continue
            is_sunday, is_holiday = day.weekday() == 6, day in holidays
            if is_sunday and rnd.random() > 0.1:
                continue
            rows.append({'employee_id': emp, 'work_date': day, 'is_sunday': is_sunday, 'is_holiday': is_holiday,
                         'pay_coefficient': 3 if is_holiday else 2 if is_sunday else 1, 'note': note})
    return rows


def generated_leaves(rnd, emp_ids, leave_types):
    rows = []
    for emp in rnd.sample(emp_ids, max(3, len(emp_ids) // 5)):
        start = TODAY + dt.timedelta(days=rnd.randint(-40, 30))
        kind, reason = rnd.choice(leave_types)
        status = 'approved' if start < TODAY else rnd.choice(['pending', 'approved'])
        rows.append({'id': uuid_from(rnd), 'employee_id': emp, 'from_date': start,
                     'to_date': start + dt.timedelta(days=rnd.randint(0, 4)), 'leave_type': kind, 'reason': reason,
                     'status': status, 'approved_by': None if status == 'pending' else 'hr'})
    return rows


def bonus_row(rates, emp, on, kind, amount, coefficient, currency):
    total = Decimal(str(amount)) * Decimal(str(coefficient))
    converted = rates.convert(total, currency, on)
    return {'employee_id': emp, 'occurred_on': on, 'kind': kind, 'amount_original': money(amount),
            'currency_original': currency, 'coefficient': coefficient, 'total_original': money(total),
            'rate_applied': converted['rate_applied'], 'rate_date': converted['rate_date'],
            'amount_base': converted['amount_base']}


def generated_bonuses(rnd, rates, emp_ids, currency, unit, taken):
    rows = []
    for emp in rnd.sample(emp_ids, max(4, len(emp_ids) // 4)):
        on = dt.date(2026, rnd.randint(6, 9), rnd.randint(1, 28))
        if (emp, on) in taken:
            continue
        kind = 'bonus' if rnd.random() < 0.75 else 'penalty'
        amount = unit * rnd.randint(1, 5)
        rows.append(bonus_row(rates, emp, on, kind, amount, 1.2 if kind == 'bonus' else 0.9, currency))
    return rows


def generated_payslips(rnd, rates, salaries, currency, tax):
    rows = []
    for period_month in (7, 8, 9):
        paid_on = dt.date(2026, period_month + 1, 5)
        for emp, base in salaries.items():
            gross = Decimal(str(base)) * Decimal(str(1 + rnd.choice([0, 0, 0.03, 0.05, 0.08])))
            net = gross * Decimal(str(1 - tax))
            converted = rates.convert(net, currency, paid_on)
            rows.append({'id': uuid_from(rnd), 'employee_id': emp, 'period': f'2026-{period_month:02d}',
                         'gross_original': money(gross), 'net_original': money(net), 'currency_original': currency,
                         'rate_applied': converted['rate_applied'], 'rate_date': converted['rate_date'],
                         'amount_base': converted['amount_base'], 'paid_on': paid_on})
    return rows


def build_region(region, cfg, rates):
    rnd = random.Random(region)
    text, cc, cur = cfg['text'], cfg['country'], cfg['currency']
    files = {s: SeedFile(s) for s in TABLES}
    prefix = cc

    def address():
        zip_code, city = rnd.choice(cfg['cities'])
        return cfg['address'].format(street=rnd.choice(cfg['streets']), no=rnd.randint(1, 250), zip=zip_code,
                                     city=city)

    def person():
        gender = rnd.randint(0, 1)
        given = rnd.choice(cfg['male'] if gender == 1 else cfg['female'])
        return gender, given, rnd.choice(cfg['family'])

    # hr
    hr = files['hr']
    branch_tier = {'DE': 'Niederlassung der TBT Center', 'BR': 'Filial da TBT Center'}.get(cc, 'Branch of TBT Center')
    companies = [{'id': f'TBT{code}', 'country_code': cc, 'name': f"{cfg['company']} – {city}",
                  'tier': branch_tier, 'address': addr} for code, city, addr in cfg['branches']]
    companies[0]['tier'] = {'DE': 'Landeszentrale', 'BR': 'Sede nacional'}.get(cc, 'Country headquarters')
    hr.insert('companies', companies)

    specialties = [{'id': f'{prefix}SP{i + 1:02d}', 'name': spec} for i, (spec, _, _) in enumerate(text['positions'])]
    hr.insert('specialties', specialties)
    degrees = [{'id': f'{prefix}DG{i + 1:02d}', 'name': n} for i, n in enumerate(text['degrees'])]
    skills = [{'id': f'{prefix}SK{i + 1:02d}', 'name': n} for i, n in enumerate(text['skills'])]
    languages = [{'id': f'{prefix}LG{i + 1:02d}', 'name': n}
                 for i, n in enumerate(cfg.get('languages') or text['languages'])]
    hr.insert('degrees', degrees)
    hr.insert('skills', skills)
    hr.insert('languages', languages)
    hr.insert('specialty_degrees', [{'specialty_id': s['id'], 'degree_id': d['id']} for s in specialties
                                    for d in rnd.sample(degrees, 2)])
    hr.insert('specialty_skills', [{'specialty_id': s['id'], 'skill_id': k['id']} for s in specialties
                                   for k in rnd.sample(skills, 3)])
    hr.insert('specialty_languages', [{'specialty_id': s['id'], 'language_id': lang['id']} for s in specialties
                                      for lang in [languages[0]] + rnd.sample(languages[1:], 1)])

    departments = []
    for c in companies:
        for i, name in enumerate(text['departments']):
            departments.append({'id': f"{c['id']}-D{i + 1:02d}", 'company_id': c['id'], 'country_code': cc,
                                'name': name, 'manager_id': None, 'location_code': None})
    positions = [{'id': f'{prefix}PS{i + 1:02d}', 'name': pos, 'specialty_id': specialties[i]['id'],
                  'salary_coefficient': coeff} for i, (_, pos, coeff) in enumerate(text['positions'])]
    hr.insert('positions', positions)

    employees, used_names = [], set()
    while len(employees) < EMPLOYEES_PER_REGION:
        gender, given, family = person()
        if (given, family) in used_names:
            continue
        used_names.add((given, family))
        idx = len(employees)
        company = companies[idx % len(companies)]
        position = positions[idx % len(positions)]
        dept_index = POSITION_TO_DEPARTMENT[idx % len(positions)]
        dept = departments[companies.index(company) * len(text['departments']) + dept_index]
        employees.append({
            'id': f"{ascii_fold(given)[:3].upper()}{rnd.randint(60, 99):02d}{idx + 1:03d}{company['id'][3:]}",
            'company_id': company['id'], 'country_code': cc, 'family_name': family, 'given_name': given,
            'birth_year': rnd.randint(1965, 2002), 'gender': gender, 'department_id': dept['id'],
            'position_id': position['id'],
            'email': ascii_fold(f'{given}.{family}').lower().replace(' ', '') + f'@{region}.tbt.local',
            'photo_url': None, 'labor_contract': rnd.choice(text['labor_contracts']),
            'hired_on': rnd_date(rnd, 2012, 2025)})
    for c in companies:
        head = next(e for e in employees if e['company_id'] == c['id'])
        for d in departments:
            if d['company_id'] == c['id']:
                d['manager_id'] = head['id']
    hr.insert('departments', departments)
    hr.insert('employees', employees)
    emp_ids = [e['id'] for e in employees]
    coefficient_of = {p['id']: p['salary_coefficient'] for p in positions}

    hr.insert('relatives', [{'employee_id': e['id'], 'full_name': ' '.join(person()[1:]), 'phone': cfg['phone'](rnd),
                             'address': address(), 'relationship': rnd.choice(text['relations'])} for e in employees])
    hr.insert('health_records', [{'employee_id': e, 'height_cm': rnd.randint(155, 195), 'weight_kg': rnd.randint(50, 100),
                                  'medical_history': rnd.choice(text['medical']), 'vision_score': rnd.randint(7, 10),
                                  'updated_on': rnd_date(rnd, 2026, 2026)} for e in emp_ids])
    hr.insert('insurances', [{'employee_id': e, 'insurance_type': rnd.choice(cfg['insurance']),
                              'insurance_number': f'{cc}{rnd.randint(10 ** 9, 10 ** 10 - 1)}',
                              'expires_on': dt.date(2027, 12, 31)} for e in emp_ids])
    hr.insert('contacts', [{'employee_id': e, 'phone': cfg['phone'](rnd), 'address': address(), 'facebook': None,
                            'x_handle': None, 'hometown_code': rnd.choice(cfg['cities'])[0]} for e in emp_ids])

    # attendance
    att = files['attendance']
    holidays = HOLIDAYS_2026[cc]
    att.insert('holidays', [{'country_code': cc, 'holiday_date': d, 'name': n} for d, n in holidays])
    holiday_days = {dt.date.fromisoformat(d) for d, _ in holidays}
    att.insert('timesheets', generated_timesheets(rnd, emp_ids, holiday_days))
    att.insert('work_schedules', generated_schedules(rnd, emp_ids, holiday_days, text['departments'][6]))
    att.insert('leave_requests', generated_leaves(rnd, emp_ids, text['leave_types']))

    # payroll
    pay = files['payroll']
    salaries = {e['id']: round(coefficient_of[e['position_id']] * cfg['salary_unit'] * rnd.uniform(0.95, 1.1), -1)
                for e in employees}
    pay.insert('salaries', [{'employee_id': e, 'employment_type': 'FT', 'base_salary': money(s), 'currency': cur}
                            for e, s in salaries.items()])
    pay.insert('coefficients', [{'id': f'{prefix}HS{i + 1:02d}', 'coefficient': c, 'reason': r}
                                for i, (r, c) in enumerate(text['coefficients'])])
    pay.insert('bonuses_penalties', generated_bonuses(rnd, rates, emp_ids, cur, cfg['salary_unit'] // 10, set()))
    pay.insert('payslips', generated_payslips(rnd, rates, salaries, cur, cfg['tax']))

    # project_contract
    pc = files['project_contract']
    customers = []
    for i in range(15):
        if i % 3 == 0:
            customers.append({'id': f'{prefix}DN{i + 1:04d}', 'country_code': cc, 'customer_type': 'business',
                              'name': f"{rnd.choice(cfg['family'])} {rnd.choice(cfg['business'])}",
                              'contact': cfg['phone'](rnd), 'address': address()})
        else:
            _, given, family = person()
            customers.append({'id': f'{prefix}CN{i + 1:04d}', 'country_code': cc, 'customer_type': 'individual',
                              'name': f'{given} {family}', 'contact': cfg['phone'](rnd), 'address': address()})
    pc.insert('customers', customers)
    contracts, projects, links, members = [], [], [], []
    for i in range(10):
        start = rnd_date(rnd, 2024, 2026)
        contract_id, project_id = f'{prefix}HD{i + 1:03d}', f'{prefix}DA{i + 1:03d}'
        contracts.append({'id': contract_id, 'country_code': cc, 'name': text['contracts'][i % len(text['contracts'])],
                          'contract_type': str(i % 4 + 1), 'start_date': start,
                          'expected_end_date': start + dt.timedelta(days=rnd.randint(120, 540))})
        acceptance = cfg['salary_unit'] * rnd.randint(40, 600)
        projects.append({'id': project_id, 'company_id': rnd.choice(companies)['id'], 'country_code': cc,
                         'customer_id': rnd.choice(customers)['id'], 'deposit_amount': money(acceptance * 0.3),
                         'expected_acceptance_amount': money(acceptance), 'currency': cur})
        link_id = f'{prefix}{start:%Y%m%d}{i:02d}'
        links.append({'id': link_id, 'project_id': project_id, 'contract_id': contract_id,
                      'end_date': start + dt.timedelta(days=rnd.randint(150, 600))})
        for emp in rnd.sample(emp_ids, 4):
            members.append({'project_contract_id': link_id, 'employee_id': emp, 'total_hours': rnd.randint(80, 220),
                            'project_salary': money(cfg['salary_unit'] * rnd.uniform(1, 3))})
    pc.insert('contracts', contracts)
    pc.insert('projects', projects)
    pc.insert('project_contracts', links)
    pc.insert('project_members', members)

    # finance
    fin = files['finance']
    areas = [{'id': f'{prefix}KV{i + 1:02d}', 'province_name': n, 'coefficient': round(0.1 * (i + 1), 2)}
             for i, n in enumerate(cfg['areas'])]
    categories = [{'id': f'{prefix}LH{i + 1:02d}', 'name': n} for i, n in enumerate(text['revenue_categories'])]
    risks = [{'id': f'{prefix}RR{i + 1:02d}', 'name': n, 'coefficient': c} for i, (n, c) in enumerate(text['risks'])]
    fin.insert('revenue_areas', areas)
    fin.insert('revenue_categories', categories)
    fin.insert('risks', risks)
    fin.insert('project_revenues', [{'project_id': p['id'], 'category_id': rnd.choice(categories)['id'],
                                     'area_id': rnd.choice(areas)['id'], 'risk_id': rnd.choice(risks)['id'],
                                     'change_coefficient': round(rnd.uniform(0.9, 1.4), 2),
                                     **rates.convert(p['expected_acceptance_amount'] * Decimal('1.1'), cur,
                                                     rnd_date(rnd, 2025, 2026))} for p in projects])
    fin.insert('service_revenues', [{'id': f'{prefix}DV{i + 1:03d}', 'customer_id': rnd.choice(customers)['id'],
                                     'service_type': rnd.choice(text['services']), 'used_on': (on := rnd_date(rnd, 2025, 2026)),
                                     'expected_price': money(cfg['salary_unit'] * 0.4),
                                     **rates.convert(cfg['salary_unit'] * rnd.uniform(0.3, 0.6), cur, on)}
                                    for i in range(8)])
    suppliers = [{'id': f'{prefix}NCC{i + 1:02d}', 'name': n, 'contact': cfg['phone'](rnd), 'address': address()}
                 for i, n in enumerate(cfg['suppliers'])]
    fin.insert('suppliers', suppliers)
    imports = [{'id': f'{prefix}N{i + 1:03d}', 'supplier_id': rnd.choice(suppliers)['id'],
                'material_name': text['materials'][i % len(text['materials'])],
                'imported_on': (on := rnd_date(rnd, 2025, 2026)),
                **rates.convert(cfg['salary_unit'] * rnd.uniform(0.5, 4), cur, on)} for i in range(8)]
    shipments = [{'id': f'{prefix}VC{i + 1:02d}', 'shipped_on': (on := rnd_date(rnd, 2025, 2026)),
                  **rates.convert(cfg['salary_unit'] * rnd.uniform(0.05, 0.3), cur, on)} for i in range(8)]
    fin.insert('material_imports', imports)
    fin.insert('material_shipments', shipments)
    fin.insert('project_costs', [{'project_id': p['id'], 'import_id': imports[i % 8]['id'],
                                  'shipment_id': shipments[i % 8]['id'],
                                  'change_coefficient': round(rnd.uniform(1, 1.2), 2),
                                  **rates.convert(cfg['salary_unit'] * rnd.uniform(1, 6), cur, rnd_date(rnd, 2025, 2026))}
                                 for i, p in enumerate(projects)])
    fin.insert('market_fluctuations', [{'observed_on': dt.date(2026, m, 5), 'coefficient': round(rnd.uniform(0.1, 0.9), 2)}
                                       for m in range(1, 10)])

    # recruitment
    rec = files['recruitment']
    candidates, history = [], []
    for i in range(10):
        _, given, family = person()
        cid = uuid_from(rnd)
        status = rnd.choice(PIPELINE)
        created = dt.datetime(2026, rnd.randint(6, 10), rnd.randint(1, 14), rnd.randint(8, 17))
        candidates.append({'id': cid, 'country_code': cc, 'full_name': f'{given} {family}',
                           'email': ascii_fold(f'{given}.{family}.{i}').lower().replace(' ', '') + '@example.com',
                           'phone': cfg['phone'](rnd), 'applied_position': rnd.choice(positions)['name'],
                           'status': status, 'source': 'self', 'cv_object_key': None, 'consent_ai': True,
                           'created_at': created.isoformat(sep=' ')})
        history += candidate_history(rnd, cid, status, created, f'hr.{region}')
    rec.insert('candidates', candidates)
    rec.insert('candidate_status_history', history)

    files['currency'].insert('exchange_rates', rates.rows())
    return files


def main():
    sys.stdout.reconfigure(encoding='utf-8')
    rates = Rates()
    legacy = sqlite3.connect(f'file:{LEGACY_DB}?mode=ro', uri=True)
    legacy.row_factory = sqlite3.Row
    print('vn: từ dữ liệu cũ')
    for f in build_vn(legacy, rates).values():
        f.write('vn')
    for region, cfg in REGIONS.items():
        print(f'{region}: sinh mới')
        for f in build_region(region, cfg, rates).values():
            f.write(region)
    print(f'Xong, xem deploy/seed/')


if __name__ == '__main__':
    main()
