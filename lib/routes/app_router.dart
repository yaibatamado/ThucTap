import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Import các provider và layout
import '../auth/auth_provider.dart';
import '../screens/admin/quan_ly_bac_si_screen.dart';
import '../screens/admin/quan_ly_benh_nhan_screen.dart';
import '../screens/admin/quan_ly_don_vi_tinh_screen.dart';
import '../screens/admin/quan_ly_ho_so_benh_an_screen.dart';
import '../screens/admin/quan_ly_khoa_screen.dart';
import '../screens/admin/quan_ly_lich_kham_screen.dart';
import '../screens/admin/quan_ly_loai_xet_nghiem_screen.dart';
import '../screens/admin/quan_ly_nhan_su_screen.dart';
import '../screens/admin/quan_ly_nhom_thuoc_screen.dart';
import '../screens/admin/quan_ly_thuoc_screen.dart';
import '../screens/admin/quan_ly_tro_ly_screen.dart';
import '../screens/admin/quan_ly_xet_nghiem_screen.dart';
import '../screens/admin/thong_ke_hoa_don_screen.dart';
import '../screens/admin/thong_ke_lich_kham_screen.dart';
import '../screens/admin/thong_ke_lich_lam_viec_screen.dart';
import '../screens/chat/chat_list_screen.dart';
import '../screens/chat/chatbot_screen.dart';
import '../screens/doctor/doctor_screens.dart';
import '../screens/doctor/ke_don_thuoc_screen.dart';
import '../screens/doctor/lich_hen_kham_bs_screen.dart';
import '../screens/doctor/lich_lam_viec_bs_screen.dart';
import '../screens/doctor/thong_tin_ca_nhan_bs_screen.dart';
import '../screens/doctor/yeu_cau_xn_bs_screen.dart';
import '../screens/error/not_found_screen.dart';
import '../screens/layouts/app_shell.dart';
import '../screens/doctor/phieu_kham_bs_screen.dart';

// Import các màn hình Auth
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart'; // THÊM IMPORT QUÊN MẬT KHẨU

// Import các màn hình Admin
import '../screens/admin/admin_home_screen.dart';
import '../screens/admin/assign_role_screen.dart';
import '../screens/admin/quan_ly_ca_truc_screen.dart';
import '../screens/admin/user_management_screen.dart';
import '../screens/admin/create_user_screen.dart';

// Import các màn hình Home (đã tách)
import '../screens/nhansu/phieu_xet_nghiem_ns_screen.dart';
import '../screens/nhansu/tiepnhan_screens.dart';
import '../screens/nhansu/xetnghiem_home_screen.dart';
import '../screens/nhansu/yeu_cau_xn_ns_screen.dart';
import '../screens/nhansu/yta_dang_ky_benh_nhan_screen.dart';
import '../screens/nhansu/yta_ghi_nhan_tinh_trang_screen.dart';
import '../screens/nhansu/yta_lich_bac_si_screen.dart';
import '../screens/nhansu/yta_screens.dart';
import '../screens/patient/gio_hang_hoa_don_screen.dart';
import '../screens/patient/hoa_don_detail_screen.dart';
import '../screens/patient/ho_so_benh_an_detail_screen.dart';
import '../screens/patient/ho_so_benh_an_screen.dart';
import '../screens/patient/ket_qua_xet_nghiem_detail_screen.dart';
import '../screens/patient/ket_qua_xet_nghiem_screen.dart';
import '../screens/patient/lich_hen_detail_screen.dart';
import '../screens/patient/lich_hen_bn_screen.dart';
import '../screens/patient/patient_screens.dart';
import '../screens/patient/payment_qr_screen.dart';
import '../screens/patient/payment_success_screen.dart';
import '../screens/patient/thong_tin_ca_nhan_screen.dart';
// --- CONFIGURATIONS ---

