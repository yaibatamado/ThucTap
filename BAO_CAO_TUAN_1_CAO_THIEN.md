# Báo cáo tuần 1 - Cao Thiên

## Công việc được phân công

Khởi tạo dự án Mobile App Flutter, cấu hình cấu trúc State Management (Bloc/Provider/GetX) và cài đặt các package kết nối API (Dio/Http).

## Kết quả thực hiện

Trong tuần 1, em đã chuẩn bị môi trường phát triển Mobile App Flutter cho hệ thống quản lý bệnh viện. Dự án được phát triển dựa trên giao diện app cơ bản có sẵn tại thư mục `D:\DuAnThucTap\AppBenhVien`.

Em đã kiểm tra cấu trúc project Flutter gồm các thư mục chính như `lib`, `android`, `ios`, `web`, `windows` và file cấu hình `pubspec.yaml`. Project hiện đã khai báo các package cần thiết cho tuần 1 như `provider`, `go_router`, `http`, `shared_preferences`, `intl`, `jwt_decode`, `socket_io_client` và `image_picker`.

Về State Management, ứng dụng sử dụng `Provider` kết hợp `ChangeNotifier`. File quản lý trạng thái chính là `lib/auth/auth_provider.dart`, dùng để lưu token đăng nhập, role người dùng, mã tài khoản, mã bệnh nhân, mã bác sĩ, loại nhân sự và trạng thái loading. Provider được đăng ký trong `lib/main.dart` bằng `ChangeNotifierProvider`.

Về kết nối API, ứng dụng sử dụng package `http` thông qua lớp dùng chung `ApiClient` tại `lib/services/api_client.dart`. Lớp này hỗ trợ các phương thức REST như GET, POST, PUT, DELETE và upload multipart. Khi có token, `ApiClient` tự động gắn `Authorization: Bearer <token>` vào header. Base URL hiện được cấu hình là `http://10.0.2.2:4000/api` để app Android Emulator có thể gọi backend chạy trên máy tính thật.

Về điều hướng, ứng dụng sử dụng `go_router` trong file `lib/routes/app_router.dart`. Phần liên quan đến bệnh nhân đã có các route nền tảng như `/patient`, `/patient/lich`, `/patient/hoso`, `/patient/xetnghiem`, `/patient/hoadon`, `/patient/taikhoan` và `/patient/payment/qr/:maLich`.

## Kiểm tra chạy thử

Em đã chạy `flutter pub get` để tải và đồng bộ các package của dự án. Ứng dụng đã chạy được trên Android Emulator bằng Flutter SDK tại `E:\flutter_windows_3.44.1-stable\flutter`.

Các file nền tảng đúng phạm vi tuần 1 gồm `lib/main.dart`, `lib/auth/auth_provider.dart` và `lib/services/api_client.dart` đã được kiểm tra bằng `flutter analyze` và không còn lỗi/cảnh báo. Khi phân tích toàn bộ project, vẫn còn một số cảnh báo lint ở các màn hình chức năng có sẵn như admin, nhân sự, bệnh nhân; các cảnh báo này không phải lỗi biên dịch và sẽ được xử lý dần khi phát triển các chức năng tương ứng ở các tuần sau.

## Kết luận

Kết quả tuần 1 là project Mobile App Flutter đã có cấu trúc nền tảng, state management bằng Provider, kết nối API bằng HTTP và sẵn sàng chạy trên Android Emulator sau khi cài đầy đủ Flutter SDK, Android Studio và Android SDK. Đây là nền tảng để phát triển các chức năng bệnh nhân trong các tuần tiếp theo.
