# Hướng dẫn dev mới — App Chat Zalo (Flutter + Firebase)

Dev mới vào **không cần cài Flutter, JDK, Android SDK, Gradle** ngay. Chạy Docker trước, setup local sau.

---

## Yêu cầu duy nhất (one-time)

1. Cài **Docker Desktop**: https://www.docker.com/products/docker-desktop/
2. Bật **WSL2** (Windows): `wsl --install` → khởi động lại máy
3. Mở Docker Desktop, đợi trạng thái **Running**

---

## 3 lệnh onboarding

Mở terminal tại thư mục `chat_app`:

```powershell
cd "D:\Backup data\git\APP chat zalo\chat_app"
```

### Lệnh 1 — Chạy app Web (xem UI ngay)

```powershell
.\scripts\dev.ps1 web
```

Hoặc không dùng script:

```powershell
docker compose up --build web
```

Mở trình duyệt: **http://localhost:8080**

Dừng: `Ctrl+C` hoặc `docker compose down`

---

### Lệnh 2 — Build APK Android (không cần Android Studio)

```powershell
.\scripts\dev.ps1 apk
```

Hoặc:

```powershell
docker compose --profile build run --rm apk
```

APK output: **`docker-output/app-release.apk`**

Copy file này sang điện thoại Android và cài (bật "Unknown sources").

> Lần đầu build APK mất **10–20 phút** (tải image Flutter + Gradle cache).

---

### Lệnh 3 — Setup Flutter local (khi cần debug sâu)

Sau khi đã chạy được bằng Docker, mới cần bước này:

```powershell
.\scripts\dev.ps1 setup-fvm
```

Script sẽ:
- Cài **FVM** (Flutter Version Manager)
- Pin Flutter **3.29.3** — khớp Docker image
- Chạy `flutter pub get`

Chạy local:

```powershell
fvm flutter run -d chrome      # Web
fvm flutter run -d android       # Android (cần emulator/thiết bị)
```

---

## Toolchain đã pin (tránh "máy tôi chạy được")

| Thành phần | Version |
|------------|---------|
| Flutter | **3.29.3** (`.fvmrc`, Docker) |
| Dart | 3.7.2 |
| Gradle | 8.5 (`android/gradle/wrapper`) |
| Kotlin | 1.9.0 |
| compileSdk | 35 |

**Không tự ý `flutter upgrade`** trên branch basecode cũ. Nâng cấp dependency làm trên branch riêng.

---

## Kiến trúc Docker

```
chat_app/
├── Dockerfile.web       → build Flutter Web + Nginx :8080
├── Dockerfile.android   → build APK (one-shot)
├── docker-compose.yml
├── .fvmrc               → pin Flutter local
└── scripts/dev.ps1      → wrapper 3 lệnh trên
```

| Service | Mục đích | Port / Output |
|---------|----------|---------------|
| `web` | Chạy giao diện web | http://localhost:8080 |
| `apk` (profile `build`) | Build file cài Android | `docker-output/app-release.apk` |

---

## Firebase

App dùng Firebase cloud (`app-zalo-6c0f6`). Docker **chỉ build/host frontend** — Auth, Firestore, Storage vẫn cần internet và project Firebase còn hoạt động.

---

## Troubleshooting

| Lỗi | Cách xử lý |
|-----|------------|
| `docker: command not found` | Cài Docker Desktop, khởi động lại terminal |
| Port 8080 bận | Đổi port trong `docker-compose.yml`: `"8888:80"` |
| Build APK fail Gradle | Chạy lại `.\scripts\dev.ps1 apk` — cache Gradle nằm trong container |
| Web trắng / lỗi Firebase | Kiểm tra internet + Firebase console |
| Muốn xóa cache Docker | `docker compose down --rmi local` |

---

## Quy trình khuyến nghị cho dev mới

```
Ngày 1:  dev.ps1 web     → thấy app chạy
Ngày 1:  dev.ps1 apk     → có file APK test trên máy
Ngày 2+: dev.ps1 setup-fvm → debug/hot reload local
```

Liên hệ team lead nếu Firebase rules hết hạn hoặc cần quyền Firebase console.