// Định nghĩa menu cho từng vai trò
final Map<String, List<Map<String, dynamic>>> roleMenus = {
  'ADMIN': [
    {
      'title': 'Tài khoản & phân quyền',
      'items': [
        {'label': 'Danh sách tài khoản', 'route': '/admin/account/list'},
        {'label': 'Tạo tài khoản', 'route': '/admin/account/create'},
        {'label': 'Phân quyền', 'route': '/admin/account/roles'},
      ],
    },
    {
      'title': 'Chuyên môn',
      'items': [
        {'label': 'Quản lý ca trực', 'route': '/admin/specialty/dept'},
        {'label': 'Quản lý bác sĩ', 'route': '/admin/specialty/b'},
        {'label': 'Quản lý khoa', 'route': '/admin/specialty/c'},
        {'label': 'Quản lý nhân sự', 'route': '/admin/specialty/d'},
      ],
    },
  ],
  'BACSI': [
    {
      'title': 'Khám & Điều trị',
      'items': [
        {'label': 'Phiếu khám', 'route': '/doctor/kham'},
        {'label': 'Kê đơn thuốc', 'route': '/doctor/kham/donthuoc'},
        {'label': 'Yêu cầu xét nghiệm', 'route': '/doctor/xetnghiem'},
      ],
    },
    {
      'title': 'Lịch làm việc',
      'items': [
        {'label': 'Lịch cá nhân', 'route': '/doctor/lich'},
        {'label': 'Lịch hẹn bệnh nhân', 'route': '/doctor/lichhen'},
      ],
    },
  ],
  'BENHNHAN': [
    {
      'title': 'Lịch khám',
      'items': [
        {'label': 'Đặt lịch khám', 'route': '/patient/lich'},
      ],
    },
    {
      'title': 'Hồ sơ',
      'items': [
        {'label': 'Hồ sơ bệnh án', 'route': '/patient/hoso'},
        {'label': 'Kết quả xét nghiệm', 'route': '/patient/xetnghiem'},
        {'label': 'Hóa đơn', 'route': '/patient/hoadon'},
      ],
    },
  ],
  'YT': [
    // Nhân sự: Y tá
    {
      'title': 'Bệnh nhân',
      'items': [
        {'label': 'Đăng ký bệnh nhân', 'route': '/yta/benhnhan/dangky'},
        {
          'label': 'Ghi nhận tình trạng',
          'route': '/yta/benhnhan/ghinhantinhtrang',
        },
        {'label': 'Lịch bác sĩ', 'route': '/yta/lichlamviec'},
      ],
    },
  ],
  'TN': [
    // Nhân sự: Tiếp nhận
    {
      'title': 'Tiếp nhận',
      'items': [
        {'label': 'Trang tiếp nhận', 'route': '/tiepnhan'},
      ],
    },
  ],
  'XN': [
    // Nhân sự: Xét nghiệm
    {
      'title': 'Xét nghiệm',
      'items': [
        {'label': 'Yêu cầu xét nghiệm', 'route': '/xetnghiem/xetnghiem/yeucau'},
        {'label': 'Phiếu xét nghiệm', 'route': '/xetnghiem/xetnghiem/phieu'},
      ],
    },
  ],
};

// Hàm lấy Menu cho Shell
List<Map<String, dynamic>> getMenuForRole(String role, String? loaiNS) {
  if (role == 'NHANSU') {
    if (loaiNS != null && roleMenus.containsKey(loaiNS)) {
      return roleMenus[loaiNS]!;
    }
    // Nếu là nhân sự nhưng không có loaiNS cụ thể (hoặc loaiNS không khớp), trả về trống
    return [];
  }
  return roleMenus[role] ?? [];
}

// --- GO ROUTER CONFIGURATION ---

