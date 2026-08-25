import 'package:flutter/material.dart';
import 'package:chat_app/components/password_text_field.dart';

/// Wrap MyPasswordTextField — giữ nguyên hành vi (toggle ẩn/hiện có sẵn).
class AppPasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const AppPasswordField({
    super.key,
    required this.controller,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return MyPasswordTextField(controller: controller, myText: hintText);
  }
}