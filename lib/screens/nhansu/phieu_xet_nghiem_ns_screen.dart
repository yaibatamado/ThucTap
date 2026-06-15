// lib/screens/nhansu/phieu_xet_nghiem_ns_screen.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../../../auth/auth_provider.dart';
import '../../../services/api_client.dart';
// TH�M: Import cho upload
import 'dart:io';
import 'package:image_picker/image_picker.dart';

// --- MODELS ---
class YeuCauSimple {
  final String maYeuCau;
  final String maBN;
  YeuCauSimple({required this.maYeuCau, required this.maBN});
  factory YeuCauSimple.fromJson(Map<String, dynamic> json) =>
      YeuCauSimple(maYeuCau: json['maYeuCau'], maBN: json['maBN']);
}

class XetNghiemSimple {
  final String maXN;
  final String tenXN;
  XetNghiemSimple({required this.maXN, required this.tenXN});
  factory XetNghiemSimple.fromJson(Map<String, dynamic> json) =>
      XetNghiemSimple(maXN: json['maXN'], tenXN: json['tenXN']);
}

class HSBASimple {
  final String maHSBA;
  final String maBN;
  HSBASimple({required this.maHSBA, required this.maBN});
  factory HSBASimple.fromJson(Map<String, dynamic> json) =>
      HSBASimple(maHSBA: json['maHSBA'], maBN: json['maBN']);
}

class PhieuXNModel {
  final String maPhieuXN;
  final String maYeuCau;
  final String? tenXN;
  final String maHSBA;
  final String ngay;
  final String? ketQua;
  final String? ghiChu;
  final String? tenNguoiNhap;

  PhieuXNModel({
    required this.maPhieuXN,
    required this.maYeuCau,
    this.tenXN,
    required this.maHSBA,
    required this.ngay,
    this.ketQua,
    this.ghiChu,
    this.tenNguoiNhap,
  });

  factory PhieuXNModel.fromJson(Map<String, dynamic> json) {
    String fNgay = json['ngayThucHien'] ?? '';
    try {
      fNgay = DateFormat(
        'yyyy-MM-dd',
      ).format(DateTime.parse(json['ngayThucHien']).toLocal());
    } catch (_) {}

    return PhieuXNModel(
      maPhieuXN: json['maPhieuXN'],
      maYeuCau: json['maYeuCau'],
      tenXN: json['XetNghiem']?['tenXN'] ?? 'N/A',
      maHSBA: json['maHSBA'] ?? 'N/A',
      ngay: fNgay,
      ketQua: json['ketQua'],
      ghiChu: json['ghiChu'],
      tenNguoiNhap: json['NhanSuYTe']?['hoTen'] ?? 'N/A',
    );
  }
}
// --- END MODELS ---

class PhieuXetNghiemNSScreen extends StatefulWidget {
  @override
  _PhieuXetNghiemNSScreenState createState() => _PhieuXetNghiemNSScreenState();
}

class _PhieuXetNghiemNSScreenState extends State<PhieuXetNghiemNSScreen> {
  final ApiClient _api = ApiClient();
  final _formKey = GlobalKey<FormState>();
  final _ketQuaController = TextEditingController();
  final _ghiChuController = TextEditingController();

  List<PhieuXNModel> _list = [];
  List<YeuCauSimple> _dsYeuCau = [];
  List<XetNghiemSimple> _dsXN = [];
  List<HSBASimple> _dsHSBA = [];
  bool _isLoading = true;

  // Form State
  String? _selectedYeuCau;
  String? _selectedXN;
  String? _selectedHSBA;
  DateTime _selectedDate = DateTime.now();

  // TH�M: State v� Controller cho ch?c nang Upload
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  // K?T TH�C TH�M

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    try {
      final responses = await Future.wait([
        _api.get('/phieuxetnghiem'), // List Phi?u d� c�
        _api.get('/yeucauxetnghiem'), // List Y�u c?u
        _api.get('/xetnghiem'), // List X�t nghi?m
        _api.get('/hsba'), // List HSBA
      ]);

      setState(() {
        _list = (jsonDecode(responses[0].body)['data'] as List)
            .map((j) => PhieuXNModel.fromJson(j))
            .toList();
        _dsYeuCau = (jsonDecode(responses[1].body)['data'] as List)
            .map((j) => YeuCauSimple.fromJson(j))
            .toList();
        _dsXN = (jsonDecode(responses[2].body)['data'] as List)
            .map((j) => XetNghiemSimple.fromJson(j))
            .toList();
        _dsHSBA = (jsonDecode(responses[3].body)['data'] as List)
            .map((j) => HSBASimple.fromJson(j))
            .toList();
      });
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

  // TH�M: H�m ch?n ?nh
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }
  // K?T TH�C TH�M

