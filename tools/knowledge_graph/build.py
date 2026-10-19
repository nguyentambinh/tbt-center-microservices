"""
Họ tên: Nguyễn Tâm Bình
MSSV:   2324801030003
Môn:    Kiến trúc và thiết kế phần mềm
Bài:    Đồ án TBT Center đa quốc gia
Ngày:   2026-10-18

Sinh bản thể học và đồ thị tri thức (services/knowledge/migrations/006_graph_seed.sql).
Quan hệ lấy đúng theo quy tắc đang chạy trong code, sửa đồ thị thì sửa file này.
Nút, cạnh do AI trích xuất (origin = extracted) không bị file sinh ra xóa.
"""
import json
import unicodedata
from pathlib import Path

OUT = Path(__file__).resolve().parents[2] / 'services/knowledge/migrations/006_graph_seed.sql'


def L(vi, en, de=None, pt=None):
    return (vi, en, de or en, pt or en)


# Lớp (bản thể học): mã -> lớp cha, nhãn, loại hiển thị trong app
CLASSES = [
    ('thing', None, L('Sự vật', 'Thing', 'Ding', 'Coisa')),
    ('agent', 'thing', L('Tác nhân', 'Agent', 'Akteur', 'Agente')),
    ('role', 'agent', L('Vai trò', 'Role', 'Rolle', 'Papel')),
    ('activity', 'thing', L('Hoạt động', 'Activity', 'Aktivität', 'Atividade')),
    ('process', 'activity', L('Quy trình', 'Process', 'Prozess', 'Processo')),
    ('step', 'activity', L('Bước', 'Step', 'Schritt', 'Etapa')),
    ('information', 'thing', L('Thông tin', 'Information', 'Information', 'Informação')),
    ('concept', 'information', L('Khái niệm', 'Concept', 'Begriff', 'Conceito')),
    ('request', 'concept', L('Đơn yêu cầu', 'Request', 'Antrag', 'Pedido')),
    ('amount', 'concept', L('Khoản tiền', 'Monetary amount', 'Geldbetrag', 'Valor monetário')),
    ('record', 'concept', L('Hồ sơ dữ liệu', 'Data record', 'Datensatz', 'Registro')),
    ('currency', 'concept', L('Đồng tiền', 'Currency', 'Währung', 'Moeda')),
    ('language', 'concept', L('Ngôn ngữ', 'Language', 'Sprache', 'Idioma')),
    ('rule', 'information', L('Quy tắc', 'Rule', 'Regel', 'Regra')),
    ('document', 'information', L('Bài viết', 'Article', 'Artikel', 'Artigo')),
    ('system', 'thing', L('Thành phần hệ thống', 'System component', 'Systemkomponente', 'Componente do sistema')),
    ('service', 'system', L('Service', 'Service', 'Dienst', 'Serviço')),
    ('technology', 'system', L('Công nghệ', 'Technology', 'Technologie', 'Tecnologia')),
    ('pattern', 'thing', L('Mẫu kiến trúc', 'Architecture pattern', 'Architekturmuster', 'Padrão de arquitetura')),
    ('place', 'thing', L('Nơi chốn', 'Place', 'Ort', 'Local')),
    ('region', 'place', L('Nước (khu vực)', 'Country region', 'Länderregion', 'Região do país')),
]
# Loại hiển thị (màu nút trong app): lớp gần nhất có trong danh sách này
DISPLAY = ['request', 'amount', 'record', 'currency', 'language', 'concept', 'process', 'step', 'rule', 'role',
           'service', 'technology', 'pattern', 'region', 'place', 'document']
DISPLAY_AS = {'request': 'concept', 'amount': 'concept', 'record': 'concept', 'currency': 'concept',
              'language': 'concept', 'place': 'region'}

# Quan hệ: mã -> nhãn, miền (domain), phạm vi (range), tính chất, giải thích
# derived = chỉ do suy luận sinh ra, người và AI không ghi trực tiếp
RELATIONS = {
    'part_of': (L('thuộc', 'part of', 'Teil von', 'parte de'), ['thing'], ['thing'],
                {'transitive': True, 'inverse': 'has_part'}, ('A là một phần của B.', 'A is a part of B.')),
    'has_part': (L('gồm phần', 'has part', 'enthält', 'contém'), ['thing'], ['thing'], {'derived': True},
                 ('B là một phần của A (chiều ngược của thuộc).', 'B is a part of A (inverse of part of).')),
    'step_of': (L('là bước của', 'step of', 'Schritt von', 'etapa de'), ['step'], ['process'], {'inverse': 'has_step'},
                ('A là một bước trong quy trình B.', 'A is a step of process B.')),
    'has_step': (L('gồm bước', 'has step', 'hat Schritt', 'tem etapa'), ['process'], ['step'], {'derived': True},
                 ('Quy trình A có bước B (suy ra từ "là bước của").', 'Process A has step B (inverse of step of).')),
    'next_step': (L('bước kế tiếp', 'next step', 'nächster Schritt', 'próxima etapa'), ['step'], ['step'],
                  {'sub_of': 'precedes'}, ('Ngay sau bước A là bước B.', 'Step B comes right after step A.')),
    'precedes': (L('đứng trước', 'precedes', 'kommt vor', 'precede'), ['step'], ['step'],
                 {'transitive': True, 'derived': True},
                 ('Bước A làm trước bước B (có thể cách nhiều bước).', 'Step A happens before step B, possibly several steps earlier.')),
    'calculated_from': (L('tính từ', 'calculated from', 'berechnet aus', 'calculado a partir de'), ['concept', 'rule'],
                        ['concept', 'rule'], {'transitive': True}, ('Giá trị A được tính từ B.', 'A is calculated from B.')),
    'approved_by': (L('do ai duyệt', 'approved by', 'genehmigt von', 'aprovado por'), ['request', 'step'], ['role'],
                    {'inverse': 'approves'}, ('Vai trò B được duyệt A.', 'Role B may approve A.')),
    'approves': (L('được duyệt', 'approves', 'genehmigt', 'aprova'), ['role'], ['request', 'step'], {'derived': True},
                 ('Vai trò A được duyệt B.', 'Role A may approve B.')),
    'created_by': (L('do ai tạo', 'created by', 'erstellt von', 'criado por'), ['concept'], ['role', 'request'], {},
                   ('A do B tạo ra.', 'A is created by B.')),
    'started_by': (L('do ai khởi động', 'started by', 'gestartet von', 'iniciado por'), ['process'], ['role'], {},
                   ('Vai trò B được bắt đầu quy trình A.', 'Role B may start process A.')),
    'handled_by': (L('service xử lý', 'handled by', 'verarbeitet von', 'processado por'), ['thing'], ['service'],
                   {'inverse': 'handles'}, ('Service B xử lý A.', 'Service B handles A.')),
    'handles': (L('xử lý', 'handles', 'verarbeitet', 'processa'), ['service'], ['thing'], {'derived': True},
                ('Service A xử lý B.', 'Service A handles B.')),
    'blocks': (L('tạm chặn', 'blocks', 'blockiert', 'bloqueia'), ['rule', 'step'], ['request'], {},
               ('A làm B tạm thời không duyệt được.', 'A temporarily blocks B.')),
    'produces': (L('tạo ra', 'produces', 'erzeugt', 'gera'), ['activity'], ['thing'], {},
                 ('Hoạt động A tạo ra B.', 'Activity A produces B.')),
    'notifies': (L('báo cho', 'notifies', 'benachrichtigt', 'notifica'), ['activity', 'request'], ['role', 'concept'], {},
                 ('A gửi thông báo cho B.', 'A sends a notification to B.')),
    'explained_in': (L('giải thích trong bài', 'explained in', 'erklärt in', 'explicado em'), ['thing'], ['document'], {},
                     ('A được giải thích trong bài viết B.', 'A is explained in article B.')),
    'protects': (L('bảo vệ', 'protects', 'schützt', 'protege'), ['rule', 'concept', 'technology', 'pattern'], ['concept'],
                 {}, ('A bảo vệ B.', 'A protects B.')),
    'has_rate': (L('tỷ lệ khấu trừ', 'deduction rate', 'Abzugssatz', 'taxa de dedução'), ['region'], ['concept'], {},
                 ('Nước A áp tỷ lệ cho B, giá trị ghi trên cạnh.', 'Country A applies a rate to B; the value is on the edge.')),
    'becomes': (L('trở thành', 'becomes', 'wird zu', 'torna-se'), ['role'], ['role'], {},
                ('Vai trò A chuyển thành vai trò B.', 'Role A turns into role B.')),
    'can_view': (L('được xem', 'can view', 'kann einsehen', 'pode ver'), ['role'], ['concept', 'document'], {},
                 ('Vai trò A được xem B.', 'Role A may view B.')),
    'undone_by': (L('hoàn tác bằng', 'undone by', 'rückgängig durch', 'desfeito por'), ['step'], ['concept'], {},
                  ('Bước A được hoàn tác bằng B.', 'Step A is undone by B.')),
    'related_to': (L('liên quan', 'related to', 'verwandt mit', 'relacionado a'), ['thing'], ['thing'], {'symmetric': True},
                   ('A và B liên quan với nhau.', 'A and B are related.')),
    'uses': (L('dùng công nghệ', 'uses', 'nutzt', 'usa'), ['activity', 'concept', 'service', 'pattern'], ['technology'], {},
             ('A dùng công nghệ B.', 'A uses technology B.')),
    'implements': (L('áp dụng mẫu', 'implements', 'setzt um', 'implementa'), ['service', 'process', 'concept', 'technology'],
                   ['pattern'], {}, ('A áp dụng mẫu kiến trúc B.', 'A implements architecture pattern B.')),
    'runs_in': (L('chạy ở', 'runs in', 'läuft in', 'executa em'), ['service', 'technology'], ['place'], {},
                ('A chạy ở nơi B.', 'A runs in place B.')),
    'located_in': (L('đặt tại', 'located in', 'befindet sich in', 'localizado em'), ['place'], ['place'], {'transitive': True},
                   ('Nơi A nằm trong nơi B.', 'Place A is located in place B.')),
    'depends_on': (L('gọi tới', 'depends on', 'hängt ab von', 'depende de'), ['service'], ['service'], {'transitive': True},
                   ('Service A cần gọi service B để làm việc.', 'Service A calls service B to do its work.')),
    'involves': (L('có sự tham gia của', 'involves', 'bezieht ein', 'envolve'), ['process'], ['service'], {'derived': True},
                 ('Quy trình A cần service B chạy được.', 'Process A needs service B to run.')),
    'has_currency': (L('dùng đồng tiền', 'uses currency', 'Währung', 'usa a moeda'), ['region'], ['currency'], {},
                     ('Nước A dùng đồng tiền B.', 'Country A uses currency B.')),
    'default_language': (L('ngôn ngữ mặc định', 'default language', 'Standardsprache', 'idioma padrão'), ['region'],
                         ['language'], {}, ('App ở nước A mặc định ngôn ngữ B.', 'The app defaults to language B in country A.')),
    'stored_in': (L('lưu ở', 'stored in', 'gespeichert in', 'armazenado em'), ['concept'], ['technology', 'place'], {},
                  ('Dữ liệu A lưu ở B.', 'Data A is stored in B.')),
}

