import 'package:flutter/material.dart';

/// Helper hiển thị SnackBar chuẩn hoá — thay cho việc gọi
/// ScaffoldMessenger.of(context).showSnackBar(...) rải rác từng page.
void showAppSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}