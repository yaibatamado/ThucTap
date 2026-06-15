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

class PhieuXN {
  const PhieuXN({
    required this.maPhieuXN,
    required this.tenXN,
    required this.tenLoai,
    required this.ngayThucHien,
    required this.ketQua,
    required this.tenNS,
  });

  final String maPhieuXN;
  final String tenXN;
  final String tenLoai;
  final DateTime? ngayThucHien;
  final String? ketQua;
  final String tenNS;

  factory PhieuXN.fromJson(Map<String, dynamic> json) => PhieuXN(
    maPhieuXN: json['maPhieuXN']?.toString() ?? 'PXN-DEMO',
    tenXN: json['XetNghiem']?['tenXN']?.toString() ?? 'Xét nghiệm',
    tenLoai:
        json['XetNghiem']?['LoaiXetNghiem']?['tenLoai']?.toString() ??
        'Tổng quát',
    ngayThucHien: DateTime.tryParse(json['ngayThucHien']?.toString() ?? ''),
    ketQua: json['ketQua']?.toString(),
    tenNS: json['NhanSuYTe']?['hoTen']?.toString() ?? 'Kỹ thuật viên',
  );

  String get ngayText => ngayThucHien == null
      ? 'Chưa có lịch'
      : DateFormat('dd/MM/yyyy HH:mm').format(ngayThucHien!.toLocal());
}

class KetQuaXetNghiemScreen extends StatefulWidget {
  const KetQuaXetNghiemScreen({super.key});

  @override
  State<KetQuaXetNghiemScreen> createState() => _KetQuaXetNghiemScreenState();
}

class _KetQuaXetNghiemScreenState extends State<KetQuaXetNghiemScreen> {
  final _api = ApiClient();
  bool _isLoading = true;
  List<PhieuXN> _results = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final maBN = context.read<AuthProvider>().maBN ?? 'BN001';

    try {
      final response = await _api.get('/phieuxetnghiem');
      final data = jsonDecode(response.body)['data'] as List;
      if (!mounted) return;
      setState(() {
        _results = data
            .where((item) => item['YeuCau']?['maBN'] == maBN)
            .map((item) => PhieuXN.fromJson(item))
            .toList();
      });
    } catch (e) {
      _showSnack('Không thể tải kết quả xét nghiệm: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.danger),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kết quả xét nghiệm')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            _buildHero(),
            const SizedBox(height: 18),
            SectionHeader(
              title: 'Phiếu gần đây',
              actionLabel: 'Làm mới',
              onAction: _load,
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_results.isEmpty)
              _buildEmptyState()
            else
              ..._results.map(_buildResultCard),
          ],
        ),
      ),
      bottomNavigationBar: const PatientBottomNavBar(currentIndex: 2),
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
              color: Colors.purple.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.biotech_rounded,
              color: Colors.purple,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Theo dõi kết quả',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  'Xem trạng thái phiếu xét nghiệm, kết quả và người thực hiện.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(PhieuXN item) {
    final hasResult = item.ketQua != null && item.ketQua!.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        onTap: () => context.go('/patient/xetnghiem/${item.maPhieuXN}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.tenXN,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                _ResultChip(
                  label: hasResult ? 'Đã có kết quả' : 'Đang xử lý',
                  color: hasResult ? AppTheme.teal : Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(item.tenLoai, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 12),
            _MetaLine(icon: Icons.schedule_rounded, text: item.ngayText),
            _MetaLine(icon: Icons.person_outline_rounded, text: item.tenNS),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () =>
                  context.go('/patient/xetnghiem/${item.maPhieuXN}'),
              icon: const Icon(Icons.description_outlined),
              label: const Text('Xem chi tiết'),
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
          Icon(Icons.science_outlined, size: 44, color: context.appMuted),
          const SizedBox(height: 10),
          Text(
            'Chưa có kết quả',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Khi có phiếu xét nghiệm, kết quả sẽ hiển thị tại đây.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.icon, required this.text});

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

class _ResultChip extends StatelessWidget {
  const _ResultChip({required this.label, required this.color});

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
