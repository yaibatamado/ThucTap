# Hướng dẫn tuần 1 - Cao Thiên

## 0. Phạm vi công việc tuần 1

Theo file phân công, phần của **5. Cao Thiên - Tuần 1** là:

> Khởi tạo dự án Mobile App Flutter, cấu hình cấu trúc State Management (Bloc/Provider/GetX) và cài đặt các package kết nối API (Dio/Http).

Source giao diện app cơ bản đã nằm trong thư mục:

```powershell
D:\DuAnThucTap\AppBenhVien
```

Tuần 1 chưa cần làm các chức năng đặt lịch, OTP, chat AI hay thanh toán. Mục tiêu là cài môi trường, mở được app Flutter hiện có, chạy được app, và hiểu các file nền tảng đã có.

## 1. Kiểm tra máy hiện tại

Bạn đang có Java 21:

```powershell
java -version
```

Kết quả hiện tại đã kiểm tra được:

```text
java version "21.0.10" 2026-01-20 LTS
```

Git đã có:

```powershell
git --version
```

Kết quả hiện tại:

```text
git version 2.51.0.windows.1
```

Flutter hiện chưa có trong PATH, nên lệnh này sẽ lỗi cho đến khi bạn cài Flutter:

```powershell
flutter --version
```

## 2. Cài Android Studio

1. Truy cập:

```text
https://developer.android.com/studio
```

2. Tải bản Android Studio cho Windows.
3. Mở file cài đặt, cứ để mặc định và bấm Next/Install.
4. Sau khi cài xong, mở Android Studio.
5. Nếu Android Studio hỏi cài Android SDK, chọn cài theo mặc định.

### 2.1. Cài SDK cần thiết

Trong Android Studio:

1. Vào `More Actions`.
2. Chọn `SDK Manager`.
3. Tab `SDK Platforms`: tick Android mới nhất có sẵn, ví dụ Android 15 hoặc Android 16.
4. Tab `SDK Tools`: tick các mục:
   - Android SDK Command-line Tools
   - Android SDK Platform-Tools
   - Android SDK Build-Tools
   - Android Emulator
5. Bấm `Apply`.
6. Chờ tải xong.

### 2.2. Tạo máy ảo Android

1. Trong Android Studio, vào `More Actions`.
2. Chọn `Device Manager`.
3. Chọn `Create Virtual Device`.
4. Chọn máy như `Pixel 6` hoặc `Pixel 7`.
5. Chọn system image có `Google APIs`.
6. Bấm `Download` nếu chưa có.
7. Bấm `Finish`.
8. Bấm nút Play để mở emulator.

## 3. Cài Flutter SDK

1. Truy cập trang cài Flutter cho Windows:

```text
https://docs.flutter.dev/get-started/install/windows/mobile
```

2. Tải Flutter SDK dạng `.zip`.
3. Giải nén vào:

```text
E:\flutter_windows_3.44.1-stable\flutter
```

Sau khi giải nén, file `flutter.bat` phải nằm ở:

```text
E:\flutter_windows_3.44.1-stable\flutter\bin\flutter.bat
```

### 3.1. Thêm Flutter vào PATH

1. Bấm Start.
2. Tìm `Environment Variables`.
3. Mở `Edit the system environment variables`.
4. Bấm `Environment Variables`.
5. Ở phần `User variables`, chọn biến `Path`.
6. Bấm `Edit`.
7. Bấm `New`.
8. Thêm dòng:

```text
E:\flutter_windows_3.44.1-stable\flutter\bin
```

9. Bấm OK hết các cửa sổ.
10. Đóng PowerShell cũ, mở PowerShell mới.

Kiểm tra:

```powershell
flutter --version
flutter doctor
```

Nếu Flutter báo thiếu Android license, chạy:

```powershell
flutter doctor --android-licenses
```

Khi được hỏi, bấm `y` để đồng ý từng license.

## 4. Mở project app có sẵn

Mở PowerShell mới và chạy:

```powershell
cd "D:\DuAnThucTap\AppBenhVien"
```

Tải package Flutter:

