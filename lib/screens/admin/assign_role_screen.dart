// lib/screens/admin/assign_role_screen.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'package:go_router/go_router.dart'; // Thêm import
import 'package:provider/provider.dart'; // Thêm import
import '../../auth/auth_provider.dart'; // Thêm import
import '../../models/user_model.dart';
import '../../services/api_client.dart';

// Helper API
final ApiClient _api = ApiClient();

class AssignRoleScreen extends StatefulWidget {
  const AssignRoleScreen({Key? key}) : super(key: key);

  @override
  _AssignRoleScreenState createState() => _AssignRoleScreenState();
}

class _AssignRoleScreenState extends State<AssignRoleScreen> {
  List<UserModel> _users = [];
  bool _isLoading = true;
  String _error = '';

  Map<String, String> _updatedRoles = {};
  final List<String> _roles = ['ADMIN', 'BACSI', 'NHANSU', 'BENHNHAN'];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    // Logic để tải danh sách người dùng
    setState(() {
      _isLoading = true;
      _updatedRoles = {};
      _error = '';
    });

    try {
      final response = await _api.get('/tai-khoan');
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List<dynamic> data = body['data'];
        final users = data.map((json) => UserModel.fromJson(json)).toList();
        setState(() {
          _users = users;
        });
      } else {
        final errorBody = jsonDecode(response.body);
        setState(() {
          _error = errorBody['message'] ?? 'Không thể tải danh sách';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Lỗi kết nối: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleChangeRole(String maTK, String? newRole) {
    // Logic khi thay đổi Dropdown
    if (newRole != null) {
      setState(() {
        _updatedRoles[maTK] = newRole;
      });
    }
  }

  void _handleSave(UserModel user) async {
    // Logic khi bấm nút Lưu
    final newRole = _updatedRoles[user.maTK] ?? user.maNhom;

    if (newRole == user.maNhom) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không có thay đổi để lưu.')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _api.put('/tai-khoan/${user.maTK}', {
        'maNhom': newRole,
      });

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Đã gán quyền $newRole cho ${user.tenDangNhap}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final errorBody = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '❌ Thao tác thất bại: ${errorBody['message'] ?? 'Lỗi'}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Lỗi API: $e'), backgroundColor: Colors.red),
      );
    }

    await _fetchUsers(); // Tải lại danh sách sau khi lưu
  }

  // --- HÀM HELPER MỚI ĐỂ LẤY MÀU CHO VAI TRÒ ---
  Color _getRoleColor(String role) {
    switch (role) {
      case 'ADMIN':
        return Colors.red[600]!;
      case 'BACSI':
        return Colors.blue[600]!;
      case 'NHANSU':
        return Colors.orange[600]!;
      case 'BENHNHAN':
        return Colors.green[600]!;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Màu nền cho toàn trang
      appBar: AppBar(
        title: Text('Phân quyền người dùng'),
        backgroundColor: Color(0xFF2C3E50), // Màu AppBar
        actions: [
          // Nút Trang chủ
          IconButton(
            icon: FaIcon(FontAwesomeIcons.house, color: Colors.white, size: 20),
            tooltip: 'Trang chủ',
            onPressed: () => context.go('/admin'),
          ),
          // Nút Đăng xuất
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
            // --- Header ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '🛡️ Phân quyền người dùng',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Color(0xFF2C3E50), // Màu tiêu đề
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: FaIcon(
                    FontAwesomeIcons.arrowsRotate,
                    size: 20,
                    color: Colors.blue[700],
                  ),
                  onPressed: _isLoading ? null : _fetchUsers,
                  tooltip: 'Tải lại danh sách',
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              'Chọn tài khoản và gán quyền mới bên dưới.',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
            ),
            SizedBox(height: 20),

            // --- Nội dung chính ---
            if (_isLoading)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_error.isNotEmpty)
              Center(
                child: Text(_error, style: TextStyle(color: Colors.red)),
              )
            else
              // Sử dụng ListView.builder để tạo danh sách Card
              ListView.builder(
                itemCount: _users.length,
                shrinkWrap:
                    true, // Cần thiết khi lồng trong SingleChildScrollView
                physics: NeverScrollableScrollPhysics(), // Cần thiết khi lồng
                itemBuilder: (context, index) {
                  final user = _users[index];
                  return _buildUserCard(user); // Widget Card mới
                },
              ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET MỚI: _buildUserCard ---
  Widget _buildUserCard(UserModel user) {
    // Lấy vai trò đã chọn (nếu có thay đổi) hoặc vai trò hiện tại
    final selectedRole = _updatedRoles[user.maTK] ?? user.maNhom;
    // Kiểm tra xem có thay đổi không
    final hasChange = selectedRole != user.maNhom;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Thông tin User (Avatar, Tên, Email) ---
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Color(0xFF2C3E50),
                  child: FaIcon(
                    FontAwesomeIcons.user,
                    color: Colors.white,
                    size: 18,
                  ),
                  radius: 20,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.tenDangNhap,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        user.email ?? '-',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Divider(height: 1),
            SizedBox(height: 16),

            // --- Phần Gán Quyền ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // --- Quyền hiện tại (Dùng Chip) ---
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quyền hiện tại:',
                        style: TextStyle(color: Colors.grey[700], fontSize: 12),
                      ),
                      SizedBox(height: 4),
                      Chip(
                        label: Text(
                          user.maNhom,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        backgroundColor: _getRoleColor(
                          user.maNhom,
                        ), // Dùng màu theo vai trò
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        visualDensity: VisualDensity(
                          horizontal: 0.0,
                          vertical: -4,
                        ), // Làm chip nhỏ lại
                      ),
                    ],
                  ),
                ),
                // --- Mũi tên ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: FaIcon(
                    FontAwesomeIcons.arrowRightLong,
                    color: Colors.grey[400],
                    size: 20,
                  ),
                ),
                // --- Gán quyền mới (Dropdown) ---
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gán quyền mới:',
                        style: TextStyle(color: Colors.grey[700], fontSize: 12),
                      ),
                      SizedBox(height: 4),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedRole,
                            items: _roles
                                .map(
                                  (role) => DropdownMenuItem(
                                    value: role,
                                    child: Text(role),
                                  ),
                                )
                                .toList(),
                            onChanged: (String? newValue) {
                              _handleChangeRole(user.maTK, newValue);
                            },
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            dropdownColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // --- Nút Lưu (Chỉ hiện khi có thay đổi) ---
            if (hasChange) ...[
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _handleSave(user),
                  icon: FaIcon(FontAwesomeIcons.solidFloppyDisk, size: 16),
                  label: Text('Lưu thay đổi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
