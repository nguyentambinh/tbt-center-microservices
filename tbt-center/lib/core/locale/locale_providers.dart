/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/api_client.dart';
import 'geo_service.dart';

const supportedLanguages = ['vi', 'en', 'de', 'pt'];

const _languageKey = 'language';
const _simulatedIpKey = 'geo_simulated_ip';
const _simulatedCountryKey = 'geo_simulated_country';

/// Nạp sẵn trong main() rồi override, để đọc đồng bộ ở mọi nơi.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Chưa override sharedPreferencesProvider'),
);

final geoServiceProvider = Provider<GeoService>((ref) => GeoService(ref.watch(apiClientProvider)));

/// Kết quả dò vị trí; `null` khi không gọi được server (app vẫn chạy với mặc định).
final geoProvider = FutureProvider<GeoResult?>((ref) async {
  final prefs = ref.watch(sharedPreferencesProvider);
  try {
    return await ref.watch(geoServiceProvider).detect(
          ip: prefs.getString(_simulatedIpKey),
          country: prefs.getString(_simulatedCountryKey),
        );
  } on Exception {
    return null;
  }
});

/// Ngôn ngữ người dùng tự chọn trong Cài đặt; `null` là tự động theo vị trí.
class LanguageController extends Notifier<String?> {
  @override
  String? build() => ref.watch(sharedPreferencesProvider).getString(_languageKey);

  Future<void> choose(String? language) async {
    final prefs = ref.read(sharedPreferencesProvider);
    if (language == null) {
      await prefs.remove(_languageKey);
    } else {
      await prefs.setString(_languageKey, language);
    }
    state = language;
  }
}

final languageControllerProvider = NotifierProvider<LanguageController, String?>(LanguageController.new);

/// Thứ tự ưu tiên: người dùng chọn → theo IP → ngôn ngữ máy → tiếng Việt.
final appLocaleProvider = Provider<Locale>((ref) {
  final chosen = ref.watch(languageControllerProvider);
  final fromGeo = ref.watch(geoProvider).value?.language;
  final device = PlatformDispatcher.instance.locale.languageCode;
  final language = chosen ?? fromGeo ?? (supportedLanguages.contains(device) ? device : 'vi');
  return Locale(language);
});

/// Khu vực nhận dữ liệu khi chưa đăng nhập (ứng viên nộp hồ sơ).
/// Nhân viên đã đăng nhập luôn dùng claim `region` trong token, không dùng giá trị này.
final submitRegionProvider = Provider<String>((ref) => ref.watch(geoProvider).value?.region ?? 'vn');

class LocationSimulator {
  LocationSimulator(this._ref);

  final Ref _ref;

  SharedPreferences get _prefs => _ref.read(sharedPreferencesProvider);

  String? get ip => _prefs.getString(_simulatedIpKey);
  String? get country => _prefs.getString(_simulatedCountryKey);

  Future<void> simulate({String? ip, String? country}) async {
    await _prefs.remove(_simulatedIpKey);
    await _prefs.remove(_simulatedCountryKey);
    if (ip != null && ip.isNotEmpty) await _prefs.setString(_simulatedIpKey, ip);
    if (country != null && country.isNotEmpty) {
      await _prefs.setString(_simulatedCountryKey, country.toUpperCase());
    }
    _ref.invalidate(geoProvider);
  }

  Future<void> clear() => simulate();
}

final locationSimulatorProvider = Provider<LocationSimulator>(LocationSimulator.new);
