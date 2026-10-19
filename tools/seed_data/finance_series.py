# Họ tên: Nguyễn Tâm Bình
# MSSV:   2324801030003
# Môn:    Kiến trúc và thiết kế phần mềm
# Bài:    Đồ án TBT Center đa quốc gia
# Ngày:   2026-10-19
"""Sinh chuỗi thu chi theo tháng (01/2025–10/2026) cho 6 khu vực vào deploy/seed/<region>/finance_series.sql.

Doanh thu dịch vụ, nhập vật liệu, vận chuyển và trả nhà cung cấp rải đều các ngày trong tháng, có mùa vụ và dao động ngẫu nhiên.
Chạy được nhiều lần trên CSDL đang có dữ liệu: mã cố định, trùng thì bỏ qua, không ghi vào tháng đã chốt sổ.
Chạy: python tools/seed_data/finance_series.py
"""

import calendar
import datetime as dt
import math
import random
import uuid
from decimal import Decimal
from pathlib import Path

from generate import ROOT, Rates, money, sql_value
from locales import REGIONS

FIRST = dt.date(2025, 1, 1)
LAST = dt.date(2026, 10, 15)

# Doanh thu tháng quy USD (thấp, cao) theo quy mô từng nước
SCALE = {'vn': (380_000, 760_000), 'de': (520_000, 980_000), 'us': (600_000, 1_150_000),
         'br': (260_000, 540_000), 'za': (190_000, 420_000), 'au': (380_000, 760_000)}
CURRENCY = {'vn': 'VND', **{k: v['currency'] for k, v in REGIONS.items()}}
TEXT = {
    'vn': {'services': ['THI CÔNG', 'BẢO DƯỠNG', 'SỬA CHỮA', 'SƠN SỬA NHÀ'],
           'materials': ['Xi măng PCB40', 'Thép cây D16', 'Thép cuộn D10', 'Bê tông thương phẩm M300', 'Gạch ống 8x18',
                         'Cát xây dựng', 'Đá 1x2']},
    **{k: {'services': v['text']['services'], 'materials': v['text']['materials']} for k, v in REGIONS.items()},
}

# Lấy mã có sẵn trong CSDL để không phụ thuộc cách đặt mã của từng nước
CUSTOMER = ("(select customer_id from (select distinct customer_id from service_revenues where id not like 'FS-%%') c "
            "order by customer_id offset (%d %% greatest((select count(distinct customer_id) from service_revenues "
            "where id not like 'FS-%%'), 1)) limit 1)")
SUPPLIER = ("(select id from suppliers order by id offset (%d %% greatest((select count(*) from suppliers), 1)) limit 1)")


def season(month_index, month):
    """Mùa vụ xây dựng: cao giữa năm, thấp dịp Tết và cuối năm, cộng xu hướng tăng nhẹ"""
    wave = 1 + 0.22 * math.sin((month - 3) / 12 * 2 * math.pi)
    trend = 1 + 0.012 * month_index
    return wave * trend


def months():
    day = FIRST
    while day <= LAST:
        yield day
        day = (day.replace(day=28) + dt.timedelta(days=4)).replace(day=1)


def spread_days(rnd, month_start, count):
    last = calendar.monthrange(month_start.year, month_start.month)[1]
    if month_start.year == LAST.year and month_start.month == LAST.month:
        last = LAST.day
    return sorted(month_start.replace(day=rnd.randint(1, last)) for _ in range(count))


def guarded(table, columns, values, period):
    cols = ', '.join(columns)
    vals = ', '.join(values)
    return (f"insert into {table} ({cols}) select {vals} "
            f"where not exists (select 1 from period_closings where period = '{period}') on conflict do nothing;")


