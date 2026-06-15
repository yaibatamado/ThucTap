import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_provider.dart';
import '../../models/user_model.dart';
import '../../services/api_client.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_components.dart';
import 'patient_bottom_nav_bar.dart';

class ThongTinCaNhanScreen extends StatefulWidget {
  const ThongTinCaNhanScreen({super.key});

  @override
  State<ThongTinCaNhanScreen> createState() => _ThongTinCaNhanScreenState();
}

class _ThongTinCaNhanScreenState extends State<ThongTinCaNhanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _formKeyPass = GlobalKey<FormState>();
  final _api = ApiClient();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _maTK;
  String? _maBN;
  String? _loadMessage;

  final _hoTen = TextEditingController();
  final _soDienThoai = TextEditingController();
  final _diaChi = TextEditingController();
  final _bhyt = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _gioiTinh;
  DateTime? _ngaySinh;
  String _tenDangNhap = '';
  String _email = '';

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _maTK = auth.maTK;
    _tenDangNhap = auth.tenDangNhap ?? 'Cao Thiên';
    _maBN = auth.maBN;
    _loadDemoData();
    _fetchData();
  }

  @override
  void dispose() {
    _hoTen.dispose();
    _soDienThoai.dispose();
    _diaChi.dispose();
    _bhyt.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _loadDemoData() {
    _hoTen.text = 'Cao Thiên';
    _soDienThoai.text = '0900000000';
    _diaChi.text = 'TP. Hồ Chí Minh';
    _bhyt.text = 'DN0123456789';
    _gioiTinh = 'Nam';
    _ngaySinh = DateTime(2003, 1, 1);
    _email = 'caothien@example.com';
  }

  Future<void> _fetchData() async {
    if (_maTK == null || _maTK!.isEmpty) {
      setState(() {
        _isLoading = false;
        _loadMessage = 'Đang dùng dữ liệu demo vì chưa có mã tài khoản.';
      });
      return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await _api.get('/benhnhan/findByMaTK/$_maTK');
      if (res.statusCode != 200) {
        throw Exception('Backend chưa trả dữ liệu bệnh nhân');
      }

      final data = jsonDecode(res.body)['data'];
      final user = UserModel.fromJson(data);

      setState(() {
        _maBN = user.maBN ?? _maBN;
        _hoTen.text = user.hoTen ?? _hoTen.text;
        _soDienThoai.text = user.soDienThoai ?? _soDienThoai.text;
        _diaChi.text = user.diaChi ?? _diaChi.text;
        _bhyt.text = user.bhyt ?? _bhyt.text;
        _gioiTinh = user.gioiTinh ?? _gioiTinh;
        _ngaySinh = user.ngaySinh != null
            ? DateTime.tryParse(user.ngaySinh!)
            : _ngaySinh;
        _tenDangNhap = data['TaiKhoan']?['tenDangNhap'] ?? _tenDangNhap;
        _email = data['TaiKhoan']?['email'] ?? _email;
        _loadMessage = null;
      });
    } catch (_) {
      setState(() {
        _loadMessage = 'Backend chưa sẵn sàng, đang hiển thị dữ liệu demo.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.danger : AppTheme.teal,
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final payload = {
      'hoTen': _hoTen.text.trim(),
      'soDienThoai': _soDienThoai.text.trim(),
      'diaChi': _diaChi.text.trim(),
      'bhyt': _bhyt.text.trim(),
      'gioiTinh': _gioiTinh,
      'ngaySinh': _ngaySinh?.toIso8601String().split('T').first,
    };

    setState(() => _isSaving = true);
    try {
      if (_maBN == null || _maBN!.contains('DEMO')) {
        _showSnack('Đã lưu tạm trên giao diện demo.');
        return;
      }

      final res = await _api.put('/benhnhan/$_maBN', payload);
      if (res.statusCode == 200) {
        _showSnack('Cập nhật thông tin thành công!');
      } else {
        _showSnack(
          jsonDecode(res.body)['message'] ?? 'Cập nhật thất bại.',
          isError: true,
        );
      }
    } catch (_) {
      _showSnack('Backend chưa sẵn sàng, chưa thể lưu thật.', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _handleChangePassword() async {
    if (!_formKeyPass.currentState!.validate()) return;
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showSnack('Mật khẩu mới không khớp.', isError: true);
      return;
    }

    try {
      final res = await _api.post('/auth/doi-mat-khau', {
        'maTK': _maTK,
        'matKhauCu': _oldPasswordController.text,
        'matKhauMoi': _newPasswordController.text,
      });

      if (res.statusCode == 200) {
        _showSnack('Đổi mật khẩu thành công!');
        _oldPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      } else {
        _showSnack(
          jsonDecode(res.body)['message'] ?? 'Đổi mật khẩu thất bại.',
          isError: true,
        );
      }
    } catch (_) {
      _showSnack(
        'Backend chưa sẵn sàng, chưa thể đổi mật khẩu.',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin cá nhân'),
        actions: [
          IconButton(
            tooltip: 'Trang chủ',
            onPressed: () => context.go('/patient'),
            icon: const Icon(Icons.home_rounded),
          ),
          IconButton(
            tooltip: 'Đăng xuất',
            onPressed: () async {
              await Provider.of<AuthProvider>(context, listen: false).logout();
              if (context.mounted) context.go('/login');
            },
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchData,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                children: [
                  _ProfileHeader(
                    name: _hoTen.text.isEmpty ? _tenDangNhap : _hoTen.text,
                    username: _tenDangNhap,
                    email: _email,
                    message: _loadMessage,
                  ),
                  const SizedBox(height: 18),
                  _AccountInfoCard(
                    tenDangNhap: _tenDangNhap,
                    email: _email,
                    maTK: _maTK ?? 'TK_DEMO',
                    maBN: _maBN ?? 'BN_DEMO',
                  ),
                  const SizedBox(height: 18),
                  _PersonalInfoForm(
                    formKey: _formKey,
                    hoTen: _hoTen,
                    soDienThoai: _soDienThoai,
                    diaChi: _diaChi,
                    bhyt: _bhyt,
                    gioiTinh: _gioiTinh,
                    ngaySinh: _ngaySinh,
                    isSaving: _isSaving,
                    onGenderChanged: (value) =>
                        setState(() => _gioiTinh = value),
                    onDateChanged: (value) => setState(() => _ngaySinh = value),
                    onSubmit: _handleSubmit,
                  ),
                  const SizedBox(height: 18),
                  _PasswordCard(
                    formKey: _formKeyPass,
                    oldPassword: _oldPasswordController,
                    newPassword: _newPasswordController,
                    confirmPassword: _confirmPasswordController,
                    onSubmit: _handleChangePassword,
                  ),
                ],
              ),
            ),
      bottomNavigationBar: const PatientBottomNavBar(currentIndex: 3),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    required this.username,
    required this.email,
    required this.message,
  });

  final String name;
  final String username;
  final String email;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          CircleAvatar(
            radius: 38,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.12),
            child: Icon(
              Icons.person_rounded,
              size: 42,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            name,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 4),
          Text(username, style: Theme.of(context).textTheme.bodyMedium),
          if (email.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(email, style: Theme.of(context).textTheme.bodyMedium),
          ],
          if (message != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      message!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AccountInfoCard extends StatelessWidget {
  const _AccountInfoCard({
    required this.tenDangNhap,
    required this.email,
    required this.maTK,
    required this.maBN,
  });

  final String tenDangNhap;
  final String email;
  final String maTK;
  final String maBN;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin tài khoản',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.account_circle_rounded,
            label: 'Tên đăng nhập',
            value: tenDangNhap,
          ),
          _InfoRow(icon: Icons.mail_rounded, label: 'Email', value: email),
          _InfoRow(
            icon: Icons.badge_rounded,
            label: 'Mã tài khoản',
            value: maTK,
          ),
          _InfoRow(
            icon: Icons.local_hospital_rounded,
            label: 'Mã bệnh nhân',
            value: maBN,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? 'Chưa cập nhật' : value,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonalInfoForm extends StatelessWidget {
  const _PersonalInfoForm({
    required this.formKey,
    required this.hoTen,
    required this.soDienThoai,
    required this.diaChi,
    required this.bhyt,
    required this.gioiTinh,
    required this.ngaySinh,
    required this.isSaving,
    required this.onGenderChanged,
    required this.onDateChanged,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController hoTen;
  final TextEditingController soDienThoai;
  final TextEditingController diaChi;
  final TextEditingController bhyt;
  final String? gioiTinh;
  final DateTime? ngaySinh;
  final bool isSaving;
  final ValueChanged<String?> onGenderChanged;
  final ValueChanged<DateTime?> onDateChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Thông tin cá nhân',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _TextField(label: 'Họ tên', controller: hoTen),
            _DateField(date: ngaySinh, onChanged: onDateChanged),
            DropdownButtonFormField<String>(
              initialValue: gioiTinh,
              decoration: const InputDecoration(labelText: 'Giới tính'),
              items: const ['Nam', 'Nữ', 'Khác']
                  .map(
                    (item) => DropdownMenuItem(value: item, child: Text(item)),
                  )
                  .toList(),
              onChanged: onGenderChanged,
              validator: (value) =>
                  value == null ? 'Vui lòng chọn giới tính' : null,
            ),
            const SizedBox(height: 14),
            _TextField(
              label: 'Số điện thoại',
              controller: soDienThoai,
              keyboardType: TextInputType.phone,
            ),
            _TextField(label: 'Địa chỉ', controller: diaChi),
            _TextField(
              label: 'Số thẻ BHYT',
              controller: bhyt,
              requiredField: false,
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: isSaving ? null : onSubmit,
              icon: const Icon(Icons.save_rounded),
              label: Text(isSaving ? 'Đang lưu...' : 'Lưu thông tin'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PasswordCard extends StatelessWidget {
  const _PasswordCard({
    required this.formKey,
    required this.oldPassword,
    required this.newPassword,
    required this.confirmPassword,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController oldPassword;
  final TextEditingController newPassword;
  final TextEditingController confirmPassword;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Đổi mật khẩu', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _TextField(
              label: 'Mật khẩu hiện tại',
              controller: oldPassword,
              isPassword: true,
            ),
            _TextField(
              label: 'Mật khẩu mới',
              controller: newPassword,
              isPassword: true,
              validator: (value) => value != null && value.length < 6
                  ? 'Mật khẩu tối thiểu 6 ký tự'
                  : null,
            ),
            _TextField(
              label: 'Xác nhận mật khẩu mới',
              controller: confirmPassword,
              isPassword: true,
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: onSubmit,
              icon: const Icon(Icons.key_rounded),
              label: const Text('Đổi mật khẩu'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.requiredField = true,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool isPassword;
  final bool requiredField;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: isPassword
              ? const Icon(Icons.visibility_off_rounded)
              : null,
        ),
        validator:
            validator ??
            (value) {
              if (requiredField && (value == null || value.trim().isEmpty)) {
                return '$label là bắt buộc';
              }
              return null;
            },
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.date, required this.onChanged});

  final DateTime? date;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        readOnly: true,
        controller: TextEditingController(
          text: date == null ? '' : DateFormat('dd/MM/yyyy').format(date!),
        ),
        decoration: const InputDecoration(
          labelText: 'Ngày sinh',
          suffixIcon: Icon(Icons.calendar_today_rounded),
        ),
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: date ?? DateTime(2003, 1, 1),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );
          if (picked != null) onChanged(picked);
        },
        validator: (value) =>
            value == null || value.isEmpty ? 'Ngày sinh là bắt buộc' : null,
      ),
    );
  }
}
