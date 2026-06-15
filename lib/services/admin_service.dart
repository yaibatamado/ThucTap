import 'dart:convert';
import 'package:http/http.dart';
import '../models/user_model.dart';
import 'api_client.dart';

final ApiClient _api = ApiClient();

// --- TÀI KHOẢN ---

// Tái tạo logic từ AdminUserList.jsx
Future<List<UserModel>> getAllUsers() async {
  try {
    final response = await _api.get('/tai-khoan');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Backend trả về { data: [...] }
      final List rawList = data['data'] ?? [];

      return rawList.map((json) => UserModel.fromJson(json)).toList();
    }
    return [];
  } catch (e) {
    print('❌ Lỗi tải danh sách người dùng: $e');
    return [];
  }
}

// Tái tạo logic từ CreateUserForm.jsx
Future<bool> createUpdateUser(
  Map<String, dynamic> payload, {
  String? maTK,
}) async {
  try {
    Response response;
    if (maTK != null) {
      // Update
      response = await _api.put('/tai-khoan/$maTK', payload);
    } else {
      // Create
      response = await _api.post('/tai-khoan', payload);
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      final errorBody = jsonDecode(response.body);
      print('❌ Lỗi API: ${errorBody['message']}');
      return false;
    }
  } catch (e) {
    print('❌ Lỗi kết nối/xử lý: $e');
    return false;
  }
}

// --- KHOA PHÒNG ---

// Tái tạo logic từ ManageKhoa.jsx
Future<List<Map<String, dynamic>>> getAllDepartments() async {
  try {
    final response = await _api.get('/khoa');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['data'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  } catch (e) {
    print('❌ Lỗi tải khoa: $e');
    return [];
  }
}