# Luật suy luận, viết được bằng OWL 2 (transitive, symmetric, inverseOf, subPropertyOf, propertyChainAxiom)
# chain: (a first b) và (b second c) thì (a result c)
# visible = cạnh suy ra có hiện trên hình đồ thị và trong ngữ cảnh cho AI không
RULES = []
for rid, (_, _, _, props, _) in RELATIONS.items():
    if props.get('transitive'):
        RULES.append((f'{rid}-transitive', 'transitive', rid, None, rid, rid not in ('precedes', 'located_in'),
                      L(f'"{RELATIONS[rid][0][0]}" có tính bắc cầu', f'"{rid}" is transitive')))
    if props.get('symmetric'):
        RULES.append((f'{rid}-symmetric', 'symmetric', rid, None, rid, False,
                      L(f'"{RELATIONS[rid][0][0]}" có tính đối xứng', f'"{rid}" is symmetric')))
    if props.get('inverse'):
        inv = props['inverse']
        RULES.append((f'{rid}-inverse', 'inverse', rid, None, inv, False,
                      L(f'"{RELATIONS[inv][0][0]}" là chiều ngược của "{RELATIONS[rid][0][0]}"', f'"{inv}" is the inverse of "{rid}"')))
    if props.get('sub_of'):
        sup = props['sub_of']
        RULES.append((f'{rid}-sub-{sup}', 'subproperty', rid, None, sup, False,
                      L(f'"{RELATIONS[rid][0][0]}" kéo theo "{RELATIONS[sup][0][0]}"', f'"{rid}" implies "{sup}"')))
RULES += [
    ('steps-involve-services', 'chain', 'has_step', 'handled_by', 'involves', True,
     L('Quy trình có bước do service S xử lý thì quy trình có sự tham gia của S',
       'A process whose step is handled by service S involves S')),
    ('involve-dependencies', 'chain', 'involves', 'depends_on', 'involves', True,
     L('Quy trình cần service S, S gọi service T thì quy trình cũng cần T',
       'If a process involves S and S depends on T, the process involves T')),
    ('view-parts', 'chain', 'can_view', 'has_part', 'can_view', True,
     L('Được xem cái tổng thì được xem phần nằm trong nó', 'Whoever can view a whole can view its parts')),
    ('protect-parts', 'chain', 'protects', 'has_part', 'protects', True,
     L('Bảo vệ cái tổng thì bảo vệ cả phần nằm trong nó', 'Protecting a whole protects its parts')),
    ('produced-blockers', 'chain', 'produces', 'blocks', 'blocks', True,
     L('Bước tạo ra quy tắc chặn đơn thì chính bước đó chặn đơn', 'A step that produces a blocking rule blocks the same requests')),
    ('runs-in-located', 'chain', 'runs_in', 'located_in', 'runs_in', False,
     L('Chạy ở nơi A, A nằm trong B thì chạy ở B', 'Running in A, and A is located in B, means running in B')),
]

