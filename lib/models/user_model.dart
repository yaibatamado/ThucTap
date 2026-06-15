// lib/models/user_model.dart
import 'package:flutter/foundation.dart';

class UserModel {
  final String maTK;
  final String tenDangNhap;
  final String? email;
  final String maNhom;
  final bool trangThai; // Backend gửi 'true' hoặc '1'

  // Thông tin chung
  final String? hoTen;
  final String? maKhoa;
  final String? tenKhoa;
  final String? chuyenMon;

  // Bác sĩ
  final String? maBS;
  final String? chucVu;
  final String? trinhDo;

  // Nhân sự
  final String? maNS;
  final String? loaiNS;
  final String? capBac;

  // Bệnh nhân
  final String? maBN;
  final String? gioiTinh;
  final String? ngaySinh;
  final String? soDienThoai;
  final String? bhyt;
  final String? diaChi;

  UserModel({
    required this.maTK,
    required this.tenDangNhap,
    this.email,
    required this.maNhom,
    required this.trangThai,
    this.hoTen,
    this.maKhoa,
    this.tenKhoa,
    this.chuyenMon,
    this.maBS,
    this.chucVu,
    this.trinhDo,
    this.maNS,
    this.loaiNS,
    this.capBac,
    this.maBN,
    this.gioiTinh,
    this.ngaySinh,
    this.soDienThoai,
    this.bhyt,
    this.diaChi,
  });

  // Factory constructor để parse JSON từ API
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Backend trả về trangThai là 1 (int) hoặc true (bool)
    bool parseTrangThai(dynamic value) {
      if (value is bool) return value;
      if (value is int) return value == 1;
      return false;
    }

    return UserModel(
      maTK: json['maTK'] ?? 'N/A',
      tenDangNhap: json['tenDangNhap'] ?? 'N/A',
      email: json['email'],
      maNhom: json['maNhom'] ?? 'N/A',
      trangThai: parseTrangThai(json['trangThai']),

      // Thông tin chung
      hoTen: json['hoTen'],
      maKhoa: json['maKhoa'],
      tenKhoa: json['tenKhoa'],
      chuyenMon: json['chuyenMon'],

      // Bác sĩ
      maBS: json['maBS'],
      chucVu: json['chucVu'],
      trinhDo: json['trinhDo'],

      // Nhân sự
      maNS: json['maNS'],
      loaiNS: json['loaiNS'],
      capBac: json['capBac'],

      // Bệnh nhân
      maBN: json['maBN'],
      gioiTinh: json['gioiTinh'],
      ngaySinh: json['ngaySinh'],
      soDienThoai: json['soDienThoai'],
      bhyt: json['bhyt'],
      diaChi: json['diaChi'],
    );
  }
}
