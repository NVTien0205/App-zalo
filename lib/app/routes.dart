import 'package:flutter/material.dart';
import 'package:chat_app/pages/login_page.dart';
import 'package:chat_app/pages/register_page.dart';

/// Route table cho các trang KHÔNG cần tham số bắt buộc lúc khởi tạo.
/// Các trang cần params (ConfirmAccount, MainPage, ChatRoomPage, OtherUserScreen...)
/// vẫn dùng Navigator.push(MaterialPageRoute(...)) trực tiếp như hiện tại —
/// việc migrate toàn bộ sang named routes để dành cho sprint sau (T-10/T-12),
/// tránh làm vội gây rủi ro vỡ luồng điều hướng đang chạy ổn định.
class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String register = '/register';

  static Map<String, WidgetBuilder> get routes => {
    login: (context) => LoginPage(),
    register: (context) => RegisterPage(),
  };
}