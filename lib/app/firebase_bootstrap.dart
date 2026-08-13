import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Khởi tạo Firebase cho cả Web và Mobile (Android/iOS).
/// Di chuyển từ main.dart:19-38 (T-03) — hành vi giữ nguyên y hệt bản gốc,
/// chỉ tách "config" ra khỏi "điểm chạy".
Future<void> initializeFirebase() async {
  try {
    if (kIsWeb) {
      // Cấu hình cho web từ project setting firebase console
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyBOgmrG1kp2Yd3E2OuUIgD7DhTlQ_b21kw",
          authDomain: "app-zalo-6c0f6.firebaseapp.com",
          projectId: "app-zalo-6c0f6",
          storageBucket: "app-zalo-6c0f6.appspot.com",
          messagingSenderId: "764109092494",
          appId: "1:764109092494:web:447a19473fc072be2f7bdf",
        ),
      );
    } else {
      // Cấu hình cho mobile (Android/iOS)
      await Firebase.initializeApp();
    }
  } catch (e) {
    // ignore: avoid_print
    print("Error initializing Firebase: $e");
  }
}