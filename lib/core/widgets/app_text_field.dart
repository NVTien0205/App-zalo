import 'package:flutter/material.dart';
import 'package:chat_app/components/EmailTextField.dart';

/// Wrap MyEmailTextField — giữ nguyên hành vi, chuẩn hoá tên gọi theo kiến trúc mới.
class AppTextField extends StatelessWidget {
  final TextEditingController controller;

  const AppTextField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return MyEmailTextField(controller: controller);
  }
}