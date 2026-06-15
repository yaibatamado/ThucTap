// lib/screens/patient/ho_so_benh_an_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_client.dart';

// === BẮT ĐẦU CÁC MODELS ===

// 1. Model cho Khối (Block)
class BlockModel {
  final int id;
  final String blockType;
  final dynamic data;
  final String timestamp;
  final String currentHash;
  final String previousHash;
  final String maHSBA;

  BlockModel({
    required this.id,
    required this.blockType,
    required this.data,
    required this.timestamp,
    required this.currentHash,
    required this.previousHash,
    required this.maHSBA,
  });

  factory BlockModel.fromJson(Map<String, dynamic> json) {
    String fNgay = json['timestamp'] ?? '';
    try {
      fNgay = DateFormat(
        'dd/MM/yyyy HH:mm:ss',
      ).format(DateTime.parse(json['timestamp']).toLocal());
    } catch (_) {}

    return BlockModel(
      id: json['id'],
      blockType: json['block_type'],
      data: jsonDecode(json['data_json']),
      timestamp: fNgay,
      currentHash: json['current_hash'],
      previousHash: json['previous_hash'],
      maHSBA: json['maHSBA'],
    );
  }
}

// 2. Model cho Thông tin chung (vẫn cần)
class HoSoSimple {
  final String maHSBA;
  final String dotKhamBenh;
  HoSoSimple({required this.maHSBA, required this.dotKhamBenh});
  factory HoSoSimple.fromJson(Map<String, dynamic> json) {
    String fDotKham = json['dotKhamBenh'] ?? '';
    try {
      fDotKham = DateFormat(
        'dd/MM/yyyy',
      ).format(DateTime.parse(json['dotKhamBenh']));
    } catch (_) {}
    return HoSoSimple(maHSBA: json['maHSBA'] ?? 'N/A', dotKhamBenh: fDotKham);
  }
}
// --- KẾT THÚC CÁC MODELS ---

// --- BẮT ĐẦU WIDGET MÀN HÌNH CHI TIẾT ---
class HoSoBenhAnDetailScreen extends StatefulWidget {
  final String maHSBA; // Nhận mã HSBA từ router

  // SỬA: Thêm Base URL để hiển thị ảnh
  static const String _fileBaseUrl =
      'http://10.0.2.2:4000'; // Match with ApiClient base URL (without /api)

  HoSoBenhAnDetailScreen({required this.maHSBA});

  @override
  _HoSoBenhAnDetailScreenState createState() => _HoSoBenhAnDetailScreenState();
}

class _HoSoBenhAnDetailScreenState extends State<HoSoBenhAnDetailScreen> {
  final ApiClient _api = ApiClient();
  List<BlockModel> _chain = []; // Danh sách các khối
  HoSoSimple? _hoSo;
  bool _isLoading = true;

  List _bacSiList = [];
  List _nhanSuList = [];

  // State cho việc xác thực
  bool _isVerifying = false;
  String? _verifyMessage;
  bool _isChainValid = true;
  String _selectedDate = ""; // State cho ngày lọc VÀ kiểm tra

  @override
  void initState() {
    super.initState();
    _fetchDetailData();
  }

