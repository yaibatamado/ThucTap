import 'dart:convert';

import 'package:http/http.dart' as http;

class DemoApi {
  static http.Response get(String path) => _json(_dataFor(path));

  static http.Response post(String path, dynamic body) {
    if (path == '/auth/login') {
      final username = (body is Map ? body['tenDangNhap'] : null)
          ?.toString()
          .trim()
          .toLowerCase();
      return _json(loginPayload(username ?? 'benhnhan'));
    }

    if (path == '/lichkham') {
      return _json({
        'success': true,
        'message': 'Đã tạo lịch hẹn demo.',
        'data': {
          'maLich': 'LK-DEMO-${DateTime.now().millisecondsSinceEpoch}',
          if (body is Map) ...body,
          'trangThai': 'CHO_THANH_TOAN',
          'BacSi': {'hoTen': 'BS. Nguyễn Minh An'},
        },
      }, statusCode: 201);
    }

    if (path == '/hoadon/giohang/confirm') {
      return _json({
        'success': true,
        'message': 'Đã tạo hóa đơn demo.',
        'data': {
          'maHD': 'HD-DEMO',
          'maBN': body is Map ? body['maBN'] : 'BN001',
          'noiDung': 'Phí khám và dịch vụ y tế',
          'tongTien': 350000,
          'trangThai': 'CHUA_THANH_TOAN',
          'ngayLap': '2026-06-15T00:00:00.000Z',
        },
      }, statusCode: 201);
    }

    if (path == '/auth/request-otp' ||
        path == '/auth/register' ||
        path == '/auth/forgot-password' ||
        path == '/auth/reset-password' ||
        path == '/auth/doi-mat-khau') {
      return _json({'success': true, 'message': 'Thao tác demo thành công.'});
    }

    return _json({
      'success': true,
      'message': 'Dữ liệu demo đã được ghi nhận.',
      'data': body,
    }, statusCode: 201);
  }

  static http.Response put(String path, dynamic body) => _json({
    'success': true,
    'message': 'Dữ liệu demo đã được cập nhật.',
    'data': body,
  });

  static http.Response delete(String path, {dynamic body}) => _json({
    'success': true,
    'message': 'Dữ liệu demo đã được xoá.',
    'data': body,
  });

  static Map<String, dynamic> loginPayload(String username) {
    final normalized = username.trim().toLowerCase();
    final user = switch (normalized) {
      'admin' => _accountAdmin,
      'bacsi' || 'doctor' => _accountDoctor,
      'yta' => _accountYTa,
      'tiepnhan' => _accountTiepNhan,
      'xetnghiem' => _accountXetNghiem,
      _ => _accountPatient,
    };

    return {
      'token': 'demo-token-$normalized',
      'user': user,
      'message': 'Đăng nhập demo thành công.',
    };
  }

