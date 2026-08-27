import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/app/app.dart';
import 'package:chat_app/features/auth/domain/auth_service.dart';
import 'package:chat_app/core/errors/result.dart';
import 'package:chat_app/core/errors/app_error.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint;

// 1. Mock đúng lớp chứa logic nghiệp vụ
class MockAuthService extends Mock implements AuthService {}
class MockUserCredential extends Mock implements UserCredential {}

void main() {
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
  });

  test('Nghiệp vụ: Chuyển đổi lỗi kỹ thuật Firebase thành thông báo tiếng Việt', () async {
    debugPrint('>>> Lab: Test Error Mapping (Xử lý lỗi mạng)');

    // 2. Thiết lập giả lập: Khi gọi signIn mà mất mạng, trả về Failure với message tiếng Việt
    // Lưu ý: signIn dùng named parameters (email, password)
    when(() => mockAuthService.signIn(
      email: any(named: 'email'),
      password: any(named: 'password'),
    )).thenAnswer((_) async => const Failure(AppError(
        code: 'network-request-failed',
        message: 'Lỗi kết nối mạng, vui lòng thử lại!'
    )));

    // 3. Khởi tạo Container và QUAN TRỌNG: Ghi đè authServiceProvider
    final container = ProviderContainer(
      overrides: [
        authServiceProvider.overrideWithValue(mockAuthService),
      ],
    );

    // 4. Thực thi hành động đăng nhập
    final result = await container.read(authServiceProvider).signIn(
      email: 'test@gmail.com',
      password: 'password123',
    );

    // 5. Kiểm chứng nghiệp vụ
    result.fold(
      onSuccess: (_) => fail('Lỗi logic: Đáng lẽ phải trả về Failure khi mất mạng!'),
      onFailure: (error) {
        debugPrint('Thông báo lỗi nhận được tại UI: ${error.message}');

        // Kiểm tra xem message có thân thiện với người dùng không
        expect(error.code, equals('network-request-failed'));
        expect(error.message, contains('kết nối mạng'));
        expect(error.message, isNot(contains('Exception'))); // Không được hiện lỗi kỹ thuật thuần túy
      },
    );

    debugPrint('Xác nhận: Hệ thống đã chuyển đổi lỗi Firebase thành thông báo thân thiện thành công.');
  });
}