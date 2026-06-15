import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_provider.dart';
import '../../services/api_client.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_components.dart';

class KetQuaXetNghiemDetailScreen extends StatefulWidget {
  const KetQuaXetNghiemDetailScreen({super.key, required this.maPhieuXN});

  final String maPhieuXN;

  @override
  State<KetQuaXetNghiemDetailScreen> createState() =>
      _KetQuaXetNghiemDetailScreenState();
}

class _KetQuaXetNghiemDetailScreenState
    extends State<KetQuaXetNghiemDetailScreen> {
  final _api = ApiClient();
  Map<String, dynamic>? _result;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final maBN = context.read<AuthProvider>().maBN ?? 'BN001';
    final response = await _api.get('/phieuxetnghiem');
    final data = jsonDecode(response.body)['data'] as List;
    final filtered = data
        .cast<Map<String, dynamic>>()
        .where((item) => item['YeuCau']?['maBN'] == maBN)
        .toList();
    final item = filtered.firstWhere(
      (row) => row['maPhieuXN']?.toString() == widget.maPhieuXN,
      orElse: () => filtered.isNotEmpty ? filtered.first : <String, dynamic>{},
    );

    if (!mounted) return;
    setState(() {
      _result = item;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết xét nghiệm')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : result == null || result.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: AppCard(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.science_outlined, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        'Không tìm thấy phiếu',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => context.go('/patient/xetnghiem'),
                        child: const Text('Quay lại'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(18),
              children: [
                _buildHeader(result),
                const SizedBox(height: 16),
                _buildResult(result),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => context.go('/patient/xetnghiem'),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Quay lại danh sách'),
                ),
              ],
            ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> result) {
    final hasResult = result['ketQua']?.toString().trim().isNotEmpty == true;
    final testName = result['XetNghiem']?['tenXN']?.toString() ?? 'Xét nghiệm';
    final category =
        result['XetNghiem']?['LoaiXetNghiem']?['tenLoai']?.toString() ??
        'Tổng quát';

    return AppCard(
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: (hasResult ? AppTheme.teal : Colors.orange).withValues(
                alpha: 0.12,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              hasResult
                  ? Icons.fact_check_rounded
                  : Icons.hourglass_top_rounded,
              color: hasResult ? AppTheme.teal : Colors.orange,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(testName, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(category, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult(Map<String, dynamic> result) {
    final date = DateTime.tryParse(result['ngayThucHien']?.toString() ?? '');
    final dateText = date == null
        ? 'Chưa có lịch'
        : DateFormat('dd/MM/yyyy HH:mm').format(date.toLocal());

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin phiếu',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 14),
          _Row(
            label: 'Mã phiếu',
            value: result['maPhieuXN']?.toString() ?? widget.maPhieuXN,
          ),
          _Row(label: 'Ngày thực hiện', value: dateText),
          _Row(
            label: 'Nhân sự',
            value: result['NhanSuYTe']?['hoTen']?.toString() ?? 'Kỹ thuật viên',
          ),
          _Row(
            label: 'Kết quả',
            value: result['ketQua']?.toString() ?? 'Đang chờ cập nhật',
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              'Lưu ý: Kết quả demo chỉ phục vụ kiểm thử giao diện. Khi kết nối backend thật, dữ liệu sẽ lấy từ hệ thống xét nghiệm.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 118,
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