# Nút: mã, lớp, nhãn (vi, en, de, pt), tên gọi khác, tóm tắt (vi, en)
NODES = [
    # Lương
    ('overtime', 'concept', ('Tăng ca', 'Overtime', 'Überstunden', 'Horas extras'),
     ['lam them gio', 'lam them', 'ngoai gio', 'extra hours', 'uberstunde'],
     ('Giờ làm thêm ngoài giờ chuẩn, chỉ được trả khi đơn tăng ca đã duyệt.',
      'Hours worked beyond standard hours, paid only when the overtime request is approved.')),
    ('overtime-pay', 'rule', ('Tiền tăng ca = giờ tăng ca × 1,5 × lương giờ', 'Overtime pay = hours × 1.5 × hourly rate',
                              'Überstundenlohn = Stunden × 1,5 × Stundenlohn', 'Hora extra = horas × 1,5 × valor-hora'),
     ['tien tang ca', 'luong tang ca', 'he so tang ca', 'he so 1,5', 'overtime pay', 'overtime rate'],
     ('Mỗi giờ tăng ca đã duyệt tính bằng 1,5 lần lương giờ.',
      'Each approved overtime hour is paid at 1.5 times the hourly rate.')),
    ('hourly-rate', 'rule', ('Lương giờ = lương tháng ÷ 176', 'Hourly rate = monthly salary ÷ 176',
                             'Stundenlohn = Monatsgehalt ÷ 176', 'Valor-hora = salário mensal ÷ 176'),
     ['luong gio', 'luong theo gio', 'don gia gio', 'hourly rate', 'hourly pay'],
     ('Lương giờ bằng lương tháng chia 176 giờ chuẩn.', 'Hourly rate is the monthly salary divided by 176 standard hours.')),
    ('base-salary', 'amount', ('Lương cơ bản', 'Base salary', 'Grundgehalt', 'Salário base'),
     ['luong thang', 'luong co ban', 'monthly salary', 'base pay'],
     ('Lương tháng ghi trong hồ sơ lương của nhân viên.', 'Monthly salary recorded in the employee pay profile.')),
    ('gross-pay', 'amount', ('Lương gộp', 'Gross pay', 'Bruttolohn', 'Salário bruto'),
     ['luong gop', 'tong luong', 'gross', 'gross salary'],
     ('Lương cơ bản cộng tiền tăng ca và thưởng, trừ phạt, trước khấu trừ.',
      'Base salary plus overtime and bonuses, minus penalties, before deductions.')),
    ('bonus-penalty', 'amount', ('Thưởng và phạt', 'Bonuses and penalties', 'Prämien und Abzüge', 'Bônus e penalidades'),
     ['thuong', 'phat', 'thuong phat', 'bonus', 'penalty'],
     ('Khoản thưởng cộng vào và khoản phạt trừ ra khi tính lương gộp.',
      'Bonuses are added and penalties subtracted when computing gross pay.')),
    ('deduction', 'amount', ('Khấu trừ', 'Deductions', 'Abzüge', 'Deduções'),
     ['khau tru', 'thue', 'bao hiem', 'tax', 'deduction'],
     ('Tỷ lệ khấu trừ ước tính theo từng nước (mô phỏng trong đồ án, chưa phải biểu thuế thật).',
      'Estimated deduction rate per country (simulated, not the real tax tables).')),
    ('net-pay', 'amount', ('Lương thực nhận', 'Net pay', 'Nettolohn', 'Salário líquido'),
     ['thuc nhan', 'thuc linh', 'luong net', 'net', 'take home'],
     ('Lương gộp trừ khấu trừ ước tính của nước nơi nhân viên làm việc.',
      'Gross pay minus the estimated deduction of the employee\'s country.')),
    ('payslip', 'record', ('Phiếu lương', 'Payslip', 'Gehaltsabrechnung', 'Holerite'),
     ['phieu luong', 'bang luong', 'payslip', 'pay slip'],
     ('Bảng chi tiết lương của một kỳ; nhân viên xem phiếu của mình, HR và tài chính xem được tất cả.',
      'Pay detail for one period; employees see their own, HR and finance see all.')),
    ('payroll-period', 'concept', ('Kỳ lương', 'Payroll period', 'Abrechnungszeitraum', 'Período da folha'),
     ['ky luong', 'thang luong', 'pay period'],
     ('Một tháng tính lương, ví dụ 2026-10.', 'One pay month, for example 2026-10.')),
    ('exchange-rate', 'concept', ('Tỷ giá nội bộ', 'Internal exchange rate', 'Interner Wechselkurs', 'Câmbio interno'),
     ['ty gia', 'doi tien', 'exchange rate'],
     ('Tỷ giá dùng để quy đổi chi phí lương về một đồng tiền khi tổng hợp.',
      'Rate used to convert payroll cost into one currency for consolidation.')),
    ('payroll-budget', 'amount', ('Ngân sách lương', 'Payroll budget', 'Lohnbudget', 'Orçamento da folha'),
     ['ngan sach luong', 'payroll budget'],
     ('Khoản tiền tài chính giữ trước cho một kỳ lương; vượt ngân sách thì không chốt được.',
      'Money finance reserves for one payroll period; payroll above the budget cannot be closed.')),
    ('payroll-expense', 'amount', ('Chi phí lương', 'Payroll expense', 'Lohnaufwand', 'Despesa da folha'),
     ['chi phi luong', 'payroll expense'],
     ('Khoản chi lương ghi vào sổ tài chính sau khi đã chi qua ngân hàng.',
      'Payroll cost recorded in the finance books after the bank payment.')),
    # Saga chốt lương
    ('payroll-closing', 'process', ('Chốt lương', 'Payroll closing', 'Lohnabschluss', 'Fechamento da folha'),
     ['chot luong', 'tra luong', 'chi luong', 'payroll run'],
     ('Quy trình nhiều bước (Saga) tính và chi lương một kỳ, lỗi giữa chừng thì hoàn tác các bước trước.',
      'Multi-step process (Saga) that calculates and pays one period, undoing earlier steps on failure.')),
    ('step-lock', 'step', ('1. Khóa kỳ', '1. Lock period', '1. Zeitraum sperren', '1. Bloquear período'),
     ['khoa ky'], ('Khóa kỳ ở chấm công để giờ công không đổi trong lúc tính.', 'Locks the period in attendance so hours do not change.')),
    ('step-hours', 'step', ('2. Lấy giờ công', '2. Collect hours', '2. Stunden erfassen', '2. Coletar horas'),
     ['lay gio cong', 'gio cong'], ('Lấy giờ làm và giờ tăng ca đã duyệt.', 'Collects worked hours and approved overtime.')),
    ('step-rate', 'step', ('3. Lấy tỷ giá', '3. Fetch exchange rate', '3. Wechselkurs holen', '3. Obter câmbio'),
     [], ('Lấy tỷ giá từ service currency.', 'Fetches the rate from the currency service.')),
    ('step-calculate', 'step', ('4. Tính phiếu nháp', '4. Calculate drafts', '4. Entwürfe berechnen', '4. Calcular rascunhos'),
     ['tinh luong'], ('Tính lương gộp, khấu trừ, thực nhận cho từng người.', 'Calculates gross, deductions and net per person.')),
    ('step-budget', 'step', ('5. Giữ ngân sách', '5. Reserve budget', '5. Budget reservieren', '5. Reservar orçamento'),
     ['giu ngan sach'], ('Giữ trước ngân sách lương ở tài chính; hoàn tác được.', 'Reserves the payroll budget in finance; can be undone.')),
    ('step-pay', 'step', ('6. Chi qua ngân hàng', '6. Pay via bank', '6. Über Bank zahlen', '6. Pagar pelo banco'),
     ['chuyen khoan', 'ngan hang', 'bank'],
     ('Bước không quay lại (pivot): đã chi thì chỉ đi tiếp; không rõ kết quả thì đối soát cùng mã tham chiếu.',
      'Point of no return (pivot): once paid only move forward; unknown results are reconciled by reference.')),
    ('step-expense', 'step', ('7. Ghi chi phí lương', '7. Record expense', '7. Aufwand buchen', '7. Registrar despesa'),
     [], ('Ghi chi phí lương vào sổ tài chính; thử lại đến khi được.', 'Records the payroll expense; retried until it succeeds.')),
    ('step-payslips', 'step', ('8. Phát phiếu lương', '8. Issue payslips', '8. Abrechnungen ausgeben', '8. Emitir holerites'),
     [], ('Phát phiếu lương và báo cho từng nhân viên.', 'Issues payslips and notifies each employee.')),
    ('step-unlock', 'step', ('9. Mở khóa kỳ', '9. Unlock period', '9. Zeitraum entsperren', '9. Desbloquear período'),
     ['mo khoa ky'], ('Mở khóa kỳ để duyệt đơn lại bình thường.', 'Unlocks the period so approvals work again.')),
    ('compensation', 'concept', ('Bù trừ (hoàn tác)', 'Compensation (undo)', 'Kompensation', 'Compensação'),
     ['hoan tac', 'bu tru', 'rollback', 'compensate'],
     ('Bước lỗi trước khi chi thì hệ thống chạy ngược: trả ngân sách, mở khóa kỳ.',
      'If a step fails before paying, the system runs backwards: releases budget, unlocks period.')),
    ('period-lock', 'rule', ('Khóa kỳ khi đang chốt lương', 'Period lock during payroll closing',
                             'Sperre während Lohnabschluss', 'Bloqueio durante fechamento'),
     ['ky dang chot', 'khong duyet duoc', 'period locked', 'locked period'],
     ('Đang chốt lương thì đơn nghỉ và đơn tăng ca trong kỳ đó tạm thời không duyệt được.',
      'While closing, leave and overtime requests in that period cannot be approved.')),
    # Chấm công
    ('attendance', 'record', ('Chấm công', 'Attendance', 'Zeiterfassung', 'Ponto'),
     ['cham cong', 'vao ca', 'ra ca', 'check in', 'clock in', 'clock out'],
     ('Một nút: lần đầu vào ca, lần sau ra ca; vào ca ít nhất 5 phút mới ra ca được.',
      'One button: first tap clocks in, next clocks out; wait at least 5 minutes before clocking out.')),
    ('shift', 'concept', ('Ca làm', 'Shift', 'Schicht', 'Turno'),
     ['ca lam', 'shift'], ('Khung giờ làm việc dùng khi chấm công.', 'Working time window used for attendance.')),
    ('holiday', 'concept', ('Ngày lễ', 'Public holidays', 'Feiertage', 'Feriados'),
     ['ngay le', 'ngay nghi le', 'holiday'], ('Danh sách ngày lễ theo năm của từng nước.', 'Yearly list of public holidays per country.')),
    ('leave-request', 'request', ('Đơn nghỉ phép', 'Leave request', 'Urlaubsantrag', 'Pedido de férias'),
     ['nghi phep', 'xin nghi', 'don nghi', 'nghi om', 'leave', 'day off', 'urlaub'],
     ('Chọn ngày bắt đầu, kết thúc, loại nghỉ và lý do; đơn trùng thời gian bị từ chối; không tự duyệt đơn của mình.',
      'Pick start, end, type and reason; overlapping requests are rejected; nobody approves their own.')),
    ('overtime-request', 'request', ('Đơn tăng ca', 'Overtime request', 'Überstundenantrag', 'Pedido de horas extras'),
     ['dang ky tang ca', 'don tang ca', 'xin tang ca', 'overtime request'],
     ('Đăng ký tăng ca theo ngày, số giờ và lý do.', 'Request overtime by date, hours and reason.')),
    # Tuyển dụng
    ('recruitment', 'process', ('Tuyển dụng', 'Recruitment', 'Rekrutierung', 'Recrutamento'),
     ['tuyen dung', 'ung tuyen', 'hiring', 'recruiting'],
     ('Hồ sơ đi qua: đã nộp, AI tóm tắt, sàng lọc, phỏng vấn, mời nhận việc, nhận vào làm.',
      'Applications move through submitted, AI summary, screening, interview, offer, hire.')),
    ('cv', 'record', ('CV', 'CV', 'Lebenslauf', 'Currículo'), ['so yeu ly lich', 'resume'],
     ('Ứng viên tải CV lên khi nộp hồ sơ.', 'Candidates upload a CV when applying.')),
    ('ai-summary', 'concept', ('Bản tóm tắt CV bằng AI', 'AI CV summary', 'KI-Zusammenfassung', 'Resumo por IA'),
     ['tom tat cv', 'ai tom tat'], ('Claude tóm tắt CV cho HR; Claude lỗi thì dùng Gemini dự phòng. AI không chấm đậu rớt.',
                                   'Claude summarises the CV for HR; Gemini is the fallback. The AI never decides pass or fail.')),
    ('submitted', 'step', ('Đã nộp hồ sơ', 'Application submitted', 'Bewerbung eingereicht', 'Candidatura enviada'),
     ['da nop', 'nop ho so'], ('Ứng viên đã nộp hồ sơ và CV.', 'The candidate has submitted the application and CV.')),
    ('ai-review', 'step', ('AI tóm tắt CV', 'AI summarises CV', 'KI fasst Lebenslauf zusammen', 'IA resume o currículo'),
     [], ('Bước chạy nền: AI đọc CV và viết bản tóm tắt cho HR.', 'Background step: the AI reads the CV and writes a summary for HR.')),
    ('screening', 'step', ('Sàng lọc', 'Screening', 'Vorauswahl', 'Triagem'), ['sang loc'],
     ('HR đọc hồ sơ và bản tóm tắt để chọn người phỏng vấn.', 'HR reads applications and summaries to pick interviewees.')),
    ('interview', 'step', ('Phỏng vấn', 'Interview', 'Vorstellungsgespräch', 'Entrevista'), ['phong van'],
     ('Bước phỏng vấn ứng viên.', 'Candidate interview stage.')),
    ('offer', 'step', ('Mời nhận việc', 'Job offer', 'Jobangebot', 'Oferta de emprego'), ['moi nhan viec', 'offer'],
     ('Bước trước khi nhận vào làm.', 'Stage before hiring.')),
    ('hire', 'step', ('Nhận vào làm', 'Hire', 'Einstellung', 'Contratação'), ['nhan viec', 'nhan vao lam', 'onboarding'],
     ('Tạo hồ sơ nhân viên và đổi tài khoản ứng viên thành tài khoản nhân viên; email là tên đăng nhập.',
      'Creates the employee record and turns the candidate account into an employee account; email is the login.')),
    ('bulk-import', 'concept', ('Nhập ứng viên hàng loạt', 'Bulk candidate import', 'Massenimport', 'Importação em lote'),
     ['nhap hang loat', 'nhap csv', 'nhap excel', 'bulk import'],
     ('HR nhập nhiều ứng viên một lần từ file CSV hoặc Excel.', 'HR imports many candidates at once from a CSV or Excel file.')),
    ('employee-record', 'record', ('Hồ sơ nhân viên', 'Employee record', 'Mitarbeiterakte', 'Ficha do funcionário'),
     ['ho so nhan vien', 'thong tin nhan vien', 'employee profile'],
     ('Thông tin nhân viên lưu ở khu vực của nước sở tại.', 'Employee data stored in the home-country region.')),
    ('department', 'concept', ('Phòng ban', 'Department', 'Abteilung', 'Departamento'), ['phong ban', 'department'],
     ('Đơn vị nhân viên trực thuộc.', 'The unit an employee belongs to.')),
    ('account', 'record', ('Tài khoản đăng nhập', 'Login account', 'Benutzerkonto', 'Conta de acesso'),
     ['tai khoan', 'dang nhap', 'mat khau', 'login', 'password'],
     ('Đăng nhập qua Keycloak; người chưa có tài khoản nhận mật khẩu tạm, phải đổi ở lần đầu.',
      'Sign-in through Keycloak; new people get a temporary password to change at first sign-in.')),
    # Tài chính, dự án
    ('income-expense', 'record', ('Thu chi theo tháng', 'Monthly income and expenses', 'Monatliche Einnahmen und Ausgaben',
                                  'Receitas e despesas mensais'),
     ['thu chi', 'doanh thu', 'chi phi', 'loi nhuan', 'revenue', 'expenses'],
     ('Doanh thu, chi phí và lợi nhuận theo từng tháng.', 'Revenue, costs and profit per month.')),
    ('material-purchase', 'record', ('Mua vật liệu', 'Material purchase', 'Materialeinkauf', 'Compra de material'),
     ['mua vat lieu', 'nhap vat lieu', 'vat lieu', 'material'],
     ('Chứng từ mua vật liệu của nhà cung cấp.', 'Voucher for buying materials from a supplier.')),
    ('supplier', 'concept', ('Nhà cung cấp', 'Supplier', 'Lieferant', 'Fornecedor'), ['nha cung cap', 'ncc', 'supplier'],
     ('Đơn vị bán vật liệu cho công ty.', 'Company that sells materials to the group.')),
    ('supplier-debt', 'amount', ('Công nợ nhà cung cấp', 'Supplier balance', 'Lieferantenschulden', 'Dívida com fornecedor'),
     ['cong no', 'no nha cung cap', 'supplier debt'],
     ('Số tiền còn nợ nhà cung cấp.', 'Amount still owed to a supplier.')),
    ('supplier-payment', 'record', ('Trả tiền nhà cung cấp', 'Supplier payment', 'Lieferantenzahlung', 'Pagamento a fornecedor'),
     ['tra tien nha cung cap', 'thanh toan nha cung cap'], ('Một lần trả tiền cho nhà cung cấp.', 'One payment to a supplier.')),
    ('month-close', 'process', ('Chốt sổ tháng', 'Month-end close', 'Monatsabschluss', 'Fechamento mensal'),
     ['chot so', 'chot thang', 'month close'], ('Khóa số liệu tài chính của một tháng đã kết thúc.', 'Locks the finance figures of a finished month.')),
    ('group-report', 'record', ('Báo cáo tập đoàn', 'Group report', 'Konzernbericht', 'Relatório do grupo'),
     ['bao cao tap doan', 'bao cao tong hop', 'group report'],
     ('Báo cáo gộp số liệu mọi nước ở Hub (phía đọc của CQRS).', 'Consolidated report of every country at the Hub (CQRS read side).')),
    ('project', 'concept', ('Dự án', 'Project', 'Projekt', 'Projeto'), ['du an', 'cong trinh', 'project'],
     ('Công trình xây dựng công ty đang làm.', 'A construction project the group is working on.')),
    ('contract', 'record', ('Hợp đồng', 'Contract', 'Vertrag', 'Contrato'), ['hop dong', 'contract'],
     ('Hợp đồng với khách hàng của dự án.', 'Agreement with the customer of a project.')),
    ('customer', 'concept', ('Khách hàng', 'Customer', 'Kunde', 'Cliente'), ['khach hang', 'customer'],
     ('Bên thuê công ty làm dự án.', 'The party that hires the group for a project.')),
    ('acceptance', 'step', ('Nghiệm thu dự án', 'Project acceptance', 'Projektabnahme', 'Aceitação do projeto'),
     ['nghiem thu', 'acceptance'], ('Xác nhận dự án đã hoàn thành theo hợp đồng.', 'Confirms the project was delivered under the contract.')),
    ('customer-notice', 'concept', ('Thông báo khách hàng', 'Customer notice', 'Kundenmitteilung', 'Aviso ao cliente'),
     ['thong bao khach hang'], ('Thông báo gửi khách hàng, hiện mới xếp hàng chờ gửi.', 'Message to customers; currently only queued.')),
    # Bảo mật, kiểm toán, thông báo
    ('personal-data', 'concept', ('Dữ liệu cá nhân', 'Personal data', 'Personenbezogene Daten', 'Dados pessoais'),
     ['du lieu ca nhan', 'thong tin ca nhan', 'gdpr', 'privacy', 'rieng tu'],
     ('Tên, email, điện thoại, lương, tài khoản; lưu ở khu vực của nước bạn.',
      'Name, email, phone, salary, account; stored in your country region.')),
    ('encryption', 'rule', ('Mã hóa theo từng nước', 'Per-country encryption', 'Verschlüsselung pro Land', 'Criptografia por país'),
     ['ma hoa', 'aes', 'encryption'], ('Bản sao trên kho tổng mã hóa AES-256-GCM bằng khóa riêng của từng nước.',
                                      'The group copy is encrypted with AES-256-GCM using a key per country.')),
    ('group-datastore', 'concept', ('Kho dữ liệu tổng', 'Group data warehouse', 'Konzern-Datenspeicher', 'Repositório do grupo'),
     ['kho tong'], ('Bản sao dữ liệu của mọi nước trên Firestore; chỉ Hub được ghi.',
                    'Copy of every country\'s data on Firestore; only the Hub writes.')),
    ('audit-log', 'record', ('Sổ kiểm toán', 'Audit log', 'Prüfprotokoll', 'Registro de auditoria'),
     ['kiem toan', 'nhat ky', 'lich su thay doi', 'audit'],
     ('Sổ chỉ ghi thêm, nối chuỗi băm nên sửa một dòng là bị phát hiện.',
      'Append-only log chained by hashes, so editing a row is detected.')),
    ('audit-access', 'rule', ('Quyền kiểm toán có thời hạn', 'Time-limited auditor access', 'Befristeter Prüferzugang',
                              'Acesso de auditor com prazo'),
     ['han truy cap', 'access until'], ('Tài khoản kiểm toán độc lập chỉ đọc được sổ tới hết ngày ghi trong access_until.',
                                        'The external auditor can read the log only until the access_until date.')),
    ('notification', 'concept', ('Thông báo', 'Notifications', 'Benachrichtigungen', 'Notificações'),
     ['thong bao', 'bao tin', 'push', 'notification'],
     ('Thông báo trong app và thông báo đẩy khi đơn được duyệt, có phiếu lương mới, hồ sơ chuyển bước.',
      'In-app and push notifications for approvals, new payslips and application changes.')),
    ('request-log', 'record', ('Log request', 'Request log', 'Anfrageprotokoll', 'Log de requisições'),
     ['log request', 'nhat ky request', 'request log'],
     ('Mỗi request của mọi service: đường dẫn, mã trả về, thời gian, correlation id; giữ 7 ngày.',
      'Every request of every service: path, status, duration, correlation id; kept 7 days.')),
    ('correlation-id', 'concept', ('Mã theo dõi (correlation id)', 'Correlation id', 'Korrelations-ID', 'ID de correlação'),
     ['correlation id', 'ma theo doi'], ('Mã đi theo một thao tác qua mọi service để ráp lại cả chuỗi.',
                                          'Id that follows one action through every service to rebuild the chain.')),
    ('metrics', 'record', ('Số liệu giám sát', 'Metrics', 'Metriken', 'Métricas'), ['metrics', 'so lieu giam sat'],
     ('Số request, lỗi, thời gian xử lý, trạng thái mạch của từng service.', 'Requests, errors, latency and breaker state per service.')),
    ('alert', 'concept', ('Cảnh báo qua email', 'Email alert', 'E-Mail-Alarm', 'Alerta por e-mail'), ['canh bao', 'alert'],
     ('Service chết hoặc lỗi nhiều thì gửi email HTML cho quản trị.', 'A service down or failing sends an HTML email to the admin.')),
    # Kho tri thức
    ('knowledge-base', 'concept', ('Kho tri thức', 'Knowledge base', 'Wissensdatenbank', 'Base de conhecimento'),
     ['kho tri thuc', 'knowledge base'], ('Bài viết nội bộ, hỏi đáp AI và đồ thị tri thức.', 'Internal articles, AI Q&A and the knowledge graph.')),
    ('ai-assistant', 'concept', ('Trợ lý hỏi đáp AI', 'AI assistant', 'KI-Assistent', 'Assistente de IA'),
     ['hoi ai', 'tro ly ai', 'hoi dap'], ('Trả lời câu hỏi từ bài viết và đồ thị, có trích dẫn nguồn.',
                                          'Answers questions from articles and the graph, with citations.')),
    ('knowledge-graph', 'concept', ('Đồ thị tri thức', 'Knowledge graph', 'Wissensgraph', 'Grafo de conhecimento'),
     ['do thi tri thuc', 'knowledge graph'], ('Kiến thức lưu thành nút và cạnh có tên, máy đi theo cạnh để trả lời.',
                                             'Knowledge stored as nodes and named edges that machines can follow.')),
    ('ontology', 'concept', ('Bản thể học (ontology)', 'Ontology', 'Ontologie', 'Ontologia'), ['ban the hoc', 'ontology', 'owl'],
     ('Định nghĩa các lớp, quan hệ nối lớp nào với lớp nào và tính chất của quan hệ; xuất được dạng RDF/OWL.',
      'Defines classes, which classes each relation connects and relation properties; exported as RDF/OWL.')),
    ('reasoning', 'concept', ('Suy luận tự động', 'Automated reasoning', 'Automatisches Schließen', 'Raciocínio automático'),
     ['suy luan', 'reasoning', 'inference'], ('Từ cạnh đã có và các luật, máy tự sinh cạnh mới, kèm lý do.',
                                             'Derives new edges from existing ones and rules, with an explanation.')),
    ('graph-extraction', 'process', ('AI trích xuất đồ thị', 'AI graph extraction', 'KI-Graphextraktion', 'Extração de grafo por IA'),
     ['trich xuat', 'tu trich xuat', 'extraction'], ('AI đọc bài viết, đề xuất nút và cạnh mới; HR duyệt rồi mới vào đồ thị.',
                                                   'The AI reads articles and proposes nodes and edges; HR approves them first.')),
    ('ext-read', 'step', ('AI đọc bài', 'AI reads article', 'KI liest Artikel', 'IA lê o artigo'), [],
     ('AI đọc bài và trả đề xuất đúng khuôn JSON theo bản thể học.', 'The AI reads the article and returns proposals as JSON.')),
    ('ext-validate', 'step', ('Kiểm theo bản thể học', 'Validate against ontology', 'Gegen Ontologie prüfen', 'Validar pela ontologia'),
     [], ('Server kiểm lớp, miền và phạm vi của quan hệ, câu trích phải có thật trong bài.',
          'The server checks classes, domains and ranges, and that the quote really is in the article.')),
    ('proposal-review', 'step', ('HR duyệt đề xuất', 'Review proposals', 'Vorschläge prüfen', 'Revisar propostas'), [],
     ('HR, quản trị hoặc ban điều hành duyệt hoặc bỏ từng đề xuất.', 'HR, admin or executives approve or reject each proposal.')),
    ('ext-reason', 'step', ('Chạy lại suy luận', 'Re-run reasoning', 'Schließen erneut ausführen', 'Reexecutar raciocínio'), [],
     ('Cạnh mới được duyệt thì máy suy luận lại toàn đồ thị.', 'Approved edges trigger reasoning over the whole graph again.')),
    ('graph-proposal', 'request', ('Đề xuất cho đồ thị', 'Graph proposal', 'Graphvorschlag', 'Proposta para o grafo'),
     ['de xuat', 'proposal'], ('Một nút hoặc cạnh AI đề xuất, kèm câu trích làm bằng chứng.',
                               'A node or edge proposed by the AI, with a quote as evidence.')),
    # Vai trò
    ('role-employee', 'role', ('Nhân viên', 'Employee', 'Mitarbeiter', 'Funcionário'), ['nhan vien', 'employee'],
     ('Chấm công, tạo đơn, xem phiếu lương của mình.', 'Clocks in, creates requests, sees own payslips.')),
    ('role-hr', 'role', ('HR (nhân sự)', 'HR', 'Personalabteilung', 'RH'), ['nhan su', 'hr'],
     ('Duyệt đơn, tuyển dụng, xem phiếu lương.', 'Approves requests, recruits, views payslips.')),
    ('role-finance', 'role', ('Tài chính', 'Finance', 'Finanzen', 'Financeiro'), ['tai chinh', 'ke toan', 'finance'],
     ('Chốt lương, thu chi, chốt sổ tháng.', 'Closes payroll, income and expenses, month-end close.')),
    ('role-executive', 'role', ('Ban điều hành', 'Executive', 'Geschäftsleitung', 'Diretoria'), ['giam doc', 'ban dieu hanh', 'executive'],
     ('Xem báo cáo tập đoàn, có quyền duyệt và chốt lương.', 'Sees group reports, can approve and close payroll.')),
    ('role-admin', 'role', ('Quản trị', 'Admin', 'Administrator', 'Administrador'), ['quan tri', 'admin'],
     ('Toàn quyền quản trị hệ thống.', 'Full system administration.')),
    ('role-candidate', 'role', ('Ứng viên', 'Candidate', 'Bewerber', 'Candidato'), ['ung vien', 'candidate'],
     ('Tự nộp và sửa hồ sơ ứng tuyển.', 'Submits and edits own application.')),
    ('role-auditor', 'role', ('Kiểm toán độc lập', 'External auditor', 'Externer Prüfer', 'Auditor externo'), ['kiem toan vien', 'auditor'],
     ('Chỉ đọc sổ kiểm toán, có thời hạn truy cập.', 'Read-only access to the audit log, time-limited.')),
    # Nơi chốn, đồng tiền, ngôn ngữ
    ('hub', 'place', ('Hub tập đoàn', 'Group Hub', 'Konzern-Hub', 'Hub do grupo'), ['hub'],
     ('Phần dùng chung cả tập đoàn: đăng nhập, sổ kiểm toán, báo cáo, kho tri thức.', 'Shared group part: sign-in, audit log, reports, knowledge base.')),
    ('region-vn', 'region', ('Việt Nam', 'Vietnam', 'Vietnam', 'Vietnã'), ['viet nam', 'vn'], ('Khu vực VN, cũng đặt Hub.', 'VN region, also hosts the Hub.')),
    ('region-de', 'region', ('Đức', 'Germany', 'Deutschland', 'Alemanha'), ['duc', 'germany', 'de'], ('Khu vực DE.', 'DE region.')),
    ('region-us', 'region', ('Mỹ', 'United States', 'USA', 'Estados Unidos'), ['hoa ky', 'usa', 'us'], ('Khu vực US.', 'US region.')),
    ('region-br', 'region', ('Brazil', 'Brazil', 'Brasilien', 'Brasil'), ['brazil', 'brasil', 'br'], ('Khu vực BR.', 'BR region.')),
    ('region-za', 'region', ('Nam Phi', 'South Africa', 'Südafrika', 'África do Sul'), ['nam phi', 'south africa', 'za'], ('Khu vực ZA.', 'ZA region.')),
    ('region-au', 'region', ('Úc', 'Australia', 'Australien', 'Austrália'), ['australia', 'au'], ('Khu vực AU.', 'AU region.')),
    ('cur-vnd', 'currency', L('Đồng Việt Nam (VND)', 'Vietnamese dong (VND)'), ['vnd'], ('Đồng tiền của khu vực VN.', 'Currency of the VN region.')),
    ('cur-eur', 'currency', L('Euro (EUR)', 'Euro (EUR)'), ['eur', 'euro'], ('Đồng tiền của khu vực DE.', 'Currency of the DE region.')),
    ('cur-usd', 'currency', L('Đô la Mỹ (USD)', 'US dollar (USD)'), ['usd', 'do la'], ('Đồng tiền của khu vực US.', 'Currency of the US region.')),
    ('cur-brl', 'currency', L('Real Brazil (BRL)', 'Brazilian real (BRL)'), ['brl'], ('Đồng tiền của khu vực BR.', 'Currency of the BR region.')),
    ('cur-zar', 'currency', L('Rand Nam Phi (ZAR)', 'South African rand (ZAR)'), ['zar', 'rand'], ('Đồng tiền của khu vực ZA.', 'Currency of the ZA region.')),
    ('cur-aud', 'currency', L('Đô la Úc (AUD)', 'Australian dollar (AUD)'), ['aud'], ('Đồng tiền của khu vực AU.', 'Currency of the AU region.')),
    ('lang-vi', 'language', ('Tiếng Việt', 'Vietnamese', 'Vietnamesisch', 'Vietnamita'), ['tieng viet'], ('Ngôn ngữ vi của app.', 'App language vi.')),
    ('lang-en', 'language', ('Tiếng Anh', 'English', 'Englisch', 'Inglês'), ['tieng anh', 'english'], ('Ngôn ngữ en của app.', 'App language en.')),
    ('lang-de', 'language', ('Tiếng Đức', 'German', 'Deutsch', 'Alemão'), ['tieng duc', 'german'], ('Ngôn ngữ de của app.', 'App language de.')),
    ('lang-pt', 'language', ('Tiếng Bồ Đào Nha', 'Portuguese', 'Portugiesisch', 'Português'), ['tieng bo dao nha', 'portuguese'],
     ('Ngôn ngữ pt của app.', 'App language pt.')),
]