  // API mới: Lấy dữ liệu chuỗi khối
  Future<void> _fetchDetailData() async {
    setState(() {
      _isLoading = true;
      _verifyMessage = null;
      _isChainValid = true;
    });
    try {
      final responses = await Future.wait([
        _api.get('/hsba/chitiet/${widget.maHSBA}'), // Chi tiết chuỗi
        _api.get('/bacsi'), // Danh sách Bác sĩ
        _api.get('/nhansu'), // Danh sách Nhân sự
      ]);

      // Xử lý chuỗi
      if (responses[0].statusCode == 200) {
        final data = jsonDecode(responses[0].body)['data'];
        final hoSoData = data['hoSo'];
        final chainData = data['chain'] as List;
        setState(() {
          _hoSo = HoSoSimple.fromJson(hoSoData);
          _chain = chainData.map((json) => BlockModel.fromJson(json)).toList();
        });
      } else {
        _showError(
          "Lỗi tải chi tiết: ${jsonDecode(responses[0].body)['message']}",
        );
      }

      // Xử lý Bác sĩ
      if (responses[1].statusCode == 200) {
        setState(() {
          _bacSiList = jsonDecode(responses[1].body)['data'] as List;
        });
      }

      // Xử lý Nhân sự
      if (responses[2].statusCode == 200) {
        setState(() {
          _nhanSuList = jsonDecode(responses[2].body)['data'] as List;
        });
      }
    } catch (e) {
      _showError('Lỗi kết nối: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // API Demo B: Gọi API để xác thực chuỗi
  Future<void> _verifyChain() async {
    final dateToVerify = _selectedDate.isEmpty
        ? DateFormat('yyyy-MM-dd').format(DateTime.now())
        : _selectedDate;

    if (_selectedDate.isEmpty) {
      setState(() => _selectedDate = dateToVerify);
    }

    setState(() {
      _isVerifying = true;
      _verifyMessage = null;
    });

    try {
      final response = await _api.get(
        '/hsba/verify/${widget.maHSBA}?ngay=$dateToVerify',
      );
      final body = jsonDecode(response.body);

      setState(() {
        _isChainValid = true;
        _verifyMessage = body['message'];
      });
    } catch (e) {
      setState(() {
        _isChainValid = false;
        try {
          final errorBody = jsonDecode(e.toString().split('body: ')[1]);
          _verifyMessage = errorBody['message'] ?? 'Lỗi không xác định';
        } catch (_) {
          _verifyMessage = 'Lỗi kết nối: $e';
        }
      });
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // THÊM: Widget hiển thị File đính kèm (Hình ảnh)
  Widget _buildFileWidget(dynamic data, String label) {
    // Trường 'file' được lưu trong data của block
    final filePath = data['file'];
    if (filePath == null || filePath.isEmpty) {
      return SizedBox.shrink();
    }

    // Xây dựng URL đầy đủ
    final fullUrl = '${HoSoBenhAnDetailScreen._fileBaseUrl}$filePath';

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
          SizedBox(height: 4),
          // Sử dụng Image.network để hiển thị ảnh từ URL
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              fullUrl,
              fit: BoxFit.cover,
              width: 150, // Giới hạn chiều rộng
              height: 150, // Giới hạn chiều cao
              loadingBuilder:
                  (
                    BuildContext context,
                    Widget child,
                    ImageChunkEvent? loadingProgress,
                  ) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
              errorBuilder: (context, error, stackTrace) => Container(
                width: 150,
                height: 150,
                color: Colors.grey[200],
                child: Center(
                  child: Text(
                    'Lỗi tải ảnh',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Logic lọc chuỗi
    final filteredChain = _chain.where((block) {
      if (_selectedDate.isEmpty) {
        return true; // Hiển thị tất cả nếu không chọn ngày
      }
      try {
        final blockDate = DateFormat(
          'yyyy-MM-dd',
        ).format(DateFormat('dd/MM/yyyy HH:mm:ss').parse(block.timestamp));
        return blockDate == _selectedDate;
      } catch (e) {
        return false;
      }
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Hồ sơ Blockchain'),
        backgroundColor: Color(0xFF15803D),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.go('/patient/hoso'),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchDetailData,
              child: ListView(
                padding: EdgeInsets.all(16),
                children: [
                  Text(
                    'Hồ sơ: ${widget.maHSBA}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  SizedBox(height: 16),

                  _buildVerifyAndFilterCard(),

                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                    child: Text(
                      'Lịch sử sự kiện (Chuỗi khối)',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  // Dùng filteredChain
                  if (filteredChain.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          _selectedDate.isEmpty
                              ? 'Không có sự kiện y tế nào.'
                              : 'Không có sự kiện nào vào ngày ${DateFormat('dd/MM/yyyy').format(DateTime.parse(_selectedDate))}',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    )
                  else
                    ...filteredChain
                        .map(
                          (block) =>
                              _buildBlockWidget(block, _bacSiList, _nhanSuList),
                        )
                        .toList(),
                ],
              ),
            ),
    );
  }

  // Thẻ Lọc/Kiểm tra
  Widget _buildVerifyAndFilterCard() {
    Color cardColor = _isChainValid ? Colors.green[50]! : Colors.red[50]!;
    Color borderColor = _isChainValid ? Colors.green[200]! : Colors.red[200]!;
    Color iconColor = _isChainValid ? Colors.green[700]! : Colors.red[700]!;
    IconData icon = _isChainValid
        ? Icons.check_circle
        : Icons.warning_amber_rounded;

    return Card(
      elevation: 2,
      color: _isChainValid
          ? Colors.white
          : cardColor, // Chỉ đổi màu nền khi có lỗi
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: _isChainValid ? Colors.grey[300]! : borderColor,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Chọn ngày (để lọc và kiểm tra):",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'dd/mm/yyyy',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              controller: TextEditingController(
                text: _selectedDate.isEmpty
                    ? ''
                    : DateFormat(
                        'dd/MM/yyyy',
                      ).format(DateTime.parse(_selectedDate)),
              ),
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate.isEmpty
                      ? DateTime.now()
                      : DateTime.parse(_selectedDate),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  setState(() {
                    _selectedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                    _verifyMessage = null; // Reset khi đổi ngày
                    _isChainValid = true;
                  });
                }
              },
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isVerifying ? null : _verifyChain,
                    icon: _isVerifying
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : FaIcon(FontAwesomeIcons.shieldHalved, size: 16),
                    label: Text(
                      _isVerifying ? 'Đang kiểm tra...' : 'Kiểm tra ngày',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() {
                      _selectedDate = "";
                      _verifyMessage = null;
                      _isChainValid = true;
                    }),
                    child: Text('Hiển thị tất cả'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            if (_verifyMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, color: iconColor, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _verifyMessage!,
                        style: TextStyle(
                          color: iconColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Helper tìm tên
  String _getBacSiName(String maBS, List bacSiList) {
    try {
      final bacSi = bacSiList.firstWhere((bs) => bs['maBS'] == maBS);
      return bacSi['hoTen'] ?? maBS;
    } catch (e) {
      return maBS; // Trả về ID nếu không tìm thấy
    }
  }

  String _getNhanSuName(String maNS, List nhanSuList) {
    try {
      // Bỏ qua 'SYSTEM'
      if (maNS == 'SYSTEM') return 'Hệ thống tự động';
      final nhanSu = nhanSuList.firstWhere((ns) => ns['maNS'] == maNS);
      return nhanSu['hoTen'] ?? maNS;
    } catch (e) {
      return maNS; // Trả về ID nếu không tìm thấy
    }
  }

  // Widget chung để hiển thị một khối
  Widget _buildBlockWidget(BlockModel block, List bacSiList, List nhanSuList) {
    Widget content;
    FaIconData iconData;
    Color color;
    String title;

    switch (block.blockType) {
      case 'PHIEU_KHAM':
        iconData = FontAwesomeIcons.fileMedical;
        color = Colors.blue;
        title = 'Phiếu Khám'; // Gán title
        content = _buildPhieuKhamContent(block.data, bacSiList);
        break;

      case 'DON_THUOC_HOAN_CHINH':
        iconData = FontAwesomeIcons.pills;
        color = Colors.purple;
        title = 'Đơn Thuốc'; // Gán title
        content = _buildDonThuocHoanChinhContent(block.data, bacSiList);
        break;

      case 'XET_NGHIEM_HOAN_CHINH':
      case 'KET_QUA_XET_NGHIEM':
      case 'PHIEU_XET_NGHIEM':
        iconData = FontAwesomeIcons.flaskVial;
        color = Colors.orange;
        title = 'Xét Nghiệm'; // Gán title
        content = _buildXetNghiemContent(block.data, nhanSuList);
        break;

      case 'YEU_CAU_XET_NGHIEM': // Ẩn
        return SizedBox.shrink();

      case 'TAO_MOI':
        iconData = FontAwesomeIcons.solidUser;
        color = Colors.green;
        title = 'Tạo Hồ Sơ'; // Gán title
        content = _buildTaoMoiContent(block.data);
        break;
      default:
        return SizedBox.shrink(); // Ẩn các loại không xác định
    }

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        // === SỬA LỖI: Thêm `mainAxisSize: MainAxisSize.min` vào Column ===
        child: Column(
          mainAxisSize: MainAxisSize.min, // <-- SỬA Ở ĐÂY
          crossAxisAlignment: CrossAxisAlignment.start,
          // === KẾT THÚC SỬA LỖI ===
          children: [
            Row(
              children: [
                FaIcon(iconData, color: color, size: 20),
                SizedBox(width: 10),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Spacer(),
                Text(
                  block.timestamp,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),

            SizedBox(height: 16), // Giữ lại SizedBox (đã xóa Divider)

            content,
          ],
        ),
      ),
    );
  }

  // Widget con cho "TAO_MOI"
  Widget _buildTaoMoiContent(dynamic data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Mã Bệnh nhân:', data['maBN'] ?? 'N/A'),
        _buildInfoRow(
          'Ngày lập:',
          DateFormat('dd/MM/yyyy').format(DateTime.parse(data['ngayLap'])),
        ),
        _buildInfoRow('Lịch sử bệnh:', data['lichSuBenh'] ?? 'Không có'),
      ],
    );
  }

  // Cập nhật PhieuKhamContent
  Widget _buildPhieuKhamContent(dynamic data, List bacSiList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Mã Phiếu Khám:', data['maPK'] ?? 'N/A'),
        _buildInfoRow(
          'Bác sĩ:',
          _getBacSiName(data['maBS'] ?? 'N/A', bacSiList),
        ),
        _buildInfoRow('Triệu chứng:', data['trieuChung'] ?? 'Không có'),
        _buildInfoRow('Chẩn đoán:', data['chuanDoan'] ?? 'Không có'),
        _buildInfoRow('Lời dặn:', data['loiDan'] ?? 'Không có'),
        // THÊM: Hiển thị file đính kèm
        _buildFileWidget(data, 'Ảnh Phiếu Khám:'),
      ],
    );
  }

  // Cập nhật DonThuocHoanChinhContent
  Widget _buildDonThuocHoanChinhContent(dynamic data, List bacSiList) {
    final chiTietList = (data['chiTietList'] as List? ?? []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Mã Đơn Thuốc:', data['maDT'] ?? 'N/A'),
        _buildInfoRow('Gắn với Phiếu Khám:', data['maPK'] ?? 'N/A'),
        _buildInfoRow(
          'Bác sĩ:',
          _getBacSiName(data['maBS'] ?? 'N/A', bacSiList),
        ),
        SizedBox(height: 8),
        Text('Chi tiết thuốc:', style: TextStyle(fontWeight: FontWeight.bold)),
        // Bảng chi tiết
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 16.0,
            horizontalMargin: 0,
            columns: [
              DataColumn(
                label: Text(
                  'Mã Thuốc',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Tên Thuốc',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'SL',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Liều dùng',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
            rows: chiTietList
                .map(
                  (item) => DataRow(
                    cells: [
                      DataCell(Text(item['maThuoc'] ?? 'N/A')),
                      DataCell(Text(item['tenThuoc'] ?? '(Không tên)')),
                      DataCell(Text(item['soLuong']?.toString() ?? 'N/A')),
                      DataCell(Text(item['lieuDung'] ?? 'N/A')),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
        // THÊM: Hiển thị file đính kèm
        _buildFileWidget(data, 'Ảnh Đơn Thuốc:'),
      ],
    );
  }

  // Cập nhật XetNghiemContent
  Widget _buildXetNghiemContent(dynamic data, List nhanSuList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Mã Phiếu XN:', data['maPhieuXN'] ?? 'N/A'),
        _buildInfoRow('Mã Yêu Cầu:', data['maYeuCau'] ?? 'N/A'),
        _buildInfoRow('Mã Xét Nghiệm:', data['maXN'] ?? 'N/A'),
        _buildInfoRow(
          'Nhân viên:',
          _getNhanSuName(data['maNS'] ?? 'N/A', nhanSuList),
        ),
        _buildInfoRow('Kết quả:', data['ketQua'] ?? 'Đang chờ...'),
        _buildInfoRow('Ghi chú:', data['ghiChu'] ?? 'Không có'),
        // THÊM: Hiển thị file đính kèm
        _buildFileWidget(data, 'Ảnh Kết Quả XN:'),
      ],
    );
  }

  // Helper build row thông tin
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: Colors.black, fontSize: 14),
          children: [
            TextSpan(
              text: '$label ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
