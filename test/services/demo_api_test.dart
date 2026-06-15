import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_app_frontend/services/demo_api.dart';

void main() {
  test('returns a doctor demo session for bacsi login', () {
    final response = DemoApi.post('/auth/login', {
      'tenDangNhap': 'bacsi',
      'matKhau': 'demo',
    });

    expect(response.statusCode, 200);
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    expect(body['token'], 'demo-token-bacsi');
    expect(body['user']['maNhom'], 'BACSI');
    expect(body['user']['maBS'], 'BS001');
  });

  test('returns sample departments and doctors without backend', () {
    final khoaResponse = DemoApi.get('/khoa');
    final bacSiResponse = DemoApi.get('/bacsi');

    final khoaBody = jsonDecode(khoaResponse.body) as Map<String, dynamic>;
    final bacSiBody = jsonDecode(bacSiResponse.body) as Map<String, dynamic>;

    expect(khoaBody['data'], isA<List>());
    expect(khoaBody['data'], isNotEmpty);
    expect(bacSiBody['data'], isA<List>());
    expect(bacSiBody['data'], isNotEmpty);
    expect(bacSiBody['data'].first['maBS'], isNotNull);
  });

  test('creates demo appointment and invoice payloads', () {
    final appointmentResponse = DemoApi.post('/lichkham', {
      'maBN': 'BN001',
      'maBS': 'BS001',
      'ngayKham': '2026-06-16',
      'gioKham': '08:30',
    });
    final invoiceResponse = DemoApi.post('/hoadon/giohang/confirm', {
      'maBN': 'BN001',
    });

    final appointmentBody =
        jsonDecode(appointmentResponse.body) as Map<String, dynamic>;
    final invoiceBody =
        jsonDecode(invoiceResponse.body) as Map<String, dynamic>;

    expect(appointmentResponse.statusCode, 201);
    expect(appointmentBody['data']['maLich'], startsWith('LK-DEMO-'));
    expect(appointmentBody['data']['trangThai'], 'CHO_THANH_TOAN');
    expect(invoiceResponse.statusCode, 201);
    expect(invoiceBody['data']['maHD'], 'HD-DEMO');
    expect(invoiceBody['data']['trangThai'], 'CHUA_THANH_TOAN');
  });
}
