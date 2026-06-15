import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import '../../services/api_client.dart';
import '../../auth/auth_provider.dart';

// (Models)
class YeuCauXN {
  final String maYeuCau;
  final String maBN;
  final String? tenBN; // Th�m t�n b?nh nh�n
  final String? tenBS;
  final String loaiYeuCau;
  final String trangThai;
  final String ngayYeuCau;

  YeuCauXN({
    required this.maYeuCau,
    required this.maBN,
    this.tenBN,
    this.tenBS,
    required this.loaiYeuCau,
    required this.trangThai,
    required this.ngayYeuCau,
  });

  factory YeuCauXN.fromJson(Map<String, dynamic> json) {
    String fNgay = json['ngayYeuCau'] ?? '';
    try {
      fNgay = DateFormat(
        'dd/MM/yyyy',
      ).format(DateTime.parse(json['ngayYeuCau']).toLocal());
    } catch (_) {}
    return YeuCauXN(
      maYeuCau: json['maYeuCau'],
      maBN: json['maBN'],
      tenBN: json['BenhNhan']?['hoTen'] ?? json['maBN'], // L?y t�n BN
      tenBS: json['BacSi']?['hoTen'] ?? 'N/A',
      loaiYeuCau: json['loaiYeuCau'] ?? 'THONG_THUONG',
      trangThai: json['trangThai'] ?? 'CHO_THUC_HIEN',
      ngayYeuCau: fNgay,
    );
  }
}

// Model don gi?n cho Dropdown
class BenhNhanSimple {
  final String maBN;
  final String hoTen;
  BenhNhanSimple({required this.maBN, required this.hoTen});
  factory BenhNhanSimple.fromJson(Map<String, dynamic> json) =>
      BenhNhanSimple(maBN: json['maBN'], hoTen: json['hoTen'] ?? json['maBN']);
}

class YeuCauXNBSScreen extends StatefulWidget {
  @override
  _YeuCauXNBSScreenState createState() => _YeuCauXNBSScreenState();
}