# Service: mã ngắn -> tóm tắt (vi, en)
SERVICES = {
    'hr': ('Service hồ sơ nhân viên.', 'Employee records service.'),
    'attendance': ('Service chấm công, đơn nghỉ, tăng ca.', 'Attendance, leave and overtime service.'),
    'payroll': ('Service lương, điều phối Saga chốt lương.', 'Payroll service, orchestrates the closing Saga.'),
    'finance': ('Service tài chính: thu chi, vật liệu, công nợ, chốt sổ, ngân sách lương.', 'Finance: income, materials, suppliers, close, payroll budget.'),
    'project_contract': ('Service dự án, hợp đồng, khách hàng, nghiệm thu.', 'Projects, contracts, customers and acceptance.'),
    'recruitment': ('Service tuyển dụng.', 'Recruitment service.'),
    'currency': ('Service tỷ giá nội bộ.', 'Internal exchange-rate service.'),
    'notification': ('Service thông báo, đẩy FCM.', 'Notification service with FCM push.'),
    'integration': ('Cổng ra ngân hàng có Circuit Breaker.', 'Bank gateway with a circuit breaker.'),
    'bank_mock': ('Ngân hàng giả lập, đóng vai hệ thống bên ngoài.', 'Simulated bank playing the external system.'),
    'sync_worker': ('Đẩy sự kiện từ outbox của khu vực lên Hub và đồng bộ kho tổng.', 'Pushes region outbox events to the Hub and syncs the warehouse.'),
    'audit': ('Service sổ kiểm toán ở Hub.', 'Audit log service at the Hub.'),
    'report': ('Service báo cáo tập đoàn (CQRS) ở Hub.', 'Group report service (CQRS) at the Hub.'),
    'datastore': ('Service ghi kho tổng ở Hub.', 'Group datastore writer at the Hub.'),
    'knowledge': ('Service kho tri thức, hỏi đáp AI, đồ thị tri thức ở Hub.', 'Knowledge base, AI Q&A and knowledge graph at the Hub.'),
    'geo': ('Service đoán khu vực theo IP ở Hub.', 'IP-to-region lookup at the Hub.'),
}
REGION_SERVICES = ['hr', 'attendance', 'payroll', 'finance', 'project_contract', 'recruitment', 'currency',
                   'notification', 'integration', 'bank_mock', 'sync_worker']
