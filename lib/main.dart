import 'package:chat_app/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/app/firebase_bootstrap.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Hive
  await Hive.initFlutter();
  await Hive.openBox("mybox");

  // Khởi tạo Firebase
  await initializeFirebase();

  // Chạy ứng dụng với ProviderScope.
  // Lớp ChatApp trong lib/app/app.dart đã tự động xử lý logic kiểm tra đăng nhập.
  runApp(
    const ProviderScope(
      child: ChatApp(),
    ),
  );
}
 