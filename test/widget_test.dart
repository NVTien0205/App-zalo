// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chat_app/pages/home_page.dart';
import 'package:chat_app/app/app.dart';

void main() {
  testWidgets(
      'ChatApp shows HomePage with login/register buttons when unauthenticated',
      (WidgetTester tester) async {
    debugPrint(
        '--- Bắt đầu Widget Test: Kiểm tra màn hình HomePage khi chưa đăng nhập ---');

    // Build our app and trigger a frame.
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      // Bỏ qua lỗi ảnh mạng
      if (details.exception.toString().contains('NetworkImage') ||
          details.exception.toString().contains('HTTP') ||
          details.library == 'image resource service') {
        debugPrint(
            'Bỏ qua lỗi tải tài nguyên mạng không cần thiết trong môi trường test.');
        return;
      }
      originalOnError?.call(details);
    };

    debugPrint(
        'Bơm Widget ChatApp vào cây Widget với authStateProvider = null');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          //Lỗi HomePage không tìm thấy
          // Giả lập "chưa đăng nhập" — tránh gọi Firebase thật trong test.
          authStateProvider.overrideWith(
            (ref) => Stream.value(null),
          ),
        ],
        child: const ChatApp(),
      ),
    );

    debugPrint('Đang chờ hệ thống render frame đầu tiên...');
    await tester.pump();

    debugPrint('Kiểm tra sự hiện diện của MaterialApp và HomePage...');
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(HomePage), findsOneWidget);

    debugPrint('Kiểm tra sự hiện diện của các nút ĐĂNG NHẬP và ĐĂNG KÝ...');
    expect(find.text('ĐĂNG NHẬP'), findsOneWidget);
    expect(find.text('ĐĂNG KÝ'), findsOneWidget);

    debugPrint('--- Kết thúc Widget Test thành công ---');
    // Restore lại
    FlutterError.onError = originalOnError;
  });
}