HUB_SERVICES = ['audit', 'report', 'datastore', 'knowledge', 'geo']
# Đúng 13 service đăng ký Eureka và gửi log request lên Elasticsearch
REGISTERED = ['hr', 'attendance', 'payroll', 'finance', 'project_contract', 'recruitment', 'currency',
              'notification', 'integration', 'audit', 'report', 'knowledge', 'datastore']


def svc(name):
    return 'svc-' + name.replace('_', '-')


for name, summary in SERVICES.items():
    NODES.append((svc(name), 'service', (name,) * 4, [name.replace('_', ' ')] if '_' in name else [], summary))

# Công nghệ: mã, nhãn, tên gọi khác, tóm tắt
TECH = [
    ('kong', 'Kong', ['kong', 'api gateway'], ('Cổng API mỗi khu vực, kiểm JWT, chia tải.', 'API gateway per region, checks JWT, balances load.')),
    ('keycloak', 'Keycloak', ['keycloak'], ('Máy chủ đăng nhập (OAuth2, PKCE) của tập đoàn.', 'Group sign-in server (OAuth2, PKCE).')),
    ('waf', 'WAF ModSecurity', ['waf', 'modsecurity', 'tuong lua'], ('Tường lửa ứng dụng web giữ cổng công khai.', 'Web application firewall on public ports.')),
    ('postgres', 'PostgreSQL', ['postgres', 'postgresql'], ('CSDL chính, primary và replica mỗi khu vực.', 'Main database, primary and replica per region.')),
    ('redis', 'Redis', ['redis'], ('Bộ nhớ đệm (cache) mỗi khu vực và Hub.', 'Cache per region and at the Hub.')),
    ('rabbitmq', 'RabbitMQ', ['rabbitmq'], ('Hàng đợi sự kiện pub/sub ở Hub.', 'Pub/sub event broker at the Hub.')),
    ('elasticsearch', 'Elasticsearch', ['elasticsearch'], ('Kho log request tập trung.', 'Central request log store.')),
    ('eureka', 'Eureka', ['eureka', 'service registry'], ('Sổ đăng ký service.', 'Service registry.')),
    ('doris', 'Apache Doris', ['doris'], ('Kho phân tích cho báo cáo tập đoàn.', 'Analytics store for group reports.')),
    ('firestore', 'Firestore', ['firestore', 'firebase'], ('Kho dữ liệu tổng trên Firebase.', 'Group data warehouse on Firebase.')),
    ('garage', 'Garage (S3)', ['garage', 's3'], ('Lưu file CV chuẩn S3 mỗi khu vực.', 'S3-compatible CV storage per region.')),
    ('prometheus', 'Prometheus', ['prometheus'], ('Thu số liệu giám sát 15 giây một lần.', 'Collects metrics every 15 seconds.')),
    ('grafana', 'Grafana', ['grafana', 'dashboard'], ('Vẽ dashboard giám sát và tra log.', 'Monitoring and log dashboards.')),
    ('alertmanager', 'Alertmanager', ['alertmanager'], ('Gửi cảnh báo qua email.', 'Sends alerts by email.')),
    ('fcm', 'Firebase Cloud Messaging', ['fcm', 'thong bao day'], ('Đẩy thông báo tới điện thoại.', 'Pushes notifications to phones.')),
    ('claude', 'Claude', ['claude', 'anthropic'], ('AI chính: tóm tắt CV, hỏi đáp, trích xuất đồ thị.', 'Main AI: CV summary, Q&A, graph extraction.')),
    ('gemini', 'Gemini', ['gemini', 'google ai'], ('AI dự phòng và tạo vector theo nghĩa.', 'Fallback AI and embeddings.')),
    ('flutter', 'Flutter', ['flutter'], ('Khung làm app Android.', 'Framework of the Android app.')),
    ('dart-frog', 'dart_frog', ['dart frog'], ('Khung viết service bằng Dart.', 'Dart framework for the services.')),
    ('docker', 'Docker', ['docker', 'container'], ('Đóng gói và chạy mọi thành phần.', 'Packages and runs every component.')),
    ('autoheal', 'Autoheal', ['autoheal', 'tu phuc hoi'], ('Khởi động lại container bị đánh dấu unhealthy.', 'Restarts containers marked unhealthy.')),
]
for tid, label, aliases, summary in TECH:
    NODES.append((f'tech-{tid}', 'technology', (label,) * 4, aliases, summary))

