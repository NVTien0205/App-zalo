# Android Studio Setup Guide — Chat App (Flutter)

> Hướng dẫn cài đặt, cấu hình và chạy project Chat App trên Android Studio cho **Fresher Android**.

---

## 1. Yêu cầu hệ thống

| Thành phần | Phiên bản khuyến nghị |
|------------|----------------------|
| **Android Studio** | Stable mới nhất (Koala / Jellyfish / Iguana) |
| **Flutter SDK** | 3.29.x (xem `.fvmrc`) — dùng `fvm` để quản lý |
| **Android SDK** | Platform 34 (compileSdk), Build-Tools 34.0.0 |
| **JDK** | 17 (bundled trong Android Studio) |
| **Git** | 2.x |
| **OS** | Windows 10/11, macOS, Linux |

---

## 2. Cài đặt công cụ

### 2.1 Android Studio
1. Tải tại [developer.android.com/studio](https://developer.android.com/studio)
2. Cài đặt → chọn **Standard Install** → bao gồm:
   - Android SDK (API 34)
   - Android SDK Build-Tools 34.0.0
   - Android Emulator
   - Android SDK Platform-Tools
   - Intel x86 Emulator Accelerator (HAXM) / Hypervisor (macOS/Linux)

### 2.2 Flutter (qua FVM — khuyến nghị)
```bash
# Cài FVM
dart pub global activate fvm

# Cài Flutter version đúng project
fvm install          # đọc .fvmrc → cài 3.29.3
fvm use              # set version cho project
```

> **Lưu ý:** Mọi lệnh Flutter chạy qua `fvm flutter ...` (VD: `fvm flutter run`, `fvm flutter build apk`)

### 2.3 Git
```bash
# Cấu hình identity (lần đầu)
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

---

## 3. Clone & Mở project

```bash
# Clone repo
git clone https://github.com/NVTien0205/App-zalo.git
cd App-zalo

# Mở Android Studio
# File → Open → chọn thư mục `android/` (KHÔNG phải root project)
```

> **Quan trọng:** Mở thư mục `android/` để Android Studio nhận diện là project Gradle. Code Dart chỉnh sửa ở `lib/` (dùng VS Code hoặc Android Studio + Dart plugin).

---

## 4. Cấu hình Local (chạy 1 lần)

### 4.1 `local.properties` (Android SDK path)
File `android/local.properties` **không commit** — Android Studio tự tạo khi Sync Gradle. Nếu chưa có:
```properties
# Windows
sdk.dir=C:\\Users\\<username>\\AppData\\Local\\Android\\Sdk

# macOS/Linux
sdk.dir=/Users/<username>/Library/Android/sdk
```

### 4.2 Cấp quyền Gradle wrapper
```bash
chmod +x android/gradlew
```

### 4.3 Cấu hình Firebase (BẮT BUỘC)
File `android/app/google-services.json` **đã trong `.gitignore`** — không có trong repo.

**Làm 1 lần:**
1. Vào [Firebase Console](https://console.firebase.google.com) → Project `app-zalo-6c0f6`
2. ⚙️ Project settings → **Your apps** → Android app `com.example.chat_app`
3. **Download `google-services.json`**
4. Copy vào: `android/app/google-services.json`

> Nếu chưa có app Android trong project → **Add app** → package name `com.example.chat_app` → Download.

---

## 5. Chạy App

### Cách 1: Android Studio UI (Debug)
1. Mở project `android/` trong Android Studio
2. Chờ Gradle Sync xanh
2. Chọn device/emulator (toolbar) → ▶️ **Run** (Shift+F10)

### Cách 2: CLI (Nhanh, khuyến nghị)
```bash
# Kiểm tra device
flutter devices

# Chạy debug (hot reload)
fvm flutter run -d <device_id>

# Build APK debug
fvm flutter build apk --debug

# Install lên máy thật
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

---

## 6. Quy tắc Code Style & Git Workflow

### Code Style
| Quy tắc | Công cụ |
|---------|---------|
| Format code | `dart format .` hoặc `Ctrl+Alt+L` (Android Studio) |
| Lint | `flutter analyze` (phải pass — 0 error) |
| Naming convention | File: `snake_case` \| Class: `PascalCase` \| Biến/hàm: `camelCase` |
| Import | Relative import cho file trong package, absolute cho package extern |

### Git Workflow (Feature Branch)
```bash
# 1. Tạo branch từ develop/main
git checkout -b feature/ticket-name

# 2. Code → test → commit
git add .
git commit -m "feat: mô tả ngắn gọn"

# 3. Push
git push -u origin feature/ticket-name

# 4. Tạo Pull Request trên GitHub → review → merge
```

**Commit message format:**
```
<type>: <mô tả ngắn>

Types: feat | fix | chore | refactor | docs | test | style
VD: feat: add AuthService interface
```

---

## 7. Debug Thường Gặp

| Lỗi | Nguyên nhân | Fix |
|-----|------------|-----|
| `google-services.json not found` | Chưa tải file từ Firebase Console | Tải file → đặt vào `android/app/` |
| `Gradle sync failed` | Cache gradle cũ / SDK mismatch | `flutter clean` → `flutter pub get` → `cd android && ./gradlew clean` |
| `sign-in provider disabled` | Email/Password chưa bật trên Firebase Console | Console → Authentication → Sign-in method → Enable Email/Password |
| `No AppCheckProvider installed` | Chưa cài App Check | Warning thường, không chặn tính năng |
| `Null check operator used on null value` (Firestore) | Document không tồn tại → `.data() as Map` crash | Guard null trước khi cast: `final data = doc.data(); if (data == null) return;` |
| `Execution policy` (PowerShell) | Script không ký | Chạy `firebase.cmd login` hoặc `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass` |

---

## 8. Build Release (Khi cần)

```bash
# Cần keystore release (chỉ lead/devops giữ)
# Cấu hình android/app/build.gradle:
# signingConfigs {
#   release {
#     keyAlias keystore.properties['keyAlias']
#     keyPassword keystore.properties['keyPassword']
#     storeFile file(keystore.properties['storeFile'])
#     storePassword keystore.properties['storePassword']
#   }
# }

fvm flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

---

## 8. Cấu trúc Thư Mục Quan Trọng

```
App-zalo/
├── android/                 # Project Gradle (mở bằng Android Studio)
│   ├── app/
│   │   ├── google-services.json   # (gitignore) - CẦN TẢI TỪ FIREBASE
│   │   ├── build.gradle           # Cấu hình signing, dependencies
│   │   └── src/main/AndroidManifest.xml
│   └── build.gradle
├── lib/                       # Code Dart chính
│   ├── main.dart              # Entry point
│   ├── app/                   # App shell, routes, bootstrap
│   ├── core/                  # Core utils, errors, widgets
│   ├── features/              # Feature-first modules
│   │   ├── auth/              # Authentication
│   │   ├── user/              # User profile
│   │   └── ...
│   └── models/                # Data models
├── test/                      # Unit/widget tests
├── firebase.json              # Firebase hosting, rules config
├── firestore.rules            # Security rules
├── .fvmrc                     # Flutter version pin (3.29.3)
├── .gitignore
└── pubspec.yaml               # Dependencies
```

---

## 9. Tài Liệu Tham Khảo

| File | Mô tả |
|------|-------|
| `lib/app/constants/firestore_paths.dart` | Đường dẫn Firestore collection/document |
| `lib/core/errors/result.dart` | `Result<T>` pattern (Success/Failure) |
| `lib/core/errors/auth_error_mapper.dart` | Map Firebase error code → message VN |
| `lib/features/auth/domain/auth_service.dart` | Interface Auth (DI ready) |
| `lib/features/auth/data/firebase_auth_service.dart` | Impl Firebase Auth |
| `firebase.json` | Hosting, Firestore rules, indexes config |

---

## 10. Checklist Trước Khi Commit

- [ ] `flutter analyze` → 0 error
- [ ] `flutter test` → all pass
- [ ] `dart format .` → no diff
- [ ] Commit message đúng format
- [ ] Không commit file nhạy cảm (`google-services.json`, `.env`, `local.properties`, keystore)

---

## 11. Liên Hệ / Hỗ Trợ

- **Lead/Architect:** xem `ARCHITECTURE.md` (khi có)
- **Issues:** GitHub Issues
- **Firebase Console:** https://console.firebase.google.com/project/app-zalo-6c0f6

---

> **Lưu ý:** Project là **Flutter** (cross-platform). Android Studio dùng để build/run native layer, debug Gradle, emulator. Code Dart viết ở `lib/` — khuyến nghị dùng **VS Code + Dart extension** hoặc Android Studio + Dart plugin cho việc viết code hàng ngày.