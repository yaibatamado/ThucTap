import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/api_client.dart';
import '../../theme/app_theme.dart';
import '../../widgets/auth_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiClient();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  int _currentStep = 1;
  bool _isLoading = false;
  String _email = '';

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final email = _emailController.text.trim();
      final response = await _api.post('/auth/forgot-password', {
        'email': email,
      });

      if (!mounted) return;

      if (response.statusCode == 200) {
        _email = email;
        _showSnackbar('Mã xác thực đã được gửi đến email!', isError: false);
        setState(() => _currentStep = 2);
      } else {
        final errorBody = jsonDecode(response.body);
        _showSnackbar(errorBody['message'] ?? 'Lỗi gửi mã xác thực.');
      }
    } catch (e) {
      _showSnackbar('Lỗi kết nối hoặc server: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showSnackbar('Mật khẩu mới không khớp.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await _api.post('/auth/reset-password', {
        'email': _email,
        'otpCode': _otpController.text.trim(),
        'newPassword': _newPasswordController.text,
      });

      if (!mounted) return;

      if (response.statusCode == 200) {
        _showSnackbar(
          'Đặt lại mật khẩu thành công! Vui lòng đăng nhập.',
          isError: false,
        );
        context.go('/login');
      } else {
        final errorBody = jsonDecode(response.body);
        _showSnackbar(errorBody['message'] ?? 'Đặt lại mật khẩu thất bại.');
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
      icon: Icons.lock_reset_rounded,
      title: 'Quên mật khẩu',
      subtitle: 'Nhận mã xác thực và đặt lại mật khẩu mới',
      child: Form(
        key: _formKey,
        child: _currentStep == 1
            ? _buildEmailStep(context)
            : _buildResetStep(context),
      ),
    );
  }

  Widget _buildEmailStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Xác minh email',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 6),
        Text(
          'Nhập email đã đăng ký để nhận mã OTP',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        AuthTextField(
          controller: _emailController,
          label: 'Email đăng ký',
          icon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _isLoading ? null : _handleRequestOtp(),
          validator: (value) =>
              value == null || value.trim().isEmpty || !value.contains('@')
              ? 'Email không hợp lệ'
              : null,
        ),
        const SizedBox(height: 20),
        AuthPrimaryButton(
          text: 'Gửi mã xác thực',
          isLoading: _isLoading,
          onPressed: _handleRequestOtp,
        ),
        const SizedBox(height: 18),
        TextButton.icon(
          onPressed: () => context.go('/login'),
          icon: const Icon(Icons.arrow_back_rounded, size: 18),
          label: const Text('Quay lại đăng nhập'),
        ),
      ],
    );
  }

  Widget _buildResetStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Đặt lại mật khẩu',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Mã OTP đã được gửi tới $_email',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 22),
        AuthTextField(
          controller: _otpController,
          label: 'Mã OTP',
          icon: Icons.pin_outlined,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          validator: (value) => value == null || value.trim().length != 6
              ? 'Mã OTP phải có 6 chữ số'
              : null,
        ),
        const SizedBox(height: 14),
        AuthTextField(
          controller: _newPasswordController,
          label: 'Mật khẩu mới',
          icon: Icons.lock_outline_rounded,
          obscureText: true,
          textInputAction: TextInputAction.next,
          validator: (value) => value == null || value.length < 6
              ? 'Mật khẩu tối thiểu 6 ký tự'
              : null,
        ),
        const SizedBox(height: 14),
        AuthTextField(
          controller: _confirmPasswordController,
          label: 'Xác nhận mật khẩu mới',
          icon: Icons.verified_user_outlined,
          obscureText: true,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _isLoading ? null : _handleResetPassword(),
          validator: (value) => value != _newPasswordController.text
              ? 'Mật khẩu không khớp'
              : null,
        ),
        const SizedBox(height: 20),
        AuthPrimaryButton(
          text: 'Đặt lại mật khẩu',
          isLoading: _isLoading,
          onPressed: _handleResetPassword,
          color: AppTheme.teal,
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: _isLoading ? null : () => setState(() => _currentStep = 1),
          icon: const Icon(Icons.arrow_back_rounded, size: 18),
          label: const Text('Đổi email'),
        ),
      ],
    );
  }
}