PATTERNS = [
    ('microservices', L('Microservices', 'Microservices'), ['microservice'], ('Mỗi nghiệp vụ một service riêng, CSDL riêng.', 'One service and database per business area.')),
    ('api-gateway', L('API Gateway', 'API Gateway'), ['cong api'], ('Một cổng vào duy nhất cho app.', 'Single entry point for the app.')),
    ('layered', L('Kiến trúc phân tầng', 'Layered architecture', 'Schichtenarchitektur', 'Arquitetura em camadas'), ['phan tang', 'layered'],
     ('Route, nghiệp vụ, truy cập dữ liệu tách tầng.', 'Routes, domain and data access in separate layers.')),
    ('primary-replica', L('Primary-Replica', 'Primary-Replica'), ['primary replica', 'replica'], ('Ghi vào primary, đọc từ replica.', 'Write to the primary, read from the replica.')),
    ('circuit-breaker', L('Circuit Breaker', 'Circuit Breaker'), ['circuit breaker', 'ngat mach'], ('Lỗi liên tục thì tạm ngừng gọi.', 'Stops calling after repeated failures.')),
    ('append-only', L('Sổ chỉ ghi thêm', 'Append-only log', 'Nur-Anhängen-Protokoll', 'Log somente inclusão'), ['append only', 'chi ghi them'],
     ('Không sửa, không xóa, chỉ thêm dòng mới.', 'Never update or delete, only append.')),
    ('event-driven', L('Hướng sự kiện', 'Event-driven', 'Ereignisgesteuert', 'Orientado a eventos'), ['event driven', 'su kien'],
     ('Service báo sự kiện, service khác tự phản ứng.', 'Services publish events and others react.')),
    ('saga', L('Saga', 'Saga'), ['saga'], ('Giao dịch nhiều bước qua nhiều service, lỗi thì bù trừ.', 'Multi-service transaction with compensation.')),
    ('cqrs', L('CQRS', 'CQRS'), ['cqrs'], ('Tách phía ghi và phía đọc.', 'Separate write and read sides.')),
    ('outbox', L('Transactional Outbox', 'Transactional Outbox'), ['outbox'], ('Ghi dữ liệu và sự kiện cùng một giao dịch.', 'Write data and event in one transaction.')),
    ('idempotency', L('Idempotency', 'Idempotency'), ['idempotency', 'chong trung'], ('Gửi lại cùng lệnh không làm hai lần.', 'Retrying a command never runs it twice.')),
    ('service-discovery', L('Service Discovery', 'Service Discovery'), ['service discovery'], ('Service tự đăng ký, bên gọi tự tìm.', 'Services register, callers look them up.')),
    ('cache-aside', L('Cache-aside', 'Cache-aside'), ['cache aside', 'cache'], ('Đọc cache trước, thiếu thì đọc CSDL rồi ghi cache.', 'Read cache first, fall back to the database.')),
    ('load-balancing', L('Cân bằng tải', 'Load balancing', 'Lastverteilung', 'Balanceamento de carga'), ['can bang tai', 'load balancer'],
     ('Chia request cho nhiều bản chạy.', 'Spreads requests over several instances.')),
    ('graphrag', L('GraphRAG', 'GraphRAG'), ['graphrag', 'rag'], ('AI trả lời từ bài viết và cạnh đồ thị.', 'AI answers from articles and graph edges.')),
]
for pid, labels, aliases, summary in PATTERNS:
    NODES.append((f'pat-{pid}', 'pattern', labels, aliases, summary))

# Bài viết trong kho cũng là nút (lớp document)
ARTICLES = {
    'overtime': ('Cách tính lương tăng ca', 'How overtime pay is calculated'),
    'deductions': ('Tỷ lệ khấu trừ ước tính theo nước', 'Estimated deduction rates by country'),
    'payroll-close': ('Quy trình chốt lương hằng tháng', 'Monthly payroll closing process'),
    'period-lock': ('Vì sao không duyệt được đơn khi đang chốt lương', 'Why requests cannot be approved during payroll closing'),
    'leave': ('Xin nghỉ phép', 'Requesting leave'),
    'clock': ('Chấm công vào và ra ca', 'Clocking in and out'),
    'overtime-request': ('Đăng ký tăng ca', 'Requesting overtime'),
    'hiring': ('Quy trình tuyển dụng và nhận việc', 'Recruitment and onboarding'),
    'privacy': ('Dữ liệu cá nhân được bảo vệ thế nào', 'How personal data is protected'),
    'notifications': ('Thông báo trong app và thông báo đẩy', 'In-app and push notifications'),
    'suppliers': ('Mua vật liệu và công nợ nhà cung cấp', 'Material purchases and supplier balances'),
    'month-close': ('Chốt sổ tháng', 'Month-end close'),
    'acceptance': ('Nghiệm thu dự án và doanh thu', 'Project acceptance and revenue'),
    'access': ('Ai được xem gì trong app', 'Who can see what in the app'),
    'knowledge-graph': ('Đồ thị tri thức, suy luận và đề xuất từ AI', 'Knowledge graph, reasoning and AI proposals'),
}

MANAGERS = ['role-hr', 'role-admin', 'role-executive']
PAYROLL_RUNNERS = ['role-finance', 'role-admin', 'role-executive']
SAGA = ['step-lock', 'step-hours', 'step-rate', 'step-calculate', 'step-budget', 'step-pay',
        'step-expense', 'step-payslips', 'step-unlock']
HIRING = ['submitted', 'ai-review', 'screening', 'interview', 'offer', 'hire']
EXTRACTION = ['ext-read', 'ext-validate', 'proposal-review', 'ext-reason']
RATES = {'vn': '10,5%', 'de': '38%', 'us': '25%', 'br': '27%', 'za': '26%', 'au': '28%'}
CURRENCIES = {'vn': 'vnd', 'de': 'eur', 'us': 'usd', 'br': 'brl', 'za': 'zar', 'au': 'aud'}
LANGUAGES = {'vn': 'vi', 'de': 'de', 'us': 'en', 'br': 'pt', 'za': 'en', 'au': 'en'}
REGIONS = list(RATES)

