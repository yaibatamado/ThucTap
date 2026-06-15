# App Bệnh Viện Flutter

Ứng dụng Flutter demo cho hệ thống quản lý bệnh viện. Project có thể chạy thử giao diện mà không cần backend.

## Chạy nhanh

```powershell
flutter pub get
flutter run
```

Mặc định app chạy ở `DEMO_MODE=true`, toàn bộ dữ liệu lấy từ `lib/services/demo_api.dart`.

Nếu muốn dùng backend thật:

```powershell
flutter run --dart-define=DEMO_MODE=false
```

Backend thật đang được cấu hình trong `lib/services/api_client.dart`:

```dart
http://10.0.2.2:4000/api
```

## Tài khoản demo

Tại màn đăng nhập, bấm trực tiếp các nút trong phần **Chạy thử không cần backend**:

- Bệnh nhân
- Bác sĩ
- Admin
- Y tá
- Tiếp nhận
- Xét nghiệm

Không cần nhập tài khoản hoặc mật khẩu.

## Luồng giao diện đã có

- Đăng nhập, đăng ký OTP, quên mật khẩu.
- Bệnh nhân: trang chủ, đặt lịch, chi tiết lịch, QR thanh toán, thanh toán thành công, hồ sơ bệnh án, kết quả xét nghiệm, chi tiết xét nghiệm, hóa đơn, chi tiết hóa đơn, tài khoản, chat AI.
- Bác sĩ: trang chủ, lịch làm việc, lịch hẹn, phiếu khám, kê đơn, yêu cầu xét nghiệm, thông tin cá nhân.
- Admin: quản lý tài khoản, phân quyền, khoa, bác sĩ, nhân sự, bệnh nhân, thuốc, xét nghiệm, hồ sơ, thống kê.
- Nhân sự: y tá, tiếp nhận, xét nghiệm.

## Kiểm tra project

```powershell
flutter test
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter build apk --debug
```

Lưu ý: project có thể còn warning/info lint ở các màn cũ, nhưng không chặn chạy app.
