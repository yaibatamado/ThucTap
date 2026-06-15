import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_provider.dart';
import '../../services/api_client.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_components.dart';
import 'patient_bottom_nav_bar.dart';

class Khoa {
  const Khoa({required this.maKhoa, required this.tenKhoa});

  final String maKhoa;
  final String tenKhoa;

  factory Khoa.fromJson(Map<String, dynamic> json) => Khoa(
    maKhoa: json['maKhoa']?.toString() ?? '',
    tenKhoa: json['tenKhoa']?.toString() ?? 'Khoa khám',
  );
}

class BacSi {
  const BacSi({
    required this.maBS,
    required this.hoTen,
    required this.maKhoa,
    this.chuyenMon,
  });

  final String maBS;
  final String hoTen;
  final String maKhoa;
  final String? chuyenMon;

  factory BacSi.fromJson(Map<String, dynamic> json) => BacSi(
    maBS: json['maBS']?.toString() ?? '',
    hoTen: json['hoTen']?.toString() ?? 'Bác sĩ',
    maKhoa: json['maKhoa']?.toString() ?? '',
    chuyenMon: json['chuyenMon']?.toString(),
  );
}

class LichHenModel {
  const LichHenModel({
    required this.maLich,
    required this.maBS,
    required this.tenBS,
    required this.ngayKham,
    required this.gioKham,
    required this.trangThai,
    required this.ghiChu,
    required this.phong,
  });

  final String maLich;
  final String maBS;
  final String tenBS;
  final DateTime ngayKham;
  final String gioKham;
  final String trangThai;
  final String ghiChu;
  final String phong;

  factory LichHenModel.fromJson(Map<String, dynamic> json) {
    final parsedDate =
        DateTime.tryParse(json['ngayKham']?.toString() ?? '') ?? DateTime.now();

    return LichHenModel(
      maLich: json['maLich']?.toString() ?? 'LK-DEMO',
      maBS: json['maBS']?.toString() ?? '',
      tenBS: json['BacSi']?['hoTen']?.toString() ?? 'Bác sĩ phụ trách',
      ngayKham: parsedDate,
      gioKham: json['gioKham']?.toString() ?? '08:00',
      trangThai: json['trangThai']?.toString() ?? 'CHO_THANH_TOAN',
      ghiChu: json['ghiChu']?.toString() ?? 'Khám tổng quát',
      phong: json['phong']?.toString() ?? 'P.201',
    );
  }

  String get ngayText => DateFormat('dd/MM/yyyy').format(ngayKham);
}

class LichHenBNScreen extends StatefulWidget {
  const LichHenBNScreen({super.key});

  @override
  State<LichHenBNScreen> createState() => _LichHenBNScreenState();
}

class _LichHenBNScreenState extends State<LichHenBNScreen> {
  final _api = ApiClient();
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  bool _isLoading = true;
  bool _isSubmitting = false;
  List<Khoa> _khoaList = [];
  List<BacSi> _bacSiList = [];
  List<LichHenModel> _appointments = [];

  String? _selectedKhoa;
  String? _selectedBacSi;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedTime = '08:30';