EDGES = [
    # Lương
    ('overtime-pay', 'calculated_from', 'hourly-rate'),
    ('overtime-pay', 'calculated_from', 'overtime'),
    ('hourly-rate', 'calculated_from', 'base-salary'),
    ('overtime', 'created_by', 'overtime-request'),
    ('gross-pay', 'calculated_from', 'base-salary'),
    ('gross-pay', 'calculated_from', 'overtime-pay'),
    ('gross-pay', 'calculated_from', 'bonus-penalty'),
    ('net-pay', 'calculated_from', 'gross-pay'),
    ('net-pay', 'calculated_from', 'deduction'),
    ('payslip', 'part_of', 'payroll-period'),
    ('net-pay', 'part_of', 'payslip'),
    ('gross-pay', 'part_of', 'payslip'),
    ('payroll-closing', 'produces', 'payslip'),
    ('payroll-closing', 'handled_by', 'svc-payroll'),
    ('payroll-closing', 'part_of', 'payroll-period'),
    ('payroll-closing', 'implements', 'pat-saga'),
    ('step-lock', 'produces', 'period-lock'),
    ('step-hours', 'related_to', 'attendance'),
    ('step-hours', 'related_to', 'overtime'),
    ('step-hours', 'handled_by', 'svc-attendance'),
    ('step-rate', 'handled_by', 'svc-currency'),
    ('step-rate', 'related_to', 'exchange-rate'),
    ('step-calculate', 'produces', 'gross-pay'),
    ('step-calculate', 'produces', 'net-pay'),
    ('step-calculate', 'handled_by', 'svc-payroll'),
    ('step-budget', 'handled_by', 'svc-finance'),
    ('step-budget', 'produces', 'payroll-budget'),
    ('step-pay', 'handled_by', 'svc-integration'),
    ('step-expense', 'handled_by', 'svc-finance'),
    ('step-expense', 'produces', 'payroll-expense'),
    ('payroll-expense', 'part_of', 'income-expense'),
    ('step-payslips', 'notifies', 'role-employee'),
    ('step-payslips', 'related_to', 'notification'),
    ('step-payslips', 'handled_by', 'svc-payroll'),
    ('step-lock', 'handled_by', 'svc-attendance'),
    ('step-unlock', 'handled_by', 'svc-attendance'),
    ('step-budget', 'undone_by', 'compensation'),
    ('step-lock', 'undone_by', 'compensation'),
    ('compensation', 'part_of', 'payroll-closing'),
    ('period-lock', 'blocks', 'leave-request'),
    ('period-lock', 'blocks', 'overtime-request'),
    ('exchange-rate', 'handled_by', 'svc-currency'),
    # Chấm công
    ('leave-request', 'created_by', 'role-employee'),
    ('overtime-request', 'created_by', 'role-employee'),
    ('leave-request', 'handled_by', 'svc-attendance'),
    ('overtime-request', 'handled_by', 'svc-attendance'),
    ('leave-request', 'notifies', 'notification'),
    ('attendance', 'handled_by', 'svc-attendance'),
    ('attendance', 'related_to', 'shift'),
    ('attendance', 'related_to', 'holiday'),
    ('attendance', 'created_by', 'role-employee'),
    ('payslip', 'handled_by', 'svc-payroll'),
    # Tuyển dụng
    ('recruitment', 'handled_by', 'svc-recruitment'),
    ('cv', 'part_of', 'recruitment'),
    ('cv', 'created_by', 'role-candidate'),
    ('cv', 'stored_in', 'tech-garage'),
    ('ai-summary', 'calculated_from', 'cv'),
    ('ai-review', 'produces', 'ai-summary'),
    ('ai-review', 'uses', 'tech-claude'),
    ('ai-review', 'uses', 'tech-gemini'),
    ('hire', 'produces', 'employee-record'),
    ('hire', 'produces', 'account'),
    ('role-candidate', 'becomes', 'role-employee'),
    ('bulk-import', 'created_by', 'role-hr'),
    ('bulk-import', 'part_of', 'recruitment'),
    ('employee-record', 'handled_by', 'svc-hr'),
    ('employee-record', 'part_of', 'personal-data'),
    ('employee-record', 'related_to', 'department'),
    ('employee-record', 'stored_in', 'tech-postgres'),
    ('account', 'stored_in', 'tech-keycloak'),
    ('account', 'part_of', 'personal-data'),
    # Tài chính, dự án (phần còn lại để AI trích xuất từ bài viết)
    ('income-expense', 'handled_by', 'svc-finance'),
    ('material-purchase', 'handled_by', 'svc-finance'),
    ('supplier-debt', 'handled_by', 'svc-finance'),
    ('month-close', 'handled_by', 'svc-finance'),
    ('group-report', 'handled_by', 'svc-report'),
    ('group-report', 'stored_in', 'tech-doris'),
    ('group-report', 'calculated_from', 'audit-log'),
    ('project', 'handled_by', 'svc-project-contract'),
    ('contract', 'handled_by', 'svc-project-contract'),
    ('contract', 'related_to', 'customer'),
    ('customer-notice', 'related_to', 'customer'),
    # Bảo mật, kiểm toán
    ('encryption', 'protects', 'personal-data'),
    ('encryption', 'part_of', 'group-datastore'),
    ('group-datastore', 'handled_by', 'svc-datastore'),
    ('group-datastore', 'stored_in', 'tech-firestore'),
    ('audit-log', 'handled_by', 'svc-audit'),
    ('audit-log', 'protects', 'personal-data'),
    ('audit-log', 'stored_in', 'tech-postgres'),
    ('audit-access', 'related_to', 'role-auditor'),
    ('payroll-closing', 'related_to', 'audit-log'),
    ('notification', 'handled_by', 'svc-notification'),
    ('notification', 'uses', 'tech-fcm'),
    ('tech-waf', 'protects', 'account'),
    # Giám sát
    ('correlation-id', 'part_of', 'request-log'),
    ('request-log', 'stored_in', 'tech-elasticsearch'),
    ('metrics', 'stored_in', 'tech-prometheus'),
    ('alert', 'calculated_from', 'metrics'),
    ('alert', 'uses', 'tech-alertmanager'),
    ('metrics', 'uses', 'tech-grafana'),
    ('request-log', 'uses', 'tech-grafana'),
    # Kho tri thức
    ('knowledge-base', 'handled_by', 'svc-knowledge'),
    ('ai-assistant', 'part_of', 'knowledge-base'),
    ('knowledge-graph', 'part_of', 'knowledge-base'),
    ('ontology', 'part_of', 'knowledge-graph'),
    ('reasoning', 'part_of', 'knowledge-graph'),
    ('reasoning', 'calculated_from', 'ontology'),
    ('ai-assistant', 'implements', 'pat-graphrag'),
    ('ai-assistant', 'uses', 'tech-claude'),
    ('ai-assistant', 'uses', 'tech-gemini'),
    ('ai-assistant', 'related_to', 'knowledge-graph'),
    ('graph-extraction', 'produces', 'graph-proposal'),
    ('graph-extraction', 'related_to', 'knowledge-graph'),
    ('graph-extraction', 'uses', 'tech-claude'),
    ('graph-extraction', 'uses', 'tech-gemini'),
    ('ext-reason', 'related_to', 'reasoning'),
    ('ext-validate', 'related_to', 'ontology'),
    # Nơi chốn
    ('hub', 'located_in', 'region-vn'),
    # Kiến trúc
    ('pat-outbox', 'part_of', 'pat-event-driven'),
    ('pat-idempotency', 'part_of', 'pat-event-driven'),
    ('pat-saga', 'part_of', 'pat-event-driven'),
    ('pat-api-gateway', 'part_of', 'pat-microservices'),
    ('pat-service-discovery', 'part_of', 'pat-microservices'),
    ('pat-cqrs', 'related_to', 'pat-event-driven'),
    ('pat-load-balancing', 'related_to', 'pat-service-discovery'),
    ('tech-kong', 'implements', 'pat-api-gateway'),
    ('tech-kong', 'implements', 'pat-load-balancing'),
    ('tech-eureka', 'implements', 'pat-service-discovery'),
    ('tech-rabbitmq', 'implements', 'pat-event-driven'),
    ('tech-postgres', 'implements', 'pat-primary-replica'),
    ('tech-redis', 'implements', 'pat-cache-aside'),
    ('svc-payroll', 'implements', 'pat-saga'),
    ('svc-integration', 'implements', 'pat-circuit-breaker'),
    ('svc-knowledge', 'implements', 'pat-circuit-breaker'),
    ('svc-knowledge', 'implements', 'pat-cache-aside'),
    ('svc-knowledge', 'implements', 'pat-graphrag'),
    ('svc-audit', 'implements', 'pat-append-only'),
    ('svc-audit', 'implements', 'pat-outbox'),
    ('svc-sync-worker', 'implements', 'pat-outbox'),
    ('svc-report', 'implements', 'pat-cqrs'),
    ('svc-attendance', 'implements', 'pat-idempotency'),
    ('svc-payroll', 'implements', 'pat-idempotency'),
    ('svc-finance', 'implements', 'pat-idempotency'),
    # Service gọi service (đúng theo InternalClient trong code)
    ('svc-payroll', 'depends_on', 'svc-attendance'),
    ('svc-payroll', 'depends_on', 'svc-currency'),
    ('svc-payroll', 'depends_on', 'svc-finance'),
    ('svc-payroll', 'depends_on', 'svc-integration'),
    ('svc-integration', 'depends_on', 'svc-bank-mock'),
    ('svc-recruitment', 'depends_on', 'svc-hr'),
    ('svc-project-contract', 'depends_on', 'svc-finance'),
    ('svc-finance', 'depends_on', 'svc-currency'),
    ('svc-notification', 'depends_on', 'svc-audit'),
    ('svc-report', 'depends_on', 'svc-audit'),
    ('svc-sync-worker', 'depends_on', 'svc-audit'),
    ('svc-sync-worker', 'depends_on', 'svc-datastore'),
    # Service dùng công nghệ
    ('svc-knowledge', 'uses', 'tech-postgres'),
    ('svc-knowledge', 'uses', 'tech-redis'),
    ('svc-knowledge', 'uses', 'tech-claude'),
    ('svc-knowledge', 'uses', 'tech-gemini'),
    ('svc-recruitment', 'uses', 'tech-garage'),
    ('svc-recruitment', 'uses', 'tech-claude'),
    ('svc-recruitment', 'uses', 'tech-gemini'),
    ('svc-recruitment', 'uses', 'tech-keycloak'),
    ('svc-notification', 'uses', 'tech-fcm'),
    ('svc-notification', 'uses', 'tech-rabbitmq'),
    ('svc-report', 'uses', 'tech-doris'),
    ('svc-report', 'uses', 'tech-rabbitmq'),
    ('svc-audit', 'uses', 'tech-rabbitmq'),
    ('svc-datastore', 'uses', 'tech-firestore'),
    ('svc-sync-worker', 'uses', 'tech-firestore'),
]
for name in ['hr', 'attendance', 'payroll', 'finance', 'project_contract', 'recruitment', 'currency',
             'notification', 'sync_worker', 'audit']:
    EDGES.append((svc(name), 'uses', 'tech-postgres'))