```powershell
flutter pub get
```

Kiểm tra lỗi code:

```powershell
flutter analyze
```

Mở emulator Android trong Android Studio, sau đó chạy app:

```powershell
flutter run
```

Nếu có nhiều thiết bị, xem danh sách:

```powershell
flutter devices
```

Chạy vào đúng thiết bị:

```powershell
flutter run -d <device_id>
```

Ví dụ:

```powershell
flutter run -d emulator-5554
```

## 5. Nếu app báo lỗi Gradle/JDK

Bạn đang dùng Java 21. Flutter/Android thường chạy ổn với JDK đi kèm Android Studio hoặc JDK 17. Nếu gặp lỗi Gradle liên quan Java, làm theo thứ tự này:

1. Mở Android Studio.
2. Vào `Settings`.
3. Vào `Build, Execution, Deployment`.
4. Vào `Build Tools`.
5. Vào `Gradle`.
6. Ở `Gradle JDK`, chọn JDK đi kèm Android Studio, thường có tên `jbr`.
7. Chạy lại:

```powershell
flutter clean
flutter pub get
flutter run
```

Chỉ cài thêm JDK 17 nếu Android Studio không có JDK đi kèm hoặc Gradle vẫn báo lỗi.

## 6. Các package tuần 1 đã có trong project

File cần xem:

```text
D:\DuAnThucTap\AppBenhVien\pubspec.yaml
```

Các package quan trọng đã có:

```yaml
provider: ^6.1.2
go_router: ^14.1.4
http: ^1.2.1
shared_preferences: ^2.2.3
jwt_decode: ^0.3.1
socket_io_client: ^2.0.3
intl: ^0.20.2
image_picker: ^1.0.4
```

Nếu sau này cần tự thêm package, dùng mẫu:

```powershell
flutter pub add ten_package
flutter pub get
```

Ví dụ nếu muốn dùng Dio thay HTTP:

```powershell
flutter pub add dio
flutter pub get
```

Hiện tại không cần thêm Dio vì app đã dùng `http`.

## 7. State Management đang dùng Provider

File chính:

```text
D:\DuAnThucTap\AppBenhVien\lib\auth\auth_provider.dart
```

File này đang quản lý:

- token đăng nhập
- role người dùng
- mã tài khoản
- mã bệnh nhân
- mã bác sĩ
- loại nhân sự
- trạng thái loading

Provider được gắn vào app tại:

```text
D:\DuAnThucTap\AppBenhVien\lib\main.dart
```

Đoạn quan trọng:

```dart
ChangeNotifierProvider(
  create: (context) => AuthProvider(),
  child: MyApp(),
)
```

Kết luận để ghi báo cáo: app dùng `Provider` kết hợp `ChangeNotifier` để quản lý trạng thái đăng nhập và phân quyền.

## 8. Kết nối API đang dùng HTTP

File chính:

```text
D:\DuAnThucTap\AppBenhVien\lib\services\api_client.dart
```

Base URL hiện tại:

```dart
const String _baseUrl = 'http://10.0.2.2:4000/api';
```

Lưu ý:

- Khi app chạy trên Android Emulator, không gọi backend bằng `localhost`.
- Emulator dùng `10.0.2.2` để trỏ về máy tính thật.
- Nếu backend chạy port `4000`, URL đúng là `http://10.0.2.2:4000/api`.

Các hàm API đã có:

- `get`
- `post`
- `put`
- `delete`
- `postMultipart`

Kết luận để ghi báo cáo: app đã có lớp `ApiClient` dùng chung để gọi REST API bằng package `http`, tự gắn `Bearer token` vào header khi có token.

## 9. Router và phạm vi Cao Thiên các tuần sau

File router:

```text
D:\DuAnThucTap\AppBenhVien\lib\routes\app_router.dart
```

Các route bệnh nhân liên quan trực tiếp đến Cao Thiên:

```text
/patient
/patient/lich
/patient/hoso
/patient/xetnghiem
/patient/hoadon
/patient/taikhoan
/patient/payment/qr/:maLich
```

