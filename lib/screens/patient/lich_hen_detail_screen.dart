import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_provider.dart';
import '../../services/api_client.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_components.dart';

class LichHenDetailScreen extends StatefulWidget {
  const LichHenDetailScreen({super.key, required this.maLich});

  final String maLich;

  @override
  State<LichHenDetailScreen> createState() => _LichHenDetailScreenState();
}

class _LichHenDetailScreenState extends State<LichHenDetailScreen> {
  final _api = ApiClient();
  Map<String, dynamic>? _appointment;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final maBN = context.read<AuthProvider>().maBN ?? 'BN001';

    try {
      final response = await _api.get('/lichkham/benhnhan/$maBN');
      final data = jsonDecode(response.body)['data'] as List;
      final item = data.cast<Map<String, dynamic>>().firstWhere(
        (row) => row['maLich']?.toString() == widget.maLich,
        orElse: () => data.isNotEmpty ? data.first : <String, dynamic>{},
      );

      if (!mounted) return;
      setState(() => _appointment = item);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appointment = _appointment;

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết lịch hẹn')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : appointment == null || appointment.isEmpty
          ? _buildMissing()
          : ListView(
              padding: const EdgeInsets.all(18),
              children: [
                _buildHeader(appointment),
                const SizedBox(height: 16),
                _buildDetails(appointment),
                const SizedBox(height: 16),
                _buildActions(appointment),
              ],
            ),
    );
  }

  Widget _buildMissing() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: AppCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.event_busy_rounded, size: 48),
              const SizedBox(height: 12),
              Text(
                'Không tìm thấy lịch hẹn',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => context.go('/patient/lich'),
                child: const Text('Quay lại lịch hẹn'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> item) {
    final status = item['trangThai']?.toString() ?? 'CHO_THANH_TOAN';
    final isPaid = status == 'DA_THANH_TOAN' || status == 'Đã xác nhận';

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: (isPaid ? AppTheme.teal : Colors.orange).withValues(
                    alpha: 0.12,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  isPaid ? Icons.verified_rounded : Icons.schedule_rounded,
                  color: isPaid ? AppTheme.teal : Colors.orange,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.maLich,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isPaid
                          ? 'Lịch hẹn đã được xác nhận'
                          : 'Đang chờ thanh toán đặt chỗ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetails(Map<String, dynamic> item) {
    final ngayKham = DateTime.tryParse(item['ngayKham']?.toString() ?? '');
    final ngayText = ngayKham == null
        ? 'Chưa rõ'
        : DateFormat('dd/MM/yyyy').format(ngayKham);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Thông tin khám', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          _DetailRow(
            label: 'Bác sĩ',
            value: item['BacSi']?['hoTen']?.toString() ?? 'Bác sĩ phụ trách',
          ),
          _DetailRow(
            label: 'Thời gian',
            value: '${item['gioKham'] ?? '--:--'} - $ngayText',
          ),
          _DetailRow(
            label: 'Phòng khám',
            value: item['phong']?.toString() ?? 'P.201',
          ),
          _DetailRow(
            label: 'Lý do khám',
            value: item['ghiChu']?.toString() ?? 'Khám tổng quát',
          ),
          _DetailRow(
            label: 'Mã bệnh nhân',
            value: item['maBN']?.toString() ?? 'BN001',
          ),
        ],
      ),
    );
  }

  Widget _buildActions(Map<String, dynamic> item) {
    final status = item['trangThai']?.toString() ?? 'CHO_THANH_TOAN';
    final isPendingPayment = status == 'CHO_THANH_TOAN';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isPendingPayment)
          ElevatedButton.icon(
            onPressed: () => context.go('/patient/payment/qr/${widget.maLich}'),
            icon: const Icon(Icons.qr_code_2_rounded),
            label: const Text('Thanh toán QR'),
          ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => context.go('/patient/lich'),
          icon: const Icon(Icons.arrow_back_rounded),
          label: const Text('Quay lại danh sách'),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

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
            width: 110,
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