for name in REGISTERED:
    EDGES += [(svc(name), 'uses', 'tech-eureka'), (svc(name), 'uses', 'tech-elasticsearch'),
              (svc(name), 'implements', 'pat-microservices'), (svc(name), 'implements', 'pat-layered')]
for name in SERVICES:
    EDGES.append((svc(name), 'uses', 'tech-dart-frog'))
for r in REGIONS:
    for name in REGION_SERVICES:
        EDGES.append((svc(name), 'runs_in', f'region-{r}'))
    for t in ['kong', 'waf', 'postgres', 'redis', 'garage', 'prometheus']:
        EDGES.append((f'tech-{t}', 'runs_in', f'region-{r}'))
    EDGES += [(f'region-{r}', 'has_currency', f'cur-{CURRENCIES[r]}'),
              (f'region-{r}', 'default_language', f'lang-{LANGUAGES[r]}')]
for name in HUB_SERVICES:
    EDGES.append((svc(name), 'runs_in', 'hub'))
for t in ['keycloak', 'waf', 'postgres', 'redis', 'rabbitmq', 'elasticsearch', 'eureka', 'doris',
          'prometheus', 'grafana', 'alertmanager', 'autoheal']:
    EDGES.append((f'tech-{t}', 'runs_in', 'hub'))
for seq, process in ((SAGA, 'payroll-closing'), (HIRING, 'recruitment'), (EXTRACTION, 'graph-extraction')):
    for a, b in zip(seq, seq[1:]):
        EDGES.append((a, 'next_step', b))
    for s in seq:
        EDGES.append((s, 'step_of', process))
for s in HIRING:
    EDGES.append((s, 'handled_by', 'svc-recruitment'))
for s in EXTRACTION:
    EDGES.append((s, 'handled_by', 'svc-knowledge'))
for role in MANAGERS:
    EDGES += [('leave-request', 'approved_by', role), ('overtime-request', 'approved_by', role),
              ('hire', 'approved_by', role), ('graph-proposal', 'approved_by', role)]
for role in PAYROLL_RUNNERS:
    EDGES.append(('payroll-closing', 'started_by', role))
for role in ['role-finance', 'role-hr', 'role-admin', 'role-executive', 'role-employee']:
    EDGES.append((role, 'can_view', 'payslip'))
for role in ['role-executive', 'role-admin', 'role-auditor']:
    EDGES.append((role, 'can_view', 'audit-log'))
# Tỷ lệ khấu trừ ghi trên cạnh (giá trị đi kèm quan hệ)
EDGE_NOTES = {}
for r, rate in RATES.items():
    EDGES.append((f'region-{r}', 'has_rate', 'deduction'))
    EDGE_NOTES[(f'region-{r}', 'has_rate', 'deduction')] = rate
# Nút liên kết tới bài giải thích
EXPLAINED = {
    'overtime': ['overtime', 'overtime-pay', 'hourly-rate'],
    'deductions': ['deduction', 'net-pay'],
    'payroll-close': ['payroll-closing', 'compensation', 'step-pay'],
    'period-lock': ['period-lock'],
    'leave': ['leave-request'],
    'clock': ['attendance'],
    'overtime-request': ['overtime-request'],
    'hiring': ['recruitment', 'hire', 'account'],
    'privacy': ['personal-data', 'encryption', 'group-datastore'],
    'notifications': ['notification'],
    'suppliers': ['material-purchase', 'supplier-debt', 'supplier'],
    'month-close': ['month-close'],
    'acceptance': ['acceptance', 'project'],
    'access': ['role-auditor', 'audit-access'],
    'knowledge-graph': ['knowledge-graph', 'ontology', 'reasoning', 'graph-extraction'],
}
for article, nodes in EXPLAINED.items():
    for n in nodes:
        EDGES.append((n, 'explained_in', f'doc-{article}'))


def fold(text):
    s = unicodedata.normalize('NFD', text.lower().replace('đ', 'd'))
    return ''.join(c for c in s if unicodedata.category(c) != 'Mn').strip()


def lit(value):
    if value is None:
        return 'null'
    return "'" + str(value).replace("'", "''") + "'"


def langs(t):
    return json.dumps(dict(zip(['vi', 'en', 'de', 'pt'], t)), ensure_ascii=False)


def arr(values):
    return 'array[' + ', '.join(lit(v) for v in values) + ']::text[]'


def ancestors(cls):
    parent = {c: p for c, p, _ in CLASSES}
    out = []
    while cls:
        out.append(cls)
        cls = parent[cls]
    return out


def display_type(cls):
    for c in ancestors(cls):
        if c in DISPLAY:
            return DISPLAY_AS.get(c, c)
    return 'concept'


def conforms(cls, allowed):
    return any(a in ancestors(cls) for a in allowed)


def check(class_of):
    """Mọi cạnh phải đúng miền và phạm vi của quan hệ; không ai ghi quan hệ chỉ do suy luận"""
    for s, rel, t in EDGES:
        assert s in class_of and t in class_of, ('nút lạ', s, rel, t)
        labels, domain, rng, props, _ = RELATIONS[rel]
        assert not props.get('derived'), ('quan hệ chỉ do suy luận', s, rel, t)
        assert conforms(class_of[s], domain), ('sai miền', s, class_of[s], rel, domain)
        assert conforms(class_of[t], rng), ('sai phạm vi', t, class_of[t], rel, rng)
    for rid, kind, first, second, result, _, _ in RULES:
        for r in (first, (second or '').lstrip('^'), result):
            assert not r or r in RELATIONS, (rid, r)
    ids = [n[0] for n in NODES]
    assert len(ids) == len(set(ids)), 'trùng mã nút'


def main():
    class_of = {n[0]: n[1] for n in NODES} | {f'doc-{a}': 'document' for a in ARTICLES}
    check(class_of)
    out = [
        '/*\n * Họ tên: Nguyễn Tâm Bình\n * MSSV:   2324801030003\n * Môn:    Kiến trúc và thiết kế phần mềm\n'
        ' * Bài:    Đồ án TBT Center đa quốc gia\n * Ngày:   2026-10-18\n */\n',
        '-- File sinh bằng tools/knowledge_graph/build.py, không sửa tay.',
        '-- Chạy lại nhiều lần được: chỉ thay phần do người soạn, giữ nút và cạnh AI trích xuất đã duyệt.',
        'begin;',
        "delete from kg_edges where origin in ('curated', 'inferred');",
        'delete from kg_rules;',
    ]
    for cid, parent, labels in CLASSES:
        out.append(f'insert into kg_classes (id, parent, labels) values ({lit(cid)}, {lit(parent)}, {lit(langs(labels))}) '
                   'on conflict (id) do update set parent = excluded.parent, labels = excluded.labels;')
    for rid, (labels, domain, rng, props, summary) in RELATIONS.items():
        out.append(
            'insert into kg_relations (id, labels, summaries, domain, range, is_transitive, is_symmetric, inverse_of, '
            f'sub_property_of, derived) values ({lit(rid)}, {lit(langs(labels))}, {lit(langs(summary))}, {arr(domain)}, '
            f"{arr(rng)}, {str(bool(props.get('transitive'))).lower()}, {str(bool(props.get('symmetric'))).lower()}, "
            f"{lit(props.get('inverse'))}, {lit(props.get('sub_of'))}, {str(bool(props.get('derived'))).lower()}) "
            'on conflict (id) do update set labels = excluded.labels, summaries = excluded.summaries, '
            'domain = excluded.domain, range = excluded.range, is_transitive = excluded.is_transitive, '
            'is_symmetric = excluded.is_symmetric, inverse_of = excluded.inverse_of, '
            'sub_property_of = excluded.sub_property_of, derived = excluded.derived;')
    for i, (rid, kind, first, second, result, visible, labels) in enumerate(RULES):
        out.append('insert into kg_rules (id, ordinal, kind, first, second, result, visible, labels) values '
                   f'({lit(rid)}, {i}, {lit(kind)}, {lit(first)}, {lit(second)}, {lit(result)}, '
                   f'{str(visible).lower()}, {lit(langs(labels))});')
    curated = []
    for nid, cls, labels, aliases, summary in NODES:
        al = sorted({fold(a) for a in [*aliases, *labels] if len(fold(a)) >= 2})
        curated.append(nid)
        out.append(
            'insert into kg_nodes (id, type, class_id, labels, summaries, aliases, origin) values '
            f"({lit(nid)}, {lit(display_type(cls))}, {lit(cls)}, {lit(langs(labels))}, {lit(langs(summary))}, {arr(al)}, "
            "'curated') on conflict (id) do update set type = excluded.type, class_id = excluded.class_id, "
            'labels = excluded.labels, summaries = excluded.summaries, aliases = excluded.aliases, '
            "article_id = null, origin = 'curated';")
    for aid, (vi, en) in ARTICLES.items():
        curated.append(f'doc-{aid}')
        out.append(
            'insert into kg_nodes (id, type, class_id, labels, summaries, aliases, article_id, origin) values '
            f"({lit('doc-' + aid)}, 'document', 'document', {lit(langs((vi, en)))}, '{{}}', '{{}}', {lit(aid)}, 'curated') "
            'on conflict (id) do update set labels = excluded.labels, article_id = excluded.article_id, '
            "type = 'document', class_id = 'document', origin = 'curated';")
    out.append(f"delete from kg_nodes where origin = 'curated' and id <> all({arr(curated)});")
    seen = set()
    for s, rel, t in EDGES:
        if (s, rel, t) in seen:
            continue
        seen.add((s, rel, t))
        note = EDGE_NOTES.get((s, rel, t))
        out.append(f"insert into kg_edges (source, relation, target, note, origin) values "
                   f"({lit(s)}, {lit(rel)}, {lit(t)}, {lit(note)}, 'curated') "
                   "on conflict (source, relation, target) do update set note = excluded.note, origin = 'curated', "
                   'rule_id = null, premises = null;')
    out.append('commit;')
    OUT.write_text('\n'.join(out) + '\n', encoding='utf-8', newline='\n')
    print(f'{len(CLASSES)} lớp, {len(RELATIONS)} quan hệ, {len(RULES)} luật, '
          f'{len(curated)} nút, {len(seen)} cạnh -> {OUT.name}')


if __name__ == '__main__':
    main()