Tuần 1 chỉ cần biết các route này đã tồn tại. Các tuần sau mới phát triển sâu vào đăng nhập, đặt lịch, sổ sức khỏe, chat AI và thanh toán QR.

## 10. Nếu phải tạo project Flutter mới từ đầu

Chỉ dùng phần này nếu source hiện có bị hỏng hoặc muốn tạo lại app trắng. Với dự án hiện tại, ưu tiên dùng source trong `AppBenhVien`.

Tạo project mới:

```powershell
cd "D:\DuAnThucTap"
flutter create hospital_app_frontend
cd "D:\DuAnThucTap\hospital_app_frontend"
```

Thêm package:

```powershell
flutter pub add provider go_router http shared_preferences intl jwt_decode font_awesome_flutter socket_io_client image_picker
flutter pub get
```

Chạy app:

```powershell
flutter run
```

Sau đó copy các thư mục/file từ app giao diện cũ sang project mới:

- `lib`
- `android`
- `pubspec.yaml`

Nhưng hiện tại không nên làm lại từ đầu vì `D:\DuAnThucTap\AppBenhVien` đã là project Flutter đầy đủ.

## 11. Checklist hoàn thành tuần 1

- [x] Android Studio đã cài xong.
- [x] Android SDK, Platform Tools, Build Tools, Emulator đã cài.
- [x] Đã tạo và mở Android Emulator.
- [x] Flutter SDK đã giải nén vào `E:\flutter_windows_3.44.1-stable\flutter`.
- [x] Đã mở project tại `D:\DuAnThucTap\AppBenhVien`.
- [x] Chạy được `flutter pub get`.
- [x] Chạy được app trên Android Emulator.
- [x] Kiểm tra file nền tảng tuần 1 bằng `flutter analyze`.
- [x] Ghi báo cáo: state management dùng Provider.
- [x] Ghi báo cáo: kết nối API dùng HTTP qua `ApiClient`.

Ghi chú: khi chạy `flutter analyze` toàn bộ project, các màn hình chức năng có sẵn vẫn còn cảnh báo lint. Riêng các file trọng tâm của tuần 1 gồm `lib/main.dart`, `lib/auth/auth_provider.dart` và `lib/services/api_client.dart` đã kiểm tra không còn issue.

## 12. Nội dung có thể ghi vào báo cáo tuần 1

Trong tuần 1, em đã khởi tạo và cấu hình môi trường phát triển Mobile App Flutter cho hệ thống quản lý bệnh viện. Dự án được phát triển dựa trên giao diện app cơ bản có sẵn trong thư mục `D:\DuAnThucTap\AppBenhVien`. Em đã kiểm tra cấu trúc project Flutter, cài đặt các công cụ cần thiết như Android Studio, Android SDK, Android Emulator và Flutter SDK để có thể chạy ứng dụng trên thiết bị giả lập Android.

Về cấu trúc kỹ thuật, ứng dụng sử dụng `Provider` và `ChangeNotifier` để quản lý trạng thái đăng nhập, token, vai trò người dùng và thông tin phân quyền thông qua file `lib/auth/auth_provider.dart`. Provider được khai báo tại `lib/main.dart` bằng `ChangeNotifierProvider`. Ứng dụng cũng đã cấu hình điều hướng bằng `go_router` trong file `lib/routes/app_router.dart`, trong đó có nhóm route dành cho bệnh nhân như `/patient`, `/patient/lich`, `/patient/hoso`, `/patient/xetnghiem`, `/patient/hoadon`.

Về kết nối API, ứng dụng sử dụng package `http` và có lớp dùng chung `ApiClient` trong file `lib/services/api_client.dart`. Lớp này hỗ trợ các phương thức REST như GET, POST, PUT, DELETE và upload multipart, đồng thời tự động gắn `Bearer token` vào header khi người dùng đã đăng nhập. Kết quả tuần 1 là ứng dụng Flutter có thể chạy được từ source giao diện có sẵn và sẵn sàng để phát triển các chức năng bệnh nhân ở các tuần tiếp theo.
