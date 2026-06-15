import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

import 'demo_api.dart';

// Default true so the app can be reviewed without a backend.
// Run with --dart-define=DEMO_MODE=false to use the real API.
const bool kDemoMode = bool.fromEnvironment('DEMO_MODE', defaultValue: true);
const String _baseUrl = 'http://10.0.2.2:4000/api';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  String? _token;

  Future<void> setToken(String? token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    if (token != null) {
      await prefs.setString('token', token);
    } else {
      await prefs.remove('token');
    }
  }

  Future<String?> getToken() async {
    if (_token == null) {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');
    }
    return _token;
  }

  Future<Map<String, String>> _getHeaders({bool isMultipart = false}) async {
    final token = await getToken();
    final Map<String, String> headers = {};

    if (!isMultipart) {
      headers['Content-Type'] = 'application/json';
    }
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<http.Response> post(String path, dynamic body) async {
    if (kDemoMode) return DemoApi.post(path, body);

    final headers = await _getHeaders();
    final url = Uri.parse('$_baseUrl$path');
    return http.post(url, headers: headers, body: jsonEncode(body));
  }

  Future<http.Response> postMultipart(
    String path,
    Map<String, String> fields, {
    File? file,
    String? fileFieldName = 'hinhAnh',
  }) async {
    if (kDemoMode) return DemoApi.post(path, fields);

    final url = Uri.parse('$_baseUrl$path');
    final request = http.MultipartRequest('POST', url);

    request.headers.addAll(await _getHeaders(isMultipart: true));
    request.fields.addAll(fields);

    if (file != null && await file.exists()) {
      request.files.add(
        await http.MultipartFile.fromPath(fileFieldName!, file.path),
      );
    }

    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  Future<http.Response> get(String path) async {
    if (kDemoMode) return DemoApi.get(path);

    final headers = await _getHeaders();
    final url = Uri.parse('$_baseUrl$path');
    return http.get(url, headers: headers);
  }

  Future<http.Response> put(String path, dynamic body) async {
    if (kDemoMode) return DemoApi.put(path, body);

    final headers = await _getHeaders();
    final url = Uri.parse('$_baseUrl$path');
    return http.put(url, headers: headers, body: jsonEncode(body));
  }

  Future<http.Response> delete(String path, {dynamic body}) async {
    if (kDemoMode) return DemoApi.delete(path, body: body);

    final headers = await _getHeaders();
    final url = Uri.parse('$_baseUrl$path');
    if (body != null) {
      return http.delete(url, headers: headers, body: jsonEncode(body));
    }
    return http.delete(url, headers: headers);
  }
}
