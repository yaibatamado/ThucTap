// lib/screens/chat/chat_list_screen.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Thêm import
import 'package:go_router/go_router.dart'; // Thêm import
import 'package:provider/provider.dart'; // Thêm import
import '../../auth/auth_provider.dart'; // Thêm import
import '../../services/chat_service.dart';
import '../../models/user_model.dart';

class ChatListScreen extends StatefulWidget {
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late Future<List<UserModel>> _contactsFuture;

  @override
  void initState() {
    super.initState();
    _contactsFuture = ChatService().getContacts();
  }

  // Hàm helper lấy màu cho vai trò
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

  // Hàm helper lấy icon cho vai trò
  FaIconData _getRoleIcon(String role) {
    switch (role) {
      case 'ADMIN':
        return FontAwesomeIcons.userShield;
      case 'BACSI':
        return FontAwesomeIcons.userDoctor;
      case 'NHANSU':
        return FontAwesomeIcons.userNurse;
      case 'BENHNHAN':
        return FontAwesomeIcons.userInjured;
      default:
        return FontAwesomeIcons.user;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Nền xám
      appBar: AppBar(
        title: Text('Chat nội bộ'),
        backgroundColor: Color(0xFF2C3E50),
        // THÊM NÚT HOME VÀ ĐĂNG XUẤT
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
      body: FutureBuilder<List<UserModel>>(
        future: _contactsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi tải danh bạ: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Không tìm thấy ai trong danh bạ.'));
          }

          final contacts = snapshot.data!;
          // --- SỬA: DÙNG ListView.builder VỚI Card ---
          return ListView.builder(
            padding: EdgeInsets.all(12), // Thêm padding
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: _getRoleColor(contact.maNhom),
                    child: FaIcon(
                      _getRoleIcon(contact.maNhom),
                      color: Colors.white,
                      size: 18,
                    ),
                    radius: 22,
                  ),
                  title: Text(
                    contact.hoTen ?? contact.tenDangNhap,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text(
                    'Vai trò: ${contact.maNhom}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Sẽ mở chat với ${contact.tenDangNhap}'),
                      ),
                    );
                    // TODO: Khi có socket
                    // context.push('/chat/window', extra: contact);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