  // S?A: H�M T?O PHI?U HO�N CH?NH (Ghi 1 l?n)
  Future<void> _handleCreatePhieuHoanChinh() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedYeuCau == null ||
        _selectedXN == null ||
        _selectedHSBA == null) {
      _showError("Vui l�ng ch?n d? Y�u c?u, X�t nghi?m v� HSBA.");
      return;
    }

    final payload = {
      'maYeuCau': _selectedYeuCau,
      'maXN': _selectedXN,
      'maHSBA': _selectedHSBA,
      'ngayThucHien': DateFormat('yyyy-MM-dd').format(_selectedDate),
      'ghiChu': _ghiChuController.text,
      'ketQua': _ketQuaController.text,
    };

    setState(() => _isLoading = true);
    final endpoint = '/phieuxetnghiem'; // Endpoint ch�nh

    try {
      dynamic response;
      if (_selectedImage != null) {
        // D�ng MULTIPART
        final Map<String, String> fields = payload.map(
          (k, v) => MapEntry(k, v?.toString() ?? ''),
        );

        response = await _api.postMultipart(
          endpoint,
          fields,
          file: _selectedImage,
          fileFieldName: 'file', // <--- S?A TH�NH 'file'
        );
      } else {
        // D�ng JSON POST
        response = await _api.post(endpoint, payload);
      }

      if (response.statusCode == 201) {
        _showSuccess('? �� luu Phi?u Ho�n Ch?nh (Block) th�nh c�ng!');
        _loadAllData();
        _formKey.currentState?.reset();
        _ketQuaController.clear();
        _ghiChuController.clear();
        setState(() {
          _selectedYeuCau = null;
          _selectedXN = null;
          _selectedHSBA = null;
          _selectedDate = DateTime.now();
          _selectedImage = null; // Reset ?nh
        });
      } else {
        String errorMessage = 'L?i luu phi?u: ${response.statusCode}';
        try {
          final errorBody = jsonDecode(response.body);
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (_) {}
        _showError(errorMessage);
      }
    } catch (e) {
      _showError('L?i k?t n?i: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Phi?u X�t nghi?m (NS)'),
        backgroundColor: Colors.indigo[700], // M�u XN
        actions: [
          IconButton(
            icon: FaIcon(FontAwesomeIcons.house, color: Colors.white, size: 20),
            tooltip: 'Trang ch?',
            onPressed: () => context.go('/xetnghiem'),
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- FORM GHI PHI?U HO�N CH?NH ---
                  Text(
                    '?? Phi?u x�t nghi?m (Nh�n vi�n XN)',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                            // H�ng 1: Dropdowns v� Ng�y
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDropdown(
                                    'Ch?n Y�u c?u',
                                    _dsYeuCau
                                        .map(
                                          (e) => DropdownMenuItem(
                                            value: e.maYeuCau,
                                            child: Text(e.maYeuCau),
                                          ),
                                        )
                                        .toList(),
                                    (v) => setState(() => _selectedYeuCau = v),
                                    _selectedYeuCau,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: _buildDropdown(
                                    'Ch?n X�t nghi?m',
                                    _dsXN
                                        .map(
                                          (e) => DropdownMenuItem(
                                            value: e.maXN,
                                            child: Text(e.tenXN),
                                          ),
                                        )
                                        .toList(),
                                    (v) => setState(() => _selectedXN = v),
                                    _selectedXN,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDropdown(
                                    'Ch?n HSBA',
                                    _dsHSBA
                                        .map(
                                          (e) => DropdownMenuItem(
                                            value: e.maHSBA,
                                            child: Text(e.maHSBA),
                                          ),
                                        )
                                        .toList(),
                                    (v) => setState(() => _selectedHSBA = v),
                                    _selectedHSBA,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(child: _buildDateField(context)),
                              ],
                            ),
                            SizedBox(height: 16),

                            // H�ng 2: K?t qu?
                            TextFormField(
                              controller: _ketQuaController,
                              decoration: InputDecoration(
                                labelText: 'K?t qu? x�t nghi?m',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
                              validator: (v) =>
                                  v!.isEmpty ? 'Vui l�ng nh?p k?t qu?' : null,
                            ),
                            SizedBox(height: 12),

                            // H�ng 3: Ghi ch�
                            TextFormField(
                              controller: _ghiChuController,
                              decoration: InputDecoration(
                                labelText: 'Ghi ch�',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 2,
                            ),

                            // TH�M: V�ng ch?n ?nh
                            SizedBox(height: 16),
                            Text(
                              'H�nh ?nh K?t qu? XN (T�y ch?n):',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _pickImage,
                                    icon: Icon(Icons.photo_library),
                                    label: Text(
                                      _selectedImage == null
                                          ? 'Ch?n ?nh'
                                          : '�?i ?nh',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey[200],
                                      foregroundColor: Colors.black87,
                                    ),
                                  ),
                                ),
                                if (_selectedImage != null) ...[
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            '�� ch?n: ${_selectedImage!.path.split('/').last}',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.close,
                                            color: Colors.red,
                                          ),
                                          onPressed: () => setState(
                                            () => _selectedImage = null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),

                            // K?T TH�C TH�M
                            SizedBox(height: 20),

                            // N�t Luu
                            ElevatedButton.icon(
                              onPressed: _handleCreatePhieuHoanChinh,
                              icon: Icon(Icons.save),
                              label: Text('Luu Phi?u Ho�n Ch?nh (Ghi 1 l?n)'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(double.infinity, 48),
                                backgroundColor: Colors.blue[800],
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),

                  // --- B?NG DANH S�CH PHI?U �� C� ---
                  Text(
                    'L?ch s? Phi?u X�t nghi?m',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  _buildListPhieu(),
                ],
              ),
            ),
    );
  }
  // ... (C�c h�m helper kh�c gi? nguy�n)

  Widget _buildDropdown(
    String label,
    List<DropdownMenuItem<String>> items,
    Function(String?) onChanged,
    String? currentValue,
  ) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      value: currentValue,
      items: items,
      onChanged: onChanged,
      validator: (v) => v == null ? 'Vui l�ng ch?n' : null,
    );
  }

  Widget _buildDateField(BuildContext context) {
    return TextFormField(
      readOnly: true,
      controller: TextEditingController(
        text: DateFormat('dd/MM/yyyy').format(_selectedDate),
      ),
      decoration: InputDecoration(
        labelText: 'Ng�y th?c hi?n',
        border: OutlineInputBorder(),
        suffixIcon: Icon(Icons.calendar_today),
      ),
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (picked != null) setState(() => _selectedDate = picked);
      },
      validator: (v) => v!.isEmpty ? 'B?t bu?c' : null,
    );
  }

  Widget _buildListPhieu() {
    if (_list.isEmpty) {
      return Center(child: Text('Kh�ng c� phi?u x�t nghi?m n�o.'));
    }

    // S? D?NG DATATABLE �? HI?N TH? D? LI?U C� C?U TR�C
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 18,
          dataRowHeight: 50,
          headingRowColor: MaterialStateProperty.all(Colors.indigo[50]),
          columns: [
            DataColumn(label: Text('M�')),
            DataColumn(label: Text('YC')),
            DataColumn(label: Text('X�t nghi?m')),
            DataColumn(label: Text('HSBA')),
            DataColumn(label: Text('Ng�y')),
            DataColumn(label: Text('K?t qu?')),
            DataColumn(label: Text('Ngu?i nh?p')),
            DataColumn(label: Text('Xo�')),
          ],
          rows: _list
              .map(
                (phieu) => DataRow(
                  cells: [
                    DataCell(Text(phieu.maPhieuXN.substring(0, 7))),
                    DataCell(Text(phieu.maYeuCau.substring(0, 7))),
                    DataCell(Text(phieu.tenXN ?? '-')),
                    DataCell(Text(phieu.maHSBA)),
                    DataCell(Text(phieu.ngay)),
                    DataCell(Text(phieu.ketQua ?? '-')),
                    DataCell(Text(phieu.tenNguoiNhap ?? '-')),
                    DataCell(
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () {
                          // Kh�ng th? x�a phi?u d� ghi v�o Blockchain!
                        },
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
