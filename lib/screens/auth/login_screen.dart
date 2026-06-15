import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_provider.dart';
import '../../services/api_client.dart';
import '../../theme/app_theme.dart';
import '../../widgets/auth_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _showPassword = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnackbar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.danger : AppTheme.teal,
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final response = await ApiClient().post('/auth/login', {
        'tenDangNhap': _usernameController.text.trim(),
        'matKhau': _passwordController.text,
      });

      if (!mounted) return;

      if (response.statusCode == 200) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.login(jsonDecode(response.body));
        if (!mounted) return;

        _showSnackbar('Đăng nhập thành công!', isError: false);
        _goToHome(authProvider);
      } else {
        final errorBody = jsonDecode(response.body);
        _showSnackbar(errorBody['message'] ?? 'Sai tài khoản hoặc mật khẩu!');
      }
    } catch (e) {
      if (mounted) _showSnackbar('Lỗi kết nối hoặc server: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleDemoLogin(String username) async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiClient().post('/auth/login', {
        'tenDangNhap': username,
        'matKhau': 'demo',
      });

      if (!mounted) return;

      if (response.statusCode == 200) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.login(jsonDecode(response.body));
        if (!mounted) return;

        _showSnackbar('Đã vào chế độ demo.', isError: false);
        _goToHome(authProvider);
      } else {
        final errorBody = jsonDecode(response.body);
        _showSnackbar(errorBody['message'] ?? 'Không thể mở chế độ demo.');
      }
    } catch (e) {
      if (mounted) _showSnackbar('Không thể mở chế độ demo: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goToHome(AuthProvider authProvider) {
    switch (authProvider.role) {
      case 'ADMIN':
        context.go('/admin');
        break;
      case 'BACSI':
        context.go('/doctor');
        break;
      case 'BENHNHAN':
        context.go('/patient');
        break;
      case 'NHANSU':
        if (authProvider.loaiNS == 'YT') {
          context.go('/yta');
        } else if (authProvider.loaiNS == 'XN') {
          context.go('/xetnghiem');
        } else if (authProvider.loaiNS == 'TN') {
          context.go('/tiepnhan');
        } else {
          context.go('/login');
        }
        break;
      default:
        context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      icon: Icons.local_hospital_rounded,
      title: 'App Bệnh Viện',
      subtitle: 'Quản lý y tế nhanh, rõ ràng và an toàn',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Đăng nhập tài khoản',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              'Nhập thông tin để tiếp tục sử dụng hệ thống',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            AuthTextField(
              controller: _usernameController,
              label: 'Tên đăng nhập',
              icon: Icons.person_outline_rounded,
              textInputAction: TextInputAction.next,
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Vui lòng nhập tên đăng nhập'
                  : null,
            ),
            const SizedBox(height: 14),
            AuthTextField(
              controller: _passwordController,
              label: 'Mật khẩu',
              icon: Icons.lock_outline_rounded,
              obscureText: !_showPassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _isLoading ? null : _handleLogin(),
              suffix: IconButton(
                onPressed: () => setState(() => _showPassword = !_showPassword),
                icon: Icon(
                  _showPassword
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                ),
              ),
              validator: (value) => value == null || value.isEmpty
                  ? 'Vui lòng nhập mật khẩu'
                  : null,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.go('/forgot-password'),
                child: const Text('Quên mật khẩu?'),
              ),
            ),
            const SizedBox(height: 12),
            AuthPrimaryButton(
              text: 'Đăng nhập',
              isLoading: _isLoading,
              onPressed: _handleLogin,
            ),
            const SizedBox(height: 18),
            Text(
              'Chạy thử không cần backend',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 10),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                _DemoLoginChip(
                  label: 'Bệnh nhân',
                  icon: Icons.personal_injury_outlined,
                  onPressed: _isLoading
                      ? null
                      : () => _handleDemoLogin('benhnhan'),
                ),
                _DemoLoginChip(
                  label: 'Bác sĩ',
                  icon: Icons.medical_services_outlined,
                  onPressed: _isLoading
                      ? null
                      : () => _handleDemoLogin('bacsi'),
                ),
                _DemoLoginChip(
                  label: 'Admin',
                  icon: Icons.admin_panel_settings_outlined,
                  onPressed: _isLoading
                      ? null
                      : () => _handleDemoLogin('admin'),
                ),
                _DemoLoginChip(
                  label: 'Y tá',
                  icon: Icons.health_and_safety_outlined,
                  onPressed: _isLoading ? null : () => _handleDemoLogin('yta'),
                ),
                _DemoLoginChip(
                  label: 'Tiếp nhận',
                  icon: Icons.assignment_ind_outlined,
                  onPressed: _isLoading
                      ? null
                      : () => _handleDemoLogin('tiepnhan'),
                ),
                _DemoLoginChip(
                  label: 'Xét nghiệm',
                  icon: Icons.science_outlined,
                  onPressed: _isLoading
                      ? null
                      : () => _handleDemoLogin('xetnghiem'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Chưa có tài khoản?',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                TextButton(
                  onPressed: () => context.go('/register'),
                  child: const Text('Đăng ký ngay'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DemoLoginChip extends StatelessWidget {
  const _DemoLoginChip({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onPressed,
      side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      backgroundColor: Theme.of(context).colorScheme.surface,
      labelStyle: Theme.of(context).textTheme.labelLarge,
    );
  }
}
