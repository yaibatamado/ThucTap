// lib/screens/patient/ho_so_benh_an_screen.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hospital_app_frontend/screens/patient/patient_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_client.dart';
import '../../auth/auth_provider.dart';

// Model
class HoSoBenhAn {
  final String maHSBA;
  final String? lichSuBenh;
  final String? ghiChu;
  final String ngayLap;

  HoSoBenhAn({
    required this.maHSBA,
    this.lichSuBenh,
    this.ghiChu,
    required this.ngayLap,
  });

  factory HoSoBenhAn.fromJson(Map<String, dynamic> json) {
    String fNgayLap = json['ngayLap'] ?? '';
    try {
      fNgayLap = DateFormat(
        'dd/MM/yyyy',
      ).format(DateTime.parse(json['ngayLap']));
    } catch (_) {}

    return HoSoBenhAn(
      maHSBA: json['maHSBA'],
      lichSuBenh: json['lichSuBenh'],
      ghiChu: json['ghiChu'],
      ngayLap: fNgayLap,
    );
  }
}

class HoSoBenhAnScreen extends StatefulWidget {
  @override
  _HoSoBenhAnScreenState createState() => _HoSoBenhAnScreenState();
}

class _HoSoBenhAnScreenState extends State<HoSoBenhAnScreen> {
  final ApiClient _api = ApiClient();
  List<HoSoBenhAn> _list = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final maBN = Provider.of<AuthProvider>(context, listen: false).maBN;
    if (maBN == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      // API: GET /api/hsba/benhnhan/:maBN
      final response = await _api.get('/hsba/benhnhan/$maBN');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'] as List;
        setState(() {
          _list = data.map((json) => HoSoBenhAn.fromJson(json)).toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi tải dữ liệu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // SỬA: Thêm Scaffold và AppBar
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Hồ sơ bệnh án'),
        backgroundColor: Color(0xFF15803D), // Màu Bệnh nhân
        actions: [
          IconButton(
            icon: FaIcon(FontAwesomeIcons.house, color: Colors.white, size: 20),
            tooltip: 'Trang chủ',
            onPressed: () => context.go('/patient'),
          ),
          IconButton(
            icon: FaIcon(
              FontAwesomeIcons.rightFromBracket,
              color: Colors.white,
              size: 20,
            ),
            tooltip: 'Đăng xuất',
            onPressed: () async {
              await Provider.of<AuthProvider>(context, listen: false).logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _list.isEmpty
          ? Center(child: Text('Bạn chưa có hồ sơ bệnh án nào.'))
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _list.length,
              itemBuilder: (context, index) {
                final item = _list[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 10),
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green[100],
                      child: FaIcon(
                        FontAwesomeIcons.fileMedical,
                        color: Colors.green[700],
                        size: 20,
                      ),
                    ),
                    title: Text(
                      'Mã HSBA: ${item.maHSBA}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Lịch sử: ${item.lichSuBenh ?? "Không có"}\nGhi chú: ${item.ghiChu ?? "Không có"}',
                    ),
                    trailing: Text(item.ngayLap),
                    // === THÊM SỰ KIỆN ONTAP TẠI ĐÂY ===
                    onTap: () {
                      // Điều hướng đến trang chi tiết, truyền maHSBA
                      context.go('/patient/hoso/${item.maHSBA}');
                    },
                    // === KẾT THÚC THÊM ===
                  ),
                );
              },
            ),
      bottomNavigationBar: PatientBottomNavBar(currentIndex: 2),
    );
  }
}