  final _timeOptions = const [
    '07:30',
    '08:30',
    '09:30',
    '10:30',
    '13:30',
    '14:30',
    '15:30',
    '16:30',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final maBN = context.read<AuthProvider>().maBN ?? 'BN001';

    try {
      final responses = await Future.wait([
        _api.get('/khoa'),
        _api.get('/bacsi'),
        _api.get('/lichkham/benhnhan/$maBN'),
      ]);

      final khoaData = jsonDecode(responses[0].body)['data'] as List;
      final bacSiData = jsonDecode(responses[1].body)['data'] as List;
      final lichData = jsonDecode(responses[2].body)['data'] as List;

      if (!mounted) return;
      setState(() {
        _khoaList = khoaData.map((item) => Khoa.fromJson(item)).toList();
        _bacSiList = bacSiData.map((item) => BacSi.fromJson(item)).toList();
        _appointments = lichData
            .map((item) => LichHenModel.fromJson(item))
            .toList();
        _selectedKhoa = _khoaList.isNotEmpty ? _khoaList.first.maKhoa : null;
        _selectedBacSi = _filteredDoctors.isNotEmpty
            ? _filteredDoctors.first.maBS
            : null;
      });
    } catch (e) {
      _showSnack('Không thể tải dữ liệu lịch hẹn: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<BacSi> get _filteredDoctors {
    if (_selectedKhoa == null) return _bacSiList;
    return _bacSiList
        .where((doctor) => doctor.maKhoa == _selectedKhoa)
        .toList();
  }

  Future<void> _createAppointment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final maBN = context.read<AuthProvider>().maBN ?? 'BN001';

    try {
      final response = await _api.post('/lichkham', {
        'maBN': maBN,
        'tenKhoa': _selectedKhoa,
        'maBS': _selectedBacSi,
        'ngayKham': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'gioKham': _selectedTime,
        'ghiChu': _reasonController.text.trim(),
        'phong': 'P.201',
      });

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final maLich = body['data']?['maLich']?.toString() ?? 'LK-DEMO';

      if (!mounted) return;
      _showSnack('Đã tạo lịch hẹn demo.', isError: false);
      context.go('/patient/payment/qr/$maLich');
    } catch (e) {
      _showSnack('Không thể tạo lịch hẹn: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _cancelAppointment(String maLich) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy lịch hẹn'),
        content: Text('Bạn có chắc muốn hủy lịch $maLich không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Không'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hủy lịch'),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    await _api.delete('/lichkham/$maLich');
    if (!mounted) return;
    setState(() {
      _appointments = _appointments
          .where((item) => item.maLich != maLich)
          .toList();
    });
    _showSnack('Đã hủy lịch hẹn demo.', isError: false);
  }

  void _showSnack(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.danger : AppTheme.teal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lịch hẹn khám')),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            _buildHero(),
            const SizedBox(height: 18),
            _buildForm(),
            const SizedBox(height: 22),
            SectionHeader(
              title: 'Lịch của tôi',
              actionLabel: 'Làm mới',
              onAction: _loadData,
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_appointments.isEmpty)
              _buildEmptyState()
            else
              ..._appointments.map(_buildAppointmentCard),
          ],
        ),
      ),
      bottomNavigationBar: const PatientBottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildHero() {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.event_available_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đặt lịch nhanh',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  'Chọn khoa, bác sĩ và thời gian phù hợp. Demo sẽ chuyển sang QR để hoàn tất đặt chỗ.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return AppCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Thông tin đặt lịch',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _selectedKhoa,
              decoration: const InputDecoration(
                labelText: 'Khoa khám',
                prefixIcon: Icon(Icons.local_hospital_outlined),
              ),
              items: _khoaList
                  .map(
                    (item) => DropdownMenuItem(
                      value: item.maKhoa,
                      child: Text(item.tenKhoa),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedKhoa = value;
                  _selectedBacSi = _filteredDoctors.isNotEmpty
                      ? _filteredDoctors.first.maBS
                      : null;
                });
              },
              validator: (value) => value == null ? 'Vui lòng chọn khoa' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedBacSi,
              decoration: const InputDecoration(
                labelText: 'Bác sĩ',
                prefixIcon: Icon(Icons.medical_services_outlined),
              ),
              items: _filteredDoctors
                  .map(
                    (item) => DropdownMenuItem(
                      value: item.maBS,
                      child: Text(
                        '${item.hoTen} - ${item.chuyenMon ?? item.maBS}',
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _selectedBacSi = value),
              validator: (value) =>
                  value == null ? 'Vui lòng chọn bác sĩ' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildDateField()),
                const SizedBox(width: 12),
                Expanded(child: _buildTimeField()),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _reasonController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Lý do khám',
                prefixIcon: Icon(Icons.notes_rounded),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Vui lòng nhập lý do khám'
                  : null,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _createAppointment,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.qr_code_2_rounded),
              label: Text(
                _isSubmitting
                    ? 'Đang tạo lịch...'
                    : 'Đặt lịch và thanh toán QR',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      readOnly: true,
      decoration: const InputDecoration(
        labelText: 'Ngày khám',
        prefixIcon: Icon(Icons.calendar_today_outlined),
      ),
      controller: TextEditingController(
        text: DateFormat('dd/MM/yyyy').format(_selectedDate),
      ),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 60)),
        );
        if (picked != null) setState(() => _selectedDate = picked);
      },
    );
  }

  Widget _buildTimeField() {
    return DropdownButtonFormField<String>(
      value: _selectedTime,
      decoration: const InputDecoration(
        labelText: 'Giờ khám',
        prefixIcon: Icon(Icons.schedule_outlined),
      ),
      items: _timeOptions
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: (value) => setState(() => _selectedTime = value ?? '08:30'),
    );
  }

  Widget _buildAppointmentCard(LichHenModel item) {
    final status = _statusMeta(item.trangThai);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        onTap: () => context.go('/patient/lich/${item.maLich}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.tenBS,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                _StatusChip(label: status.label, color: status.color),
              ],
            ),
            const SizedBox(height: 10),
            _InfoLine(
              icon: Icons.event_rounded,
              text: '${item.gioKham} - ${item.ngayText}',
            ),
            _InfoLine(icon: Icons.meeting_room_outlined, text: item.phong),
            _InfoLine(icon: Icons.notes_rounded, text: item.ghiChu),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.go('/patient/lich/${item.maLich}'),
                    icon: const Icon(Icons.visibility_outlined),
                    label: const Text('Chi tiết'),
                  ),
                ),
                const SizedBox(width: 10),
                if (item.trangThai == 'CHO_THANH_TOAN')
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          context.go('/patient/payment/qr/${item.maLich}'),
                      icon: const Icon(Icons.qr_code_rounded),
                      label: const Text('QR'),
                    ),
                  )
                else
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _cancelAppointment(item.maLich),
                      icon: const Icon(Icons.close_rounded),
                      label: const Text('Hủy'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return AppCard(
      child: Column(
        children: [
          Icon(Icons.event_busy_rounded, size: 44, color: context.appMuted),
          const SizedBox(height: 10),
          Text(
            'Chưa có lịch hẹn',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Bạn có thể đặt lịch mới bằng biểu mẫu phía trên.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: context.appMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

({String label, Color color}) _statusMeta(String status) {
  return switch (status) {
    'DA_THANH_TOAN' ||
    'Đã xác nhận' => (label: 'Đã xác nhận', color: AppTheme.teal),
    'DA_KHAM' => (label: 'Đã khám', color: Colors.indigo),
    'DA_HUY' => (label: 'Đã hủy', color: AppTheme.danger),
    _ => (label: 'Chờ thanh toán', color: Colors.orange),
  };
}