def build(region):
    rnd = random.Random(f'finance-series-{region}')
    rates = Rates()
    cur = CURRENCY[region]
    low, high = SCALE[region]
    text = TEXT[region]
    lines = [f'-- Sinh tự động bởi tools/seed_data/finance_series.py, khu vực {region}. Không sửa tay.', 'begin;']
    for idx, month in enumerate(months()):
        period = month.strftime('%Y-%m')
        tag = month.strftime('%y%m')
        target = rnd.uniform(low, high) * season(idx, month.month)
        cost_ratio = rnd.uniform(0.58, 0.88)

        # Doanh thu dịch vụ: 4–7 khoản, chia không đều
        n = rnd.randint(4, 7)
        weights = [rnd.uniform(0.4, 1.6) for _ in range(n)]
        for i, (day, w) in enumerate(zip(spread_days(rnd, month, n), weights)):
            usd = target * w / sum(weights)
            row = rates.convert(Decimal(str(usd)) * rates.table[(day, cur)], cur, day)
            lines.append(guarded('service_revenues',
                                 ['id', 'customer_id', 'service_type', 'used_on', 'expected_price', 'amount_original',
                                  'currency_original', 'rate_applied', 'rate_date', 'amount_base'],
                                 [sql_value(f'FS-DV{tag}{i:02d}'), CUSTOMER % rnd.randint(0, 999),
                                  sql_value(rnd.choice(text['services'])), sql_value(day),
                                  sql_value(money(row['amount_original'] * Decimal(str(rnd.uniform(0.9, 1.15))))),
                                  sql_value(row['amount_original']), sql_value(cur), sql_value(row['rate_applied']),
                                  sql_value(row['rate_date']), sql_value(row['amount_base'])], period))

        # Chi phí: nhập vật liệu (85%) và vận chuyển (15%)
        cost = target * cost_ratio
        n = rnd.randint(4, 8)
        weights = [rnd.uniform(0.5, 1.5) for _ in range(n)]
        imports = []
        for i, (day, w) in enumerate(zip(spread_days(rnd, month, n), weights)):
            usd = cost * 0.85 * w / sum(weights)
            row = rates.convert(Decimal(str(usd)) * rates.table[(day, cur)], cur, day)
            supplier = rnd.randint(0, 999)
            imports.append((day, supplier, row['amount_original']))
            lines.append(guarded('material_imports',
                                 ['id', 'supplier_id', 'material_name', 'imported_on', 'amount_original',
                                  'currency_original', 'rate_applied', 'rate_date', 'amount_base'],
                                 [sql_value(f'FS-N{tag}{i:02d}'), SUPPLIER % supplier,
                                  sql_value(rnd.choice(text['materials'])), sql_value(day),
                                  sql_value(row['amount_original']), sql_value(cur), sql_value(row['rate_applied']),
                                  sql_value(row['rate_date']), sql_value(row['amount_base'])], period))
        n = rnd.randint(2, 4)
        for i, day in enumerate(spread_days(rnd, month, n)):
            usd = cost * 0.15 / n * rnd.uniform(0.7, 1.3)
            row = rates.convert(Decimal(str(usd)) * rates.table[(day, cur)], cur, day)
            lines.append(guarded('material_shipments',
                                 ['id', 'shipped_on', 'amount_original', 'currency_original', 'rate_applied',
                                  'rate_date', 'amount_base'],
                                 [sql_value(f'FS-VC{tag}{i:02d}'), sql_value(day), sql_value(row['amount_original']),
                                  sql_value(cur), sql_value(row['rate_applied']), sql_value(row['rate_date']),
                                  sql_value(row['amount_base'])], period))

        # Trả nhà cung cấp 60–95% tiền hàng, 10–35 ngày sau khi nhập
        for i, (day, supplier, amount) in enumerate(imports):
            paid = day + dt.timedelta(days=rnd.randint(10, 35))
            if paid > LAST:
                continue
            row = rates.convert(amount * Decimal(str(rnd.uniform(0.6, 0.95))), cur, paid)
            pay_id = uuid.uuid5(uuid.NAMESPACE_URL, f'tbt/{region}/FS-N{tag}{i:02d}')
            lines.append(guarded('supplier_payments',
                                 ['id', 'supplier_id', 'paid_on', 'amount_original', 'currency_original',
                                  'rate_applied', 'rate_date', 'amount_base', 'note', 'recorded_by'],
                                 [sql_value(str(pay_id)), SUPPLIER % supplier, sql_value(paid),
                                  sql_value(row['amount_original']), sql_value(cur), sql_value(row['rate_applied']),
                                  sql_value(row['rate_date']), sql_value(row['amount_base']),
                                  sql_value(f'Thanh toán FS-N{tag}{i:02d}'), sql_value(f'finance.{region}')],
                                 paid.strftime('%Y-%m')))
    lines.append('commit;')
    return '\n'.join(lines) + '\n'


def main():
    for region in CURRENCY:
        out = ROOT / 'deploy' / 'seed' / region / 'finance_series.sql'
        out.write_text(build(region), encoding='utf-8', newline='\n')
        print(region, out.relative_to(ROOT), sum(1 for _ in out.open(encoding='utf-8')) - 3, 'dòng')


if __name__ == '__main__':
    main()