  static http.Response _json(Object body, {int statusCode = 200}) {
    return http.Response(
      jsonEncode(body),
      statusCode,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  }

  static Map<String, dynamic> _dataFor(String path) {
    if (path.startsWith('/benhnhan/findByMaTK/')) {
      return {'success': true, 'data': _patientDetail};
    }
    if (path.startsWith('/hsba/chitiet/')) {
      return {'success': true, 'data': _hsbaDetail};
    }
    if (path.startsWith('/hsba/benhnhan/')) {
      return {'success': true, 'data': _hsbaList};
    }
    if (path.startsWith('/lichkham/benhnhan/')) {
      return {'success': true, 'data': _lichKham};
    }
    if (path.startsWith('/phieukham/bacsi/')) {
      return {'success': true, 'data': _phieuKham};
    }
    if (path.startsWith('/lichlamviec/bacsi/')) {
      return {'success': true, 'data': _lichLamViec};
    }
    if (path.startsWith('/hoadon/thongke')) {
      return {
        'success': true,
        'data': {
          'tongTien': 1850000,
          'tongSo': 12,
          'daThanhToan': 9,
          'chuaThanhToan': 3,
        },
      };
    }
    if (path.startsWith('/hoadon/giohang/')) {
      return {'success': true, 'data': _gioHang};
    }
    if (path.startsWith('/hoadon/myhoadon/')) {
      return {'success': true, 'data': _hoaDon};
    }

    return switch (path) {
      '/tai-khoan' => {'success': true, 'data': _accounts},
      '/khoa' => {'success': true, 'data': _khoa},
      '/bacsi' => {'success': true, 'data': _doctors},
      '/benhnhan' => {'success': true, 'data': _patients},
      '/nhansu' => {'success': true, 'data': _staff},
      '/catruc' => {'success': true, 'data': _caTruc},
      '/lichlamviec' => {'success': true, 'data': _lichLamViec},
      '/lichkham' => {'success': true, 'data': _lichKham},
      '/hsba' => {'success': true, 'data': _hsbaList},
      '/thuoc/nhomthuoc' => {'success': true, 'data': _nhomThuoc},
      '/thuoc/donvitinh' => {'success': true, 'data': _donViTinh},
      '/thuoc' => {'success': true, 'data': _thuoc},
      '/loaixetnghiem' => {'success': true, 'data': _loaiXetNghiem},
      '/xetnghiem' => {'success': true, 'data': _xetNghiem},
      '/yeucauxetnghiem' => {'success': true, 'data': _yeuCauXetNghiem},
      '/phieuxetnghiem' => {'success': true, 'data': _phieuXetNghiem},
      '/tro-ly' => {
        'success': true,
        'data': {'items': _troLy},
      },
      '/chat/contacts' => {'success': true, 'data': _accounts},
      '/chatbot/history' => {'success': true, 'data': _chatHistory},
      _ => {'success': true, 'data': [], 'message': 'Dữ liệu demo trống.'},
    };
  }

  static final Map<String, dynamic> _accountAdmin = {
    'maTK': 'TK_ADMIN',
    'tenDangNhap': 'Quản trị hệ thống',
    'email': 'admin@benhvien.demo',
    'maNhom': 'ADMIN',
    'trangThai': true,
    'hoTen': 'Quản trị hệ thống',
  };

  static final Map<String, dynamic> _accountDoctor = {
    'maTK': 'TK_BS001',
    'tenDangNhap': 'BS. Nguyễn Minh An',
    'email': 'bacsi@benhvien.demo',
    'maNhom': 'BACSI',
    'trangThai': true,
    'maBS': 'BS001',
    'hoTen': 'BS. Nguyễn Minh An',
    'maKhoa': 'K001',
    'tenKhoa': 'Khoa Nội tổng hợp',
    'chuyenMon': 'Nội khoa',
    'chucVu': 'Bác sĩ điều trị',
    'trinhDo': 'Thạc sĩ',
  };

  static final Map<String, dynamic> _accountPatient = {
    'maTK': 'TK_BN001',
    'tenDangNhap': 'Trần Gia Hân',
    'email': 'benhnhan@benhvien.demo',
    'maNhom': 'BENHNHAN',
    'trangThai': true,
    'maBN': 'BN001',
    'hoTen': 'Trần Gia Hân',
    'gioiTinh': 'Nữ',
    'ngaySinh': '2002-05-12',
    'soDienThoai': '0901234567',
    'bhyt': 'HS4012345678901',
    'diaChi': 'Quận 1, TP. Hồ Chí Minh',
  };

  static final Map<String, dynamic> _accountYTa = {
    'maTK': 'TK_NS001',
    'tenDangNhap': 'Điều dưỡng Lê Mai',
    'email': 'yta@benhvien.demo',
    'maNhom': 'NHANSU',
    'trangThai': true,
    'maNS': 'NS001',
    'loaiNS': 'YT',
    'hoTen': 'Điều dưỡng Lê Mai',
    'capBac': 'Điều dưỡng trưởng',
  };

  static final Map<String, dynamic> _accountTiepNhan = {
    'maTK': 'TK_NS002',
    'tenDangNhap': 'NV tiếp nhận Phạm Vy',
    'email': 'tiepnhan@benhvien.demo',
    'maNhom': 'NHANSU',
    'trangThai': true,
    'maNS': 'NS002',
    'loaiNS': 'TN',
    'hoTen': 'Nhân viên tiếp nhận Phạm Vy',
    'capBac': 'Nhân viên',
  };

  static final Map<String, dynamic> _accountXetNghiem = {
    'maTK': 'TK_NS003',
    'tenDangNhap': 'KTV xét nghiệm Võ Khang',
    'email': 'xetnghiem@benhvien.demo',
    'maNhom': 'NHANSU',
    'trangThai': true,
    'maNS': 'NS003',
    'loaiNS': 'XN',
    'hoTen': 'KTV xét nghiệm Võ Khang',
    'capBac': 'Kỹ thuật viên',
  };

  static final List<Map<String, dynamic>> _accounts = [
    _accountAdmin,
    _accountDoctor,
    _accountPatient,
    _accountYTa,
    _accountTiepNhan,
    _accountXetNghiem,
  ];

  static final List<Map<String, dynamic>> _khoa = [
    {
      'maKhoa': 'K001',
      'tenKhoa': 'Khoa Nội tổng hợp',
      'moTa': 'Khám và điều trị bệnh nội khoa.',
    },
    {
      'maKhoa': 'K002',
      'tenKhoa': 'Khoa Nhi',
      'moTa': 'Chăm sóc sức khỏe trẻ em.',
    },
    {
      'maKhoa': 'K003',
      'tenKhoa': 'Khoa Xét nghiệm',
      'moTa': 'Thực hiện xét nghiệm lâm sàng.',
    },
  ];

  static final List<Map<String, dynamic>> _doctors = [
    _accountDoctor,
    {
      'maTK': 'TK_BS002',
      'tenDangNhap': 'bacsi2',
      'email': 'bacsi2@benhvien.demo',
      'maNhom': 'BACSI',
      'trangThai': true,
      'maBS': 'BS002',
      'hoTen': 'BS. Phạm Thuỳ Linh',
      'maKhoa': 'K002',
      'tenKhoa': 'Khoa Nhi',
      'chuyenMon': 'Nhi khoa',
      'chucVu': 'Bác sĩ chuyên khoa',
      'trinhDo': 'Chuyên khoa I',
    },
  ];

  static final List<Map<String, dynamic>> _patients = [_accountPatient];
  static final List<Map<String, dynamic>> _staff = [
    _accountYTa,
    _accountTiepNhan,
    _accountXetNghiem,
  ];

  static final Map<String, dynamic> _patientDetail = {
    ..._accountPatient,
    'TaiKhoan': {
      'tenDangNhap': 'Trần Gia Hân',
      'email': 'benhnhan@benhvien.demo',
    },
  };

  static final List<Map<String, dynamic>> _caTruc = [
    {
      'maCa': 'CA01',
      'tenCa': 'Ca sáng',
      'thoiGianBatDau': '07:00:00',
      'thoiGianKetThuc': '11:30:00',
    },
    {
      'maCa': 'CA02',
      'tenCa': 'Ca chiều',
      'thoiGianBatDau': '13:00:00',
      'thoiGianKetThuc': '17:00:00',
    },
  ];

  static final List<Map<String, dynamic>> _lichLamViec = [
    {
      'maLLV': 'LLV001',
      'maBS': 'BS001',
      'maCa': 'CA01',
      'maNS': 'NS001',
      'ngayLamViec': '2026-06-15T00:00:00.000Z',
      'BacSi': {'hoTen': 'BS. Nguyễn Minh An'},
      'NhanSuYTe': {'hoTen': 'Điều dưỡng Lê Mai'},
      'CaTruc': {
        'tenCa': 'Ca sáng',
        'thoiGianBatDau': '07:00:00',
        'thoiGianKetThuc': '11:30:00',
      },
    },
  ];

  static final List<Map<String, dynamic>> _lichKham = [
    {
      'maLich': 'LK001',
      'maBN': 'BN001',
      'maBS': 'BS001',
      'ngayKham': '2026-06-16T08:30:00.000Z',
      'gioKham': '08:30',
      'trangThai': 'DA_THANH_TOAN',
      'lyDoKham': 'Khám tổng quát',
      'ghiChu': 'Khám tổng quát',
      'phong': 'P.201',
      'BenhNhan': {'hoTen': 'Trần Gia Hân'},
      'BacSi': {'hoTen': 'BS. Nguyễn Minh An'},
    },
    {
      'maLich': 'LK002',
      'maBN': 'BN001',
      'maBS': 'BS002',
      'ngayKham': '2026-06-18T14:30:00.000Z',
      'gioKham': '14:30',
      'trangThai': 'CHO_THANH_TOAN',
      'lyDoKham': 'Tái khám sau xét nghiệm',
      'ghiChu': 'Tái khám sau xét nghiệm',
      'phong': 'P.305',
      'BenhNhan': {'hoTen': 'Trần Gia Hân'},
      'BacSi': {'hoTen': 'BS. Phạm Thuỳ Linh'},
    },
  ];

  static final List<Map<String, dynamic>> _hsbaList = [
    {
      'maHSBA': 'HSBA001',
      'maBN': 'BN001',
      'ngayLap': '2026-06-01T00:00:00.000Z',
      'dotKhamBenh': '2026-06-16T00:00:00.000Z',
      'lichSuBenh': 'Viêm họng nhẹ, đã điều trị ổn định.',
      'ghiChu': 'Theo dõi sức khỏe định kỳ.',
      'BenhNhan': {'hoTen': 'Trần Gia Hân'},
    },
  ];

  static final Map<String, dynamic> _hsbaDetail = {
    'maHSBA': 'HSBA001',
    'maBN': 'BN001',
    'ngayLap': '2026-06-01T00:00:00.000Z',
    'lichSuBenh': 'Viêm họng nhẹ, đã điều trị ổn định.',
    'ghiChu': 'Dữ liệu mẫu chế độ demo.',
    'BenhNhan': {'hoTen': 'Trần Gia Hân'},
    'blocks': [],
  };

  static final List<Map<String, dynamic>> _phieuKham = [
    {
      'maPK': 'PK001',
      'maHSBA': 'HSBA001',
      'maBS': 'BS001',
      'ngayKham': '2026-06-16T08:30:00.000Z',
      'chanDoan': 'Sức khỏe ổn định',
      'trieuChung': 'Mệt nhẹ',
      'ketLuan': 'Nghỉ ngơi và uống đủ nước',
      'HoSoBenhAn': {
        'maBN': 'BN001',
        'BenhNhan': {'hoTen': 'Trần Gia Hân'},
      },
    },
  ];

  static final List<Map<String, dynamic>> _nhomThuoc = [
    {
      'maNhom': 'NT001',
      'tenNhom': 'Giảm đau',
      'moTa': 'Thuốc giảm đau thông dụng',
    },
  ];

  static final List<Map<String, dynamic>> _donViTinh = [
    {'maDVT': 'DVT001', 'tenDVT': 'Viên', 'moTa': 'Đơn vị viên uống'},
  ];

  static final List<Map<String, dynamic>> _thuoc = [
    {
      'maThuoc': 'T001',
      'tenThuoc': 'Paracetamol 500mg',
      'maNhom': 'NT001',
      'maDVT': 'DVT001',
      'tonKhoHienTai': 120,
      'NhomThuoc': {'tenNhom': 'Giảm đau'},
      'DonViTinh': {'tenDVT': 'Viên'},
    },
  ];

  static final List<Map<String, dynamic>> _loaiXetNghiem = [
    {
      'maLoaiXN': 'LXN001',
      'tenLoai': 'Huyết học',
      'moTa': 'Xét nghiệm máu cơ bản',
    },
  ];

  static final List<Map<String, dynamic>> _xetNghiem = [
    {
      'maXN': 'XN001',
      'tenXN': 'Công thức máu',
      'maLoaiXN': 'LXN001',
      'chiPhi': 120000,
      'thoiGianTraKetQua': 'Trong ngày',
      'LoaiXetNghiem': {'tenLoai': 'Huyết học'},
    },
  ];

  static final List<Map<String, dynamic>> _yeuCauXetNghiem = [
    {
      'maYC': 'YCXN001',
      'maBN': 'BN001',
      'maBS': 'BS001',
      'maXN': 'XN001',
      'trangThai': 'Chờ thực hiện',
      'ngayYeuCau': '2026-06-15T09:00:00.000Z',
      'BenhNhan': {'hoTen': 'Trần Gia Hân'},
      'BacSi': {'hoTen': 'BS. Nguyễn Minh An'},
      'XetNghiem': {'tenXN': 'Công thức máu'},
    },
  ];

  static final List<Map<String, dynamic>> _phieuXetNghiem = [
    {
      'maPhieuXN': 'PXN001',
      'maYC': 'YCXN001',
      'maXN': 'XN001',
      'maNS': 'NS003',
      'ngayThucHien': '2026-06-15T10:00:00.000Z',
      'ketQua': 'Các chỉ số trong giới hạn bình thường.',
      'YeuCau': {'maBN': 'BN001'},
      'XetNghiem': {
        'tenXN': 'Công thức máu',
        'LoaiXetNghiem': {'tenLoai': 'Huyết học'},
      },
      'NhanSuYTe': {'hoTen': 'KTV xét nghiệm Võ Khang'},
    },
  ];

  static final List<Map<String, dynamic>> _troLy = [
    {
      'maTroLy': 'TL001',
      'maNS': 'NS001',
      'maBacSi': 'BS001',
      'phamViUyQuyen': 'Hỗ trợ tiếp nhận và chuẩn bị hồ sơ',
    },
  ];

  static final List<Map<String, dynamic>> _gioHang = [
    {
      'maCTGH': 'GH001',
      'maDichVu': 'LK002',
      'loaiDichVu': 'Đặt lịch',
      'noiDung': 'Phí đặt chỗ khám',
      'thanhTien': 100000,
    },
    {
      'maCTGH': 'GH002',
      'maDichVu': 'XN001',
      'loaiDichVu': 'Xét nghiệm',
      'noiDung': 'Công thức máu',
      'thanhTien': 120000,
    },
  ];

  static final List<Map<String, dynamic>> _hoaDon = [
    {
      'maHD': 'HD001',
      'maBN': 'BN001',
      'noiDung': 'Khám tổng quát',
      'tongTien': 250000,
      'trangThai': 'DA_THANH_TOAN',
      'ngayLap': '2026-06-15T00:00:00.000Z',
    },
    {
      'maHD': 'HD002',
      'maBN': 'BN001',
      'noiDung': 'Xét nghiệm công thức máu',
      'tongTien': 120000,
      'trangThai': 'CHUA_THANH_TOAN',
      'ngayLap': '2026-06-15T00:00:00.000Z',
    },
  ];

  static final List<Map<String, dynamic>> _chatHistory = [
    {'sender': 'bot', 'text': 'Xin chào, tôi có thể hỗ trợ gì cho bạn?'},
  ];
}
