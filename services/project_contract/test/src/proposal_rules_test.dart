/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:archive/archive.dart';
import 'package:project_contract_service/src/data/project_repository.dart';
import 'package:project_contract_service/src/project_rules.dart';
import 'package:project_contract_service/src/proposal_ai.dart';
import 'package:project_contract_service/src/proposals.dart';
import 'package:tbt_common/tbt_common.dart';
import 'package:test/test.dart';

void main() {
  final today = DateTime(2026, 10, 25);

  group('phân cấp, cảnh báo, tiến độ', () {
    test('4 cấp theo giá trị quy USD', () {
      expect(projectTier(50000), 1);
      expect(projectTier(100000), 2);
      expect(projectTier(500000), 3);
      expect(projectTier(2000000), 4);
    });

    test('màu cảnh báo theo thời gian còn lại', () {
      String level(DateTime? start, DateTime end, [String s = 'in_progress']) =>
          warningLevel(start: start, end: end, status: s, today: today);
      final began = DateTime(2025);
      expect(level(began, DateTime(2026, 11, 10)), 'red');
      expect(level(began, DateTime(2026, 10)), 'red');
      expect(level(began, DateTime(2027, 3)), 'orange');
      expect(level(began, DateTime(2027, 9)), 'yellow');
      expect(level(began, DateTime(2029)), 'normal');
      expect(level(DateTime(2027), DateTime(2028)), 'not_started');
      expect(level(began, DateTime(2026, 11), 'accepted'), 'accepted');
    });

    test('tiến độ theo thời gian đã qua', () {
      expect(
        progressOf(
          start: DateTime(2026),
          end: DateTime(2027),
          status: 'in_progress',
          today: DateTime(2026, 7, 2),
        ),
        closeTo(0.5, 0.01),
      );
      expect(
        progressOf(
          start: DateTime(2026),
          end: DateTime(2027),
          status: 'accepted',
          today: today,
        ),
        1,
      );
    });
  });

  group('ràng buộc đề xuất', () {
    List<String> check({
      double value = 2500000000,
      DateTime? start,
      DateTime? end,
      DateTime? acceptance,
      int members = 3,
    }) => checkProposal(
      value: value,
      deposit: null,
      rateToUsd: 25000,
      start: start ?? DateTime(2026, 11),
      end: end ?? DateTime(2027, 6),
      acceptance: acceptance,
      members: members,
      today: today,
    );

    test('đề xuất hợp lệ', () => expect(check(), isEmpty));

    test('ngày bắt đầu đã qua, kết thúc trước bắt đầu', () {
      expect(check(start: DateTime(2026, 10)), contains('start_in_past'));
      expect(
        check(start: DateTime(2027), end: DateTime(2026, 12)),
        contains('end_before_start'),
      );
    });

    test('dự án cấp 1 làm quá 12 tháng', () {
      expect(
        check(value: 1500000000, end: DateTime(2028)),
        contains('too_long_for_tier'),
      );
    });

    test('cấp 3 cần ít nhất 5 người', () {
      expect(
        check(value: 12500000000, members: 4),
        contains('too_few_members'),
      );
    });

    test('nghiệm thu trước ngày kết thúc hoặc quá 90 ngày', () {
      expect(
        check(acceptance: DateTime(2027, 5)),
        contains('acceptance_out_of_range'),
      );
      expect(
        check(acceptance: DateTime(2027, 12)),
        contains('acceptance_out_of_range'),
      );
      expect(check(acceptance: DateTime(2027, 7)), isEmpty);
    });

    test('ProposalData chuẩn hóa ngày, số tiền và báo thiếu tên', () {
      final data = ProposalData.fromJson({
        'customerName': 'Công ty An Phát',
        'value': '2.500.000.000',
        'currency': 'vnd',
        'startDate': '2026-11-01T00:00:00Z',
        'endDate': '2027-06-01',
        'memberIds': ['E1', 'E2', 'E2', 'E3'],
      });
      expect(data.json['value'], 2500000000);
      expect(data.currency, 'VND');
      expect(data.json['startDate'], '2026-11-01');
      expect(data.memberIds, ['E1', 'E2', 'E3']);
      expect(data.errors(rateToUsd: 25000, today: today), ['name_required']);
    });
  });

  group('hai bên sửa qua lại', () {
    test('lãnh đạo sửa thì chờ bên lập, bên lập đồng ý thì duyệt', () {
      final s1 = nextProposalStatus(
        'awaiting_executive',
        ProposalSide.executive,
        'counter',
      );
      expect(s1, 'awaiting_proposer');
      expect(
        nextProposalStatus(s1, ProposalSide.proposer, 'counter'),
        'awaiting_executive',
      );
      expect(
        nextProposalStatus(s1, ProposalSide.proposer, 'approve'),
        'approved',
      );
    });

    test('không tự duyệt bản của mình, không sửa bản đã chốt', () {
      expect(
        () => nextProposalStatus(
          'awaiting_executive',
          ProposalSide.proposer,
          'approve',
        ),
        throwsA(isA<ProjectRuleViolation>()),
      );
      expect(
        () => nextProposalStatus('approved', ProposalSide.executive, 'counter'),
        throwsA(isA<ProjectRuleViolation>()),
      );
    });
  });

  group('AI dự phòng', () {
    test('đọc số tiền theo cách viết từng nước', () {
      expect(parseAmount('2.500.000.000'), 2500000000);
      expect(parseAmount('2,500,000.50 USD'), 2500000.5);
      expect(parseAmount('1.250.000,75 €'), 1250000.75);
      expect(parseAmount('12,5'), 12.5);
      expect(parseAmount('abc'), isNull);
    });

    test('chọn người ít dự án nhất, xen kẽ chức vụ', () {
      final people = [
        {'id': 'A', 'position': 'Kỹ sư'},
        {'id': 'B', 'position': 'Kỹ sư'},
        {'id': 'C', 'position': 'Thợ hồ'},
        {'id': 'D', 'position': 'Thợ hồ'},
        {'id': 'E', 'position': 'Giám sát'},
      ];
      final picked = ProposalAdvisor.pickByLoad(people, {'A': 3, 'C': 1}, 4);
      expect(picked, ['B', 'D', 'E', 'A']);
    });

    test('đọc chữ trong hợp đồng Word', () {
      final xml = [
        '<w:document><w:body>',
        '<w:p><w:r><w:t>HỢP ĐỒNG THI CÔNG</w:t></w:r></w:p>',
        '<w:p><w:r><w:t xml:space="preserve">Giá trị: </w:t></w:r>',
        '<w:r><w:t>2.500.000.000 VND &amp; VAT</w:t></w:r></w:p>',
        '</w:body></w:document>',
      ].join();
      final archive = Archive()
        ..addFile(ArchiveFile.string('word/document.xml', xml));
      final text = docxText(ZipEncoder().encode(archive));
      expect(text, 'HỢP ĐỒNG THI CÔNG\nGiá trị: 2.500.000.000 VND & VAT');
    });
  });
}