class _YeuCauXNBSScreenState extends State<YeuCauXNBSScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiClient _api = ApiClient();

  // Data State
  List<YeuCauXN> _list = [];
  List<BenhNhanSimple> _dsBenhNhan = [];

  // UI State
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _maBS;

  // Form State
  String? _selectedMaBN;
  String? _selectedLoaiYeuCau = 'THONG_THUONG';

  final List<Map<String, String>> _loaiYeuCauOptions = const [
    {'value': 'THONG_THUONG', 'label': 'Th�ng thu?ng'},
    {'value': 'KHAN_CAP', 'label': 'Kh?n c?p'},
    {'value': 'THEO_DOI', 'label': 'Theo d�i'},
  ];

  @override
  void initState() {
    super.initState();
    _maBS = Provider.of<AuthProvider>(context, listen: false).maBS;
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    try {
      final responses = await Future.wait([
        _api.get('/yeucauxetnghiem'), // List YC (c?n l?c)
        _api.get('/benhnhan'), // List B?nh nh�n (cho form)
      ]);

      // 1. L?y danh s�ch Y�u c?u (l?c theo maBS)
      if (responses[0].statusCode == 200) {
        final data = jsonDecode(responses[0].body)['data'] as List;
        final filteredList = data
            .map((json) => YeuCauXN.fromJson(json))
            .where(
              (item) =>
                  data.firstWhere(
                    (j) => j['maYeuCau'] == item.maYeuCau,
                  )['maBS'] ==
                  _maBS,
            )
            .toList();
        _list = filteredList;
      }

      // 2. L?y danh s�ch B?nh nh�n
      if (responses[1].statusCode == 200) {
        final data = jsonDecode(responses[1].body)['data'] as List;
        _dsBenhNhan = data
            .map((json) => BenhNhanSimple.fromJson(json))
            .toList();
      }
    } catch (e) {
      _showError('L?i t?i d? li?u: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  String _displayTrangThai(String trangThai) {
    switch (trangThai) {
      case 'CHO_THUC_HIEN':
        return 'Ch? th?c hi?n';
      case 'DA_LAY_MAU':
        return '�� l?y m?u';
      case 'DA_HOAN_THANH':
        return '�� ho�n th�nh';
      default:
        return trangThai;
    }
  }

  // --- H�M T?O Y�U C?U XN (Ghi v�o Blockchain) ---
  Future<void> _handleCreateYeuCau() async {
    if (!_formKey.currentState!.validate() || _maBS == null) return;
    setState(() => _isSubmitting = true);

    final payload = {
      'maBN': _selectedMaBN,
      'loaiYeuCau': _selectedLoaiYeuCau,
      'trangThai': 'CHO_THUC_HIEN', // Lu�n kh?i t?o
      // maBS du?c l?y t? token ? backend
    };

    try {
      // API: POST /api/yeucauxetnghiem (�� s?a d? t?o Block)
      final response = await _api.post('/yeucauxetnghiem', payload);

      if (response.statusCode == 201) {
        _showSuccess('? T?o y�u c?u (Block) th�nh c�ng!');
        _loadAllData();
        _formKey.currentState?.reset();
        setState(() {
          _selectedMaBN = null;
          _selectedLoaiYeuCau = 'THONG_THUONG';
        });
      } else {
        _showError(jsonDecode(response.body)['message'] ?? 'L?i t?o y�u c?u.');
      }
    } catch (e) {
      _showError('L?i k?t n?i: $e');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Y�u c?u x�t nghi?m'),
        backgroundColor: Color(0xFF004D40), // M�u B�c si
        actions: [
          IconButton(
            icon: FaIcon(FontAwesomeIcons.house, color: Colors.white, size: 20),
            tooltip: 'Trang ch?',
            onPressed: () => context.go('/doctor'),
          ),
          IconButton(
            icon: FaIcon(
              FontAwesomeIcons.rightFromBracket,
              color: Colors.white,
              size: 20,
            ),
            tooltip: '�ang xu?t',
            onPressed: () async {
              await Provider.of<AuthProvider>(context, listen: false).logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAllData,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- FORM T?O Y�U C?U ---
              Text(
                '? T?o Y�u c?u X�t nghi?m',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // 1. Ch?n B?nh nh�n
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Ch?n B?nh nh�n',
                            border: OutlineInputBorder(),
                          ),
                          value: _selectedMaBN,
                          items: _dsBenhNhan
                              .map(
                                (bn) => DropdownMenuItem(
                                  value: bn.maBN,
                                  child: Text('${bn.hoTen} (${bn.maBN})'),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => _selectedMaBN = v),
                          validator: (v) =>
                              v == null ? 'Vui l�ng ch?n b?nh nh�n' : null,
                        ),
                        SizedBox(height: 16),
                        // 2. Lo?i Y�u c?u
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Lo?i Y�u c?u',
                            border: OutlineInputBorder(),
                          ),
                          value: _selectedLoaiYeuCau,
                          items: _loaiYeuCauOptions
                              .map(
                                (opt) => DropdownMenuItem(
                                  value: opt['value'],
                                  child: Text(opt['label']!),
                                ),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedLoaiYeuCau = v),
                          validator: (v) =>
                              v == null ? 'Vui l�ng ch?n lo?i y�u c?u' : null,
                        ),
                        SizedBox(height: 20),
                        // N�t
                        ElevatedButton.icon(
                          onPressed: _isSubmitting ? null : _handleCreateYeuCau,
                          icon: _isSubmitting
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : FaIcon(FontAwesomeIcons.vial, size: 18),
                          label: Text(
                            _isSubmitting
                                ? '�ang t?o...'
                                : 'T?o Y�u c?u (Ghi Blockchain)',
                          ),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 44),
                            backgroundColor: Colors.blue[700],
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 30),

              // --- DANH S�CH Y�U C?U �� G?I ---
              Text(
                '?? L?ch s? Y�u c?u c?a t�i',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),

              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _list.isEmpty
                  ? Center(child: Text('Chua c� y�u c?u n�o du?c t?o.'))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _list.length,
                      itemBuilder: (context, index) {
                        final item = _list[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 10),
                          elevation: 2,
                          child: ListTile(
                            leading: FaIcon(
                              FontAwesomeIcons.flask,
                              color: item.trangThai == 'DA_HOAN_THANH'
                                  ? Colors.green[700]
                                  : Colors.orange[700],
                            ),
                            title: Text(
                              'YC: ${item.maYeuCau} - BN: ${item.tenBN ?? item.maBN}',
                            ),
                            subtitle: Text(
                              'Lo?i: ${item.loaiYeuCau} - Ng�y: ${item.ngayYeuCau}',
                            ),
                            trailing: Chip(
                              label: Text(
                                _displayTrangThai(item.trangThai),
                                style: TextStyle(fontSize: 12),
                              ),
                              backgroundColor: item.trangThai == 'DA_HOAN_THANH'
                                  ? Colors.green[100]
                                  : Colors.orange[100],
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
