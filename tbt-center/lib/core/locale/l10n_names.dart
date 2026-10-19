/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import '../../l10n/app_localizations.dart';
import '../theme/role_gem.dart';

extension LocalizedNames on AppLocalizations {
  String gemName(RoleGem gem) => switch (gem) {
        RoleGem.gold => gemGold,
        RoleGem.platinum => gemPlatinum,
        RoleGem.emerald => gemEmerald,
        RoleGem.ruby => gemRuby,
        RoleGem.sapphire => gemSapphire,
        RoleGem.diamond => gemDiamond,
        RoleGem.amethyst => gemAmethyst,
      };

  String regionName(String region) => switch (region) {
        'de' => regionDe,
        'us' => regionUs,
        'br' => regionBr,
        'za' => regionZa,
        'au' => regionAu,
        _ => regionVn,
      };

  String roleName(String role) => switch (role) {
        'executive' => roleExecutive,
        'admin' => roleAdmin,
        'hr' => roleHr,
        'finance' => roleFinance,
        'employee' => roleEmployee,
        'auditor' => roleAuditor,
        _ => roleCandidate,
      };

  /// Tên ngôn ngữ luôn viết bằng chính ngôn ngữ đó để ai cũng nhận ra.
  static const languageNames = {'vi': 'Tiếng Việt', 'en': 'English', 'de': 'Deutsch', 'pt': 'Português (Brasil)'};
}
