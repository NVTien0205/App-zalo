#!/bin/sh
set -e

echo "==> Building release APK..."
flutter build apk --release

mkdir -p /output
APK="build/app/outputs/flutter-apk/app-release.apk"

if [ ! -f "$APK" ]; then
  echo "ERROR: APK not found at $APK"
  exit 1
fi

cp "$APK" /output/app-release.apk
echo "==> Done. APK saved to docker-output/app-release.apk"
