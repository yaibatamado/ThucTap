// lib/screens/admin/quan_ly_ca_truc_screen.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_provider.dart';
import '../../services/api_client.dart';

// (Giữ nguyên các hàm helper API: getAllShifts, createShift, updateShift, deleteShift)
final ApiClient _api = ApiClient();
Future<List<Map<String, dynamic>>> getAllShifts() async {
  try {
    final response = await _api.get('/catruc');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['data'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  } catch (e) {
    print('❌ Lỗi tải ca trực: $e');
    return [];
  }
}

Future<bool> createShift(Map<String, dynamic> data) async {
  try {
    final response = await _api.post('/catruc', data);
    return response.statusCode == 201;
  } catch (e) {
    print('❌ Lỗi tạo ca trực: $e');
    return false;
  }
}

Future<bool> updateShift(String maCa, Map<String, dynamic> data) async {
  try {
    final response = await _api.put('/catruc/$maCa', data);
    return response.statusCode == 200;
  } catch (e) {
    print('❌ Lỗi cập nhật ca trực: $e');
    return false;
  }
}

Future<bool> deleteShift(String maCa) async {
  try {
    final response = await _api.delete('/catruc/$maCa');
    return response.statusCode == 200;
  } catch (e) {
    print('❌ Lỗi xóa ca trực: $e');
    return false;
  }
}

class QuanLyCaTrucPageScreen extends StatefulWidget {
  @override
  _QuanLyCaTrucPageScreenState createState() => _QuanLyCaTrucPageScreenState();
}

class _QuanLyCaTrucPageScreenState extends State<QuanLyCaTrucPageScreen> {
  final _formKey = GlobalKey<FormState>();

  final _tenCaController = TextEditingController();
  final _batDauController = TextEditingController(text: '08:00');
  final _ketThucController = TextEditingController(text: '17:00');

  List<Map<String, dynamic>> _shifts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchShifts();
  }

  @override
  void dispose() {
    _tenCaController.dispose();
    _batDauController.dispose();
    _ketThucController.dispose();
    super.dispose();
  }

  Future<void> _fetchShifts() async {
    setState(() => _isLoading = true);
    final list = await getAllShifts();
    setState(() {
      _shifts = list;
      _isLoading = false;
    });
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _handleCreateShift() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await createShift({
      'tenCa': _tenCaController.text,
      'thoiGianBatDau': '${_batDauController.text}:00',
      'thoiGianKetThuc': '${_ketThucController.text}:00',
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Tạo ca trực thành công'),
          backgroundColor: Colors.green,
        ),
      );
      _tenCaController.clear();
      _batDauController.text = '08:00';
      _ketThucController.text = '17:00';
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Tạo ca trực thất bại'),
          backgroundColor: Colors.red,
        ),
      );
    }
    await _fetchShifts();
  }

  // (Hàm _handleUpdateShift và _handleDeleteShift giữ nguyên)
  void _handleUpdateShift(Map<String, dynamic> shift) {
    showDialog(
      context: context,
      builder: (context) {
        String tenCa = shift['tenCa'];
        String batDau = shift['thoiGianBatDau'].toString().substring(0, 5);
        String ketThuc = shift['thoiGianKetThuc'].toString().substring(0, 5);

        return AlertDialog(
          title: Text('Sửa ca trực: ${shift['maCa']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: tenCa,
                onChanged: (v) => tenCa = v,
                decoration: InputDecoration(labelText: 'Tên ca'),
              ),
              SizedBox(height: 10),
              TextFormField(
                initialValue: batDau,
                onChanged: (v) => batDau = v,
                decoration: InputDecoration(labelText: 'Giờ bắt đầu (HH:mm)'),
              ),
              SizedBox(height: 10),
              TextFormField(
                initialValue: ketThuc,
                onChanged: (v) => ketThuc = v,
                decoration: InputDecoration(labelText: 'Giờ kết thúc (HH:mm)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final success = await updateShift(shift['maCa'], {
                  'tenCa': tenCa,
                  'thoiGianBatDau': '$batDau:00',
                  'thoiGianKetThuc': '$ketThuc:00',
                });
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('✅ Cập nhật thành công')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ Cập nhật thất bại'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                _fetchShifts();
              },
              child: Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleDeleteShift(String maCa) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa ca trực $maCa?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await deleteShift(maCa);
      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('🗑️ Đã xóa ca trực $maCa')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Xóa thất bại'),
            backgroundColor: Colors.red,
          ),
        );
      }
      _fetchShifts();
    }
  }

  @override
  Widget build(BuildContext context) {
    // THIẾT KẾ LẠI THEO ẢNH
    return Scaffold(
      backgroundColor: Color(0xFFF4F7F6), // Màu nền xám nhạt
      appBar: AppBar(
        title: Text('Quản lý ca trực'),
        backgroundColor: Color(0xFF2C3E50),
        leading: IconButton(
          icon: FaIcon(
            FontAwesomeIcons.chevronLeft,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => context.go('/admin'), // Luôn quay về trang chủ
        ),
        actions: [
          IconButton(
            icon: FaIcon(FontAwesomeIcons.house, color: Colors.white, size: 20),
            tooltip: 'Trang chủ',
            onPressed: () => context.go('/admin'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề chính
            Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.clock,
                  color: Colors.blue[700],
                  size: 28,
                ),
                SizedBox(width: 12),
                Text(
                  'Quản lý ca trực bệnh viện',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Color(0xFF2C3E50),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // --- Form Thêm Ca Trực ---
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          FaIcon(
                            FontAwesomeIcons.plus,
                            size: 18,
                            color: Color(0xFF2C3E50),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Thêm ca trực mới',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),

                      TextFormField(
                        controller: _tenCaController,
                        decoration: InputDecoration(
                          labelText: 'Tên ca',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                        validator: (v) =>
                            v!.isEmpty ? 'Tên ca là bắt buộc' : null,
                      ),
                      SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: _buildTimePicker(
                              context,
                              'Giờ bắt đầu',
                              _batDauController,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: _buildTimePicker(
                              context,
                              'Giờ kết thúc',
                              _ketThucController,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _handleCreateShift,
                          icon: FaIcon(FontAwesomeIcons.plus, size: 16),
                          label: Text('Thêm ca'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            foregroundColor: Colors.white, // Màu chữ
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            textStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),

            // --- Bảng Danh sách Ca Trực ---
            Text(
              'Danh sách Ca Trực',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Color(0xFF2C3E50),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),

            if (_isLoading)
              Center(child: CircularProgressIndicator())
            else
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.antiAlias, // Giúp bo tròn DataTable
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 25, // Tăng khoảng cách
                    horizontalMargin: 12,
                    dataRowHeight: 52,
                    headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
                    columns: [
                      DataColumn(
                        label: Text(
                          'Mã ca',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Tên ca',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Bắt đầu',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Kết thúc',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Thao tác',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                    rows: _shifts.map((shift) {
                      return DataRow(
                        cells: [
                          DataCell(Text(shift['maCa'])),
                          DataCell(Text(shift['tenCa'])),
                          DataCell(
                            Text(
                              shift['thoiGianBatDau'].toString().substring(
                                0,
                                5,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              shift['thoiGianKetThuc'].toString().substring(
                                0,
                                5,
                              ),
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: FaIcon(
                                    FontAwesomeIcons.pen,
                                    size: 16,
                                    color: Colors.blue[700],
                                  ), // Sửa icon
                                  onPressed: () => _handleUpdateShift(shift),
                                  tooltip: 'Sửa',
                                  splashRadius: 20,
                                ),
                                IconButton(
                                  icon: FaIcon(
                                    FontAwesomeIcons.trashCan,
                                    size: 16,
                                    color: Colors.red[700],
                                  ), // Sửa icon
                                  onPressed: () =>
                                      _handleDeleteShift(shift['maCa']),
                                  tooltip: 'Xóa',
                                  splashRadius: 20,
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // SỬA LỖI 2: Sửa lại hàm _buildTimePicker
  Widget _buildTimePicker(
    BuildContext context,
    String label,
    TextEditingController controller,
  ) {
    return TextFormField(
      readOnly: true,
      controller: controller, // Sử dụng controller
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        suffixIcon: Icon(Icons.access_time, color: Colors.grey[600]),
      ),
      onTap: () async {
        final initialTime = TimeOfDay(
          hour: int.parse(controller.text.split(':')[0]),
          minute: int.parse(controller.text.split(':')[1]),
        );

        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: initialTime,
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(alwaysUse24HourFormat: true),
              child: child!,
            );
          },
        );

        if (picked != null) {
          final newTime =
              '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
          setState(() {
            controller.text = newTime;
          });
        }
      },
    );
  }
}
