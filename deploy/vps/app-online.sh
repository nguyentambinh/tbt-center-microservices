#!/bin/bash
# Build app trỏ về máy chủ thật, ghi đè APK trong BaoCao/apk và cài lên máy ảo Android.
# Cách dùng (từ thư mục gốc dự án): bash deploy/vps/app-online.sh [tên máy ảo] [--apkpure]
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/../.." && pwd)
AVD=${1:-Resizable_Experimental}
APP_ID=com.tbtcenter.tbtcenter
OUT="$ROOT/BaoCao/apk/TBTCenter_online_VPS.apk"
EMU="${LOCALAPPDATA:-$HOME/AppData/Local}/Android/Sdk/emulator/emulator.exe"

cd "$ROOT/tbt-center"
flutter build apk --release --dart-define-from-file=config/vps.json
mkdir -p "$(dirname "$OUT")"
cp build/app/outputs/flutter-apk/app-release.apk "$OUT"
# Chuẩn bị đăng kho ứng dụng: thêm --apkpure để chép bản này vào thư mục APKPure (không lên git)
[ "${2:-}" = "--apkpure" ] && mkdir -p "$ROOT/APKPure" && cp "$OUT" "$ROOT/APKPure/TBTCenter_online_VPS.apk"
(cd android && ./gradlew --stop >/dev/null 2>&1) || true

# Máy ảo chưa chạy thì bật ở tiến trình riêng (gpu host ổn định hơn swiftshader)
if ! adb devices | grep -q "^emulator-.*device$"; then
  powershell.exe -NoProfile -Command "Start-Process '$EMU' -ArgumentList '-avd','$AVD','-no-snapshot-load','-no-boot-anim','-gpu','host' -WindowStyle Minimized" </dev/null
  adb wait-for-device
  until [ "$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = "1" ]; do sleep 3; done
fi

# App online gọi thẳng máy chủ, bỏ các cổng adb reverse của bản dev
adb reverse --remove-all >/dev/null 2>&1 || true
if ! adb install -r "$OUT" >/dev/null 2>&1; then
  adb uninstall "$APP_ID" >/dev/null 2>&1 || true
  adb install "$OUT" >/dev/null
fi
echo "Đã cài $(basename "$OUT") ($(du -h "$OUT" | cut -f1)) lên $AVD"
