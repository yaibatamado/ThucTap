import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../services/api_client.dart';
import '../../theme/app_theme.dart';
import '../../widgets/auth_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKeyStep1 = GlobalKey<FormState>();
  final _formKeyStep2 = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();

  int _currentStep = 1;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _showSnackbar(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.danger : AppTheme.teal,
      ),
    );
  }

  Future<void> _handleRequestOtp() async {
    if (!_formKeyStep1.currentState!.validate()) return;
    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackbar('Mật khẩu xác nhận không khớp!');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await ApiClient().post('/auth/request-otp', {
        'tenDangNhap': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
      });

      if (!mounted) return;

      if (response.statusCode == 200) {
        _showSnackbar('Mã OTP đã được gửi đến email!', isError: false);
        setState(() => _currentStep = 2);
      } else {
        final errorBody = jsonDecode(response.body);
        _showSnackbar(errorBody['message'] ?? 'Lỗi gửi OTP.');
      }
    } catch (e) {
      _showSnackbar('Lỗi kết nối hoặc server: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKeyStep2.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final response = await ApiClient().post('/auth/register', {
        'tenDangNhap': _usernameController.text.trim(),
        'matKhau': _passwordController.text,
        'email': _emailController.text.trim(),
        'maNhom': 'BENHNHAN',
        'otpCode': _otpController.text.trim(),
      });

      if (!mounted) return;

      if (response.statusCode == 201) {
        _showSnackbar(
          'Đăng ký thành công! Vui lòng đăng nhập.',
          isError: false,
        );
        context.go('/login');
      } else {
        final errorBody = jsonDecode(response.body);
        _showSnackbar(errorBody['message'] ?? 'Đăng ký thất bại.');
      }
    } catch (e) {
      _showSnackbar('Lỗi kết nối hoặc server: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      icon: Icons.person_add_alt_1_rounded,
      title: 'Tạo tài khoản',
      subtitle: 'Đăng ký tài khoản bệnh nhân để sử dụng dịch vụ',
      accentColor: AppTheme.teal,
      child: _currentStep == 1
          ? _buildInfoStep(context)
          : _buildOtpStep(context),
    );
  }

  Widget _buildInfoStep(BuildContext context) {
    return Form(
      key: _formKeyStep1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Thông tin đăng ký',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            'Mã OTP sẽ được gửi đến email của bạn',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 22),
          AuthTextField(
            controller: _usernameController,
            label: 'Tên đăng nhập',
            icon: Icons.person_outline_rounded,
            readOnly: _isLoading,
            textInputAction: TextInputAction.next,
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Vui lòng nhập tên đăng nhập'
                : null,
          ),
          const SizedBox(height: 14),
          AuthTextField(
            controller: _emailController,
            label: 'Email',
            icon: Icons.mail_outline_rounded,
            readOnly: _isLoading,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (value) =>
                value == null || value.trim().isEmpty || !value.contains('@')
                ? 'Email không hợp lệ'
                : null,
          ),
          const SizedBox(height: 14),
          AuthTextField(
            controller: _passwordController,
            label: 'Mật khẩu',
            icon: Icons.lock_outline_rounded,
            obscureText: true,
            readOnly: _isLoading,
            textInputAction: TextInputAction.next,
            validator: (value) => value == null || value.length < 6
                ? 'Mật khẩu tối thiểu 6 ký tự'
                : null,
          ),
          const SizedBox(height: 14),
          AuthTextField(
            controller: _confirmPasswordController,
            label: 'Xác nhận mật khẩu',
            icon: Icons.verified_user_outlined,
            obscureText: true,
            readOnly: _isLoading,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _isLoading ? null : _handleRequestOtp(),
            validator: (value) => value != _passwordController.text
                ? 'Mật khẩu không khớp'
                : null,
          ),
          const SizedBox(height: 20),
          AuthPrimaryButton(
            text: 'Gửi mã OTP',
            isLoading: _isLoading,
            onPressed: _handleRequestOtp,
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: _isLoading
                ? null
                : () => _showSnackbar(
                    'Chức năng đăng ký bằng Google đang được phát triển.',
                    isError: false,
                  ),
            icon: const FaIcon(FontAwesomeIcons.google, size: 18),
            label: const Text('Đăng ký bằng Google'),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Đã có tài khoản?',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              TextButton(
                onPressed: () => context.go('/login'),
                child: const Text('Đăng nhập'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOtpStep(BuildContext context) {
    return Form(
      key: _formKeyStep2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Xác thực OTP',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Mã OTP đã được gửi tới ${_emailController.text}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 22),
          AuthTextField(
            controller: _otpController,
            label: 'Mã OTP',
            icon: Icons.pin_outlined,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _isLoading ? null : _handleRegister(),
            validator: (value) => value == null || value.trim().length != 6
                ? 'Mã OTP phải có 6 chữ số'
                : null,
          ),
          const SizedBox(height: 20),
          AuthPrimaryButton(
            text: 'Hoàn tất đăng ký',
            isLoading: _isLoading,
            onPressed: _handleRegister,
            color: AppTheme.teal,
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _isLoading
                ? null
                : () => setState(() => _currentStep = 1),
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: const Text('Quay lại nhập thông tin'),
          ),
        ],
      ),
    );
  }
}