final GoRouter appRouter = GoRouter(
  // Thêm NotFoundPage cho mọi trường hợp
  errorBuilder: (context, state) => NotFoundScreen(),

  routes: [
    GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
    GoRoute(path: '/register', builder: (context, state) => RegisterScreen()),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => ForgotPasswordScreen(),
    ),
    // --- SHELL ROUTES CHO TỪNG VAI TRÒ ---
    GoRoute(path: '/chatbot', builder: (context, state) => ChatbotScreen()),
    GoRoute(path: '/chat/list', builder: (context, state) => ChatListScreen()),
    // 1. ADMIN Shell
    ShellRoute(
      builder: (context, state, child) => AppShell(
        title: "Admin Dashboard",
        menuItems: getMenuForRole('ADMIN', null),
        child: child,
      ),
      routes: [
        GoRoute(path: '/admin', builder: (context, state) => AdminHome()),
        GoRoute(
          path: '/admin/account/list',
          builder: (context, state) => UserManagementScreen(),
        ),
        GoRoute(
          path: '/admin/account/create',
          builder: (context, state) =>
              CreateUserScreen(userToEdit: state.extra as dynamic),
        ),
        GoRoute(
          path: '/admin/account/roles',
          builder: (context, state) => AssignRoleScreen(),
        ),
        GoRoute(
          path: '/admin/specialty/dept',
          builder: (context, state) => QuanLyCaTrucPageScreen(),
        ),
        GoRoute(
          path: '/admin/specialty/b',
          builder: (context, state) => QuanLyBacSiScreen(),
        ),
        GoRoute(
          path: '/admin/specialty/c',
          builder: (context, state) => QuanLyKhoaScreen(),
        ),
        GoRoute(
          path: '/admin/specialty/d',
          builder: (context, state) => QuanLyNhanSuScreen(),
        ),
        GoRoute(
          path: '/admin/specialty/e',
          builder: (context, state) => QuanLyTroLyScreen(),
        ),
        GoRoute(
          path: '/admin/specialty/f',
          builder: (context, state) => QuanLyLichKhamScreen(),
        ),
        GoRoute(
          path: '/admin/specialty/g',
          builder: (context, state) => QuanLyLoaiXNScreen(),
        ),
        GoRoute(
          path: '/admin/specialty/h',
          builder: (context, state) => QuanLyXetNghiemScreen(),
        ),
        GoRoute(
          path: '/admin/specialty/j',
          builder: (context, state) => QuanLyBenhNhanScreen(),
        ),
        GoRoute(
          path: '/admin/specialty/m',
          builder: (context, state) => QuanLyHoSoBenhAnScreen(),
        ),
        GoRoute(
          path: '/admin/specialty/n',
          builder: (context, state) => QuanLyNhomThuocScreen(),
        ),
        GoRoute(
          path: '/admin/specialty/o',
          builder: (context, state) => QuanLyThuocScreen(),
        ),
        GoRoute(
          path: '/admin/specialty/p',
          builder: (context, state) => QuanLyDonViTinhScreen(),
        ),
        GoRoute(
          path: '/admin/specialty/k',
          builder: (context, state) => ThongKeHoaDonScreen(),
        ),
        GoRoute(
          path: '/admin/specialty/l',
          builder: (context, state) => ThongKeLichKhamScreen(),
        ),
        GoRoute(
          path: '/admin/specialty/v',
          builder: (context, state) => ThongKeLichLamViecScreen(),
        ),
      ],
    ),

    // 2. DOCTOR Shell
    ShellRoute(
      builder: (context, state, child) => AppShell(
        title: "Trang Bác sĩ",
        menuItems: getMenuForRole('BACSI', null),
        child: child,
      ),
      routes: [
        GoRoute(path: '/doctor', builder: (context, state) => DoctorHome()),
        GoRoute(
          path: '/doctor/lich',
          builder: (context, state) => LichLamViecBSScreen(),
        ),
        GoRoute(
          path: '/doctor/lichhen',
          builder: (context, state) => LichHenKhamBSScreen(),
        ),
        GoRoute(
          path: '/doctor/kham',
          builder: (context, state) => PhieuKhamBSScreenn(),
        ),
        GoRoute(
          path: '/doctor/kham/donthuoc',
          builder: (context, state) => KeDonThuocScreen(),
        ),
        GoRoute(
          path: '/doctor/xetnghiem',
          builder: (context, state) => YeuCauXNBSScreen(),
        ),
        GoRoute(
          path: '/doctor/taikhoan',
          builder: (context, state) => ThongTinCaNhanBSScreen(),
        ),
      ],
    ),

    // 3. PATIENT Shell
    ShellRoute(
      builder: (context, state, child) => AppShell(
        title: "Trang Bệnh nhân",
        menuItems: getMenuForRole('BENHNHAN', null),
        child: child,
        backgroundColor: Colors.green[900], // Màu nền sidebar khác
      ),
      routes: [
        GoRoute(path: '/patient', builder: (context, state) => PatientHome()),
        GoRoute(
          path: '/patient/lich',
          builder: (context, state) => LichHenBNScreen(),
        ),
        GoRoute(
          path: '/patient/lich/:maLich',
          builder: (context, state) =>
              LichHenDetailScreen(maLich: state.pathParameters['maLich']!),
        ),
        GoRoute(
          path: '/patient/xetnghiem',
          builder: (context, state) => KetQuaXetNghiemScreen(),
        ),
        GoRoute(
          path: '/patient/xetnghiem/:maPhieuXN',
          builder: (context, state) => KetQuaXetNghiemDetailScreen(
            maPhieuXN: state.pathParameters['maPhieuXN']!,
          ),
        ),
        GoRoute(
          path: '/patient/hoadon',
          builder: (context, state) => GioHangHoaDonScreen(),
        ),
        GoRoute(
          path: '/patient/hoadon/:maHD',
          builder: (context, state) =>
              HoaDonDetailScreen(maHD: state.pathParameters['maHD']!),
        ),
        GoRoute(
          path: '/patient/taikhoan',
          builder: (context, state) => ThongTinCaNhanScreen(),
        ),
        GoRoute(
          path: '/patient/lich-hen-cua-toi',
          builder: (context, state) => LichHenBNScreen(),
        ),
        GoRoute(
          path: '/patient/hoso',
          builder: (context, state) => HoSoBenhAnScreen(),
          routes: [
            // Thêm route con (nested route) cho chi tiết
            GoRoute(
              path: ':maHSBA', // Nhận tham số là mã hồ sơ
              builder: (context, state) {
                final maHSBA = state.pathParameters['maHSBA']!;
                return HoSoBenhAnDetailScreen(maHSBA: maHSBA);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/patient/payment/qr/:maLich',
          builder: (context, state) {
            final maLich = state.pathParameters['maLich']!;
            return PaymentQRScreen(maLich: maLich);
          },
        ),
        GoRoute(
          path: '/patient/payment/success/:referenceId',
          builder: (context, state) => PaymentSuccessScreen(
            referenceId: state.pathParameters['referenceId']!,
          ),
        ),
      ],
    ),

    // 4. NHANSU (YTA/TIEPNHAN/XETNGHIEM) Shells
    // Đây là phần GoRouter sẽ xử lý redirect nội bộ dựa trên loaiNS
    // Chúng ta định nghĩa các shell riêng cho mỗi loaiNS
    ShellRoute(
      builder: (context, state, child) => AppShell(
        title: "Trang Y tá",
        menuItems: getMenuForRole('NHANSU', 'YT'),
        child: child,
        backgroundColor: Colors.amber[700],
      ),
      routes: [
        GoRoute(path: '/yta', builder: (context, state) => YtaHome()),
        GoRoute(
          path: '/yta/benhnhan/dangky',
          builder: (context, state) => DangKyBenhNhanYtaScreen(),
        ),
        GoRoute(
          path: '/yta/benhnhan/ghinhantinhtrang',
          builder: (context, state) => GhiNhanTinhTrangScreen(),
        ),
        GoRoute(
          path: '/yta/lichlamviec',
          builder: (context, state) => LichBacSiYtaScreen(),
        ),
      ],
    ),
    ShellRoute(
      builder: (context, state, child) => AppShell(
        title: "Trang Tiếp nhận",
        menuItems: getMenuForRole('NHANSU', 'TN'),
        child: child,
        backgroundColor: Colors.yellow[700],
      ),
      routes: [
        GoRoute(path: '/tiepnhan', builder: (context, state) => TiepNhanHome()),
      ],
    ),
    ShellRoute(
      builder: (context, state, child) => AppShell(
        title: "Trang Xét nghiệm",
        menuItems: getMenuForRole('NHANSU', 'XN'),
        child: child,
        backgroundColor: Colors.indigo[700],
      ),
      routes: [
        GoRoute(
          path: '/xetnghiem',
          builder: (context, state) => XetNghiemHome(),
        ),
        GoRoute(
          path: '/xetnghiem/xetnghiem/yeucau',
          builder: (context, state) => YeuCauXNTruocScreen(),
        ), // Màn hình 1
        GoRoute(
          path: '/xetnghiem/xetnghiem/phieu',
          builder: (context, state) => PhieuXetNghiemNSScreen(),
        ), // Màn hình 2
      ],
    ),

    // Redirect route (tương đương với '/' trong AppRoutes.jsx)
    GoRoute(path: '/', redirect: (_, __) => '/login'),
  ],

  // Logic Redirects (Tương đương với PrivateRoute.jsx)
  redirect: (context, state) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final isAuthenticated = auth.isAuthenticated;
    final isLoggingIn =
        state.matchedLocation == '/login' ||
        state.matchedLocation == '/register' ||
        state.matchedLocation ==
            '/forgot-password'; // SỬA: Bổ sung forgot-password

    // 1. Đang tải dữ liệu Auth
    if (auth.isLoading) return null;

    // 2. Không đăng nhập (Chặn PrivateRoute)
    if (!isAuthenticated) {
      return isLoggingIn
          ? null
          : '/login'; // Chuyển hướng đến Login nếu không phải Login/Register/Forgot
    }

    // 3. Đã đăng nhập (Chặn Login/Register/Forgot)
    if (isLoggingIn) {
      // Chuyển hướng đến trang chủ theo vai trò khi đăng nhập thành công
      switch (auth.role) {
        case 'ADMIN':
          return '/admin';
        case 'BACSI':
          return '/doctor';
        case 'BENHNHAN':
          return '/patient';
        case 'NHANSU':
          if (auth.loaiNS == 'YT') return '/yta';
          if (auth.loaiNS == 'XN') return '/xetnghiem';
          if (auth.loaiNS == 'TN') return '/tiepnhan';
          return '/404'; // Hoặc trang chung của nhân sự nếu không có loaiNS
        default:
          return '/404';
      }
    }

    // 4. Kiểm tra phân quyền (Chặn truy cập sai role)
    // Lấy prefix mong muốn từ URL hiện tại
    final targetPrefix = state.matchedLocation.split('/')[1];

    if (targetPrefix == 'admin' && auth.role != 'ADMIN') return '/404';
    if (targetPrefix == 'doctor' && auth.role != 'BACSI') return '/404';
    if (targetPrefix == 'patient' && auth.role != 'BENHNHAN') return '/404';

    if (targetPrefix == 'yta' && (auth.role != 'NHANSU' || auth.loaiNS != 'YT'))
      return '/404';
    if (targetPrefix == 'xetnghiem' &&
        (auth.role != 'NHANSU' || auth.loaiNS != 'XN'))
      return '/404';
    if (targetPrefix == 'tiepnhan' &&
        (auth.role != 'NHANSU' || auth.loaiNS != 'TN'))
      return '/404';

    return null; // Cho phép đi tiếp
  },
);
