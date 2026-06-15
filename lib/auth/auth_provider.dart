import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_client.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  String? _role;
  String? _maTK;
  String? _tenDangNhap;
  String? _maBN;
  String? _maBS;
  String? _loaiNS;
  bool _isLoading = true;

  String? get token => _token;
  String? get role => _role;
  String? get maTK => _maTK;
  String? get tenDangNhap => _tenDangNhap;
  String? get maBN => _maBN;
  String? get maBS => _maBS;
  String? get loaiNS => _loaiNS;
  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _loadAuthData();
  }

  Future<void> _loadAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _role = prefs.getString('role');
    _maTK = prefs.getString('maTK');
    _tenDangNhap = prefs.getString('tenDangNhap');
    _maBN = prefs.getString('maBN');
    _maBS = prefs.getString('maBS');
    _loaiNS = prefs.getString('loaiNS');
    _isLoading = false;
    notifyListeners();
  }

  Future<void> login(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();

    // Giả định userData đã bao gồm token và user info từ API
    _token = userData['token'];
    final user = userData['user'] as Map<String, dynamic>;

    // Cập nhật các trường chính
    _role = user['maNhom'];
    _maTK = user['maTK'];
    _tenDangNhap = user['tenDangNhap'];

    // Cập nhật các trường phụ (Có thể null)
    _maBN = user['maBN'];
    _maBS = user['maBS'];
    _loaiNS = user['loaiNS'];

    // Lưu vào SharedPreferences và ApiClient
    await prefs.setString('token', _token!);
    await prefs.setString('role', _role!);
    await prefs.setString('maTK', _maTK!);
    if (_tenDangNhap != null) {
      await prefs.setString('tenDangNhap', _tenDangNhap!);
    }
    if (_maBN != null) await prefs.setString('maBN', _maBN!);
    if (_maBS != null) await prefs.setString('maBS', _maBS!);
    if (_loaiNS != null) await prefs.setString('loaiNS', _loaiNS!);

    await ApiClient().setToken(_token);

    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await ApiClient().setToken(null);
    _token = null;
    _role = null;
    _maTK = null;
    _tenDangNhap = null;
    _maBN = null;
    _maBS = null;
    _loaiNS = null;
    notifyListeners();
  }
}
