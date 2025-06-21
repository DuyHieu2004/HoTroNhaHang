<<<<<<< HEAD
<<<<<<< HEAD
# doan_nhom_cuoiky

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
=======
=======
>>>>>>> 4c39bec7b4b69bf893eacab27cf4e41cf0d8ed07
# Ứng Dụng Hỗ Trợ Nhà Hàng

Ứng dụng Flutter hỗ trợ quản lý nhà hàng với các tính năng đặt bàn, gọi món, thanh toán và quản lý nhân sự.

## Yêu Cầu Hệ Thống

### Phần Mềm Cần Thiết
- **Flutter SDK**: Phiên bản 3.7.0 trở lên
- **Dart SDK**: Đi kèm với Flutter
- **Android Studio** hoặc **Visual Studio Code**
- **Git**
- **Java JDK**: Phiên bản 8 trở lên (cho Android)

### Thiết Bị
- **Android**: API level 21 (Android 5.0) trở lên
- **iOS**: iOS 12.0 trở lên
- **Máy tính**: Windows, macOS, hoặc Linux

## Cài Đặt Môi Trường

### 1. Cài Đặt Flutter

#### Windows:
```bash
# Tải Flutter SDK từ https://flutter.dev/docs/get-started/install/windows
# Giải nén và thêm vào PATH
flutter doctor
```

#### macOS:
```bash
# Sử dụng Homebrew
brew install flutter
flutter doctor
```

### 2. Cài Đặt Android Studio
- Tải và cài đặt Android Studio từ [developer.android.com](https://developer.android.com/studio)
- Cài đặt Android SDK và Android SDK Command-line Tools
- Tạo Android Virtual Device (AVD) để test

### 3. Cấu Hình IDE

#### Visual Studio Code:
```bash
# Cài đặt extensions
# - Flutter
# - Dart
```

#### Android Studio:
- Cài đặt Flutter plugin
- Cài đặt Dart plugin

## Cài Đặt Dự Án

### 1. Clone Repository
```bash
git clone <repository-url>
cd DoAn_DiDong
```

### 2. Cài Đặt Dependencies
```bash
flutter pub get
```

### 3. Cấu Hình Firebase

#### Bước 1: Tạo Firebase Project
1. Truy cập [Firebase Console](https://console.firebase.google.com/)
2. Tạo project mới hoặc sử dụng project có sẵn
3. Kích hoạt các services:
   - **Authentication** (Email/Password)
   - **Cloud Firestore**
   - **Storage**

#### Bước 2: Cấu Hình Android
1. Thêm Android app vào Firebase project
2. Tải file `google-services.json`
3. Đặt file vào `android/app/`

#### Bước 3: Cấu Hình iOS (nếu cần)
1. Thêm iOS app vào Firebase project
2. Tải file `GoogleService-Info.plist`
3. Đặt file vào `ios/Runner/`

#### Bước 4: Cài Đặt Firebase CLI
```bash
npm install -g firebase-tools
firebase login
flutter packages pub run build_runner build
```

### 4. Cấu Hình Permissions

#### Android (`android/app/src/main/AndroidManifest.xml`):
<<<<<<< HEAD


```xml
   <uses-permission android:name="android.permission.INTERNET" />
   <uses-permission android:name="android.permission.CAMERA" />
   <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
   <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
   <uses-permission android:name="android.permission.ACCESS_NOTIFICATION_POLICY" />
=======
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.ACCESS_NOTIFICATION_POLICY" />
>>>>>>> 4c39bec7b4b69bf893eacab27cf4e41cf0d8ed07
```

## Chạy Ứng Dụng

### 1. Kiểm Tra Thiết Bị
```bash
flutter devices
```

### 2. Chạy Ứng Dụng

#### Debug Mode:
```bash
flutter run
```

#### Release Mode:
```bash
flutter run --release
```

#### Chạy trên thiết bị cụ thể:
```bash
flutter run -d <device-id>
```

### 3. Hot Reload
Trong khi ứng dụng đang chạy:
- Nhấn `r` để hot reload
- Nhấn `R` để hot restart
- Nhấn `q` để thoát

## Build Ứng Dụng

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle
```bash
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## Cấu Trúc Dự Án

```
lib/
├── main.dart                 # Entry point
├── models/                   # Data models
│   ├── Ban.dart
│   ├── DonGoiMon.dart
│   ├── KhachHang.dart
│   └── ...
├── providers/                # State management
│   ├── BanProvider.dart
│   ├── DonGoiMonProvider.dart
│   └── ...
├── screens/                  # UI screens
│   ├── Home_Screen.dart
│   ├── LogIn_Screen.dart
│   ├── GoiMonScreen.dart
│   └── ...
├── services/                 # Business logic
└── utils/                    # Utilities
```

## Tính Năng Chính

- **🔐 Đăng nhập/Đăng ký**: Xác thực người dùng
- **🍽️ Quản lý bàn**: Xem trạng thái và đặt bàn
- **📋 Gọi món**: Chọn món ăn và tạo đơn hàng
- **💳 Thanh toán**: Xử lý thanh toán đơn hàng
- **👥 Quản lý nhân sự**: Quản lý thông tin nhân viên
- **📊 Thống kê**: Báo cáo doanh thu và hoạt động
- **🔔 Thông báo**: Nhận thông báo real-time

## Troubleshooting

### Lỗi Thường Gặp

#### 1. Flutter Doctor Issues
```bash
flutter doctor -v
# Làm theo hướng dẫn để fix các issues
```

#### 2. Gradle Build Failed
```bash
cd android
.\gradlew clean
cd ..
flutter clean
flutter pub get
```

#### 3. Firebase Connection Issues
- Kiểm tra file `google-services.json`
- Đảm bảo package name khớp với Firebase project
- Kiểm tra internet connection

#### 4. Permission Denied
```bash
# Trên thiết bị Android, cấp quyền thủ công trong Settings
# Hoặc chạy:
adb shell pm grant com.example.doan_nhom_cuoiky android.permission.CAMERA
```

### Debug Tips

1. **Sử dụng Flutter Inspector** trong IDE
2. **Kiểm tra logs**:
   ```bash
   flutter logs
   ```
3. **Debug trên thiết bị thật** để test đầy đủ tính năng

## Đóng Góp

1. Fork repository
2. Tạo feature branch
3. Commit changes
4. Push to branch
5. Tạo Pull Request

## Liên Hệ

Nếu gặp vấn đề, vui lòng tạo issue trên GitHub hoặc liên hệ team phát triển.

---

**Lưu ý**: Đảm bảo cấu hình Firebase đúng cách trước khi chạy ứng dụng. Ứng dụng cần kết nối internet để hoạt động đầy đủ các tính năng.
        
<<<<<<< HEAD
>>>>>>> 4c39bec7b4b69bf893eacab27cf4e41cf0d8ed07
=======
>>>>>>> 4c39bec7b4b69bf893eacab27cf4e41cf0d8ed07
