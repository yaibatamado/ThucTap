import 'package:flutter/material.dart';

class NotFoundScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lỗi 404')),
      body: Center(
        child: Text(
          "404 – Không tìm thấy trang!",
          style: TextStyle(fontSize: 24, color: Colors.red),
        ),
      ),
    );
  }
}
