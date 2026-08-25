import 'package:chat_app/core/errors/app_error.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_app/app/app.dart';
import 'package:chat_app/features/auth/domain/auth_service.dart';
import 'package:chat_app/core/errors/result.dart';
import 'package:flutter/foundation.dart' show debugPrint;

// Tạo các lớp Mock để giả lập
class MockAuthService extends Mock implements AuthService {}
class MockUserCredential extends Mock implements UserCredential {}
class MockUser extends Mock implements User {}

void main() {
  late MockAuthService mockAuth;
  late MockUserCredential mockCredential;
  late ProviderContainer container;

  setUp(() {
    debugPrint('--- Thiết lập môi trường Test ---');
    mockAuth = MockAuthService();
    mockCredential = MockUserCredential();
    container = ProviderContainer(
      overrides: [
        authServiceProvider.overrideWithValue(mockAuth),
      ],
    );
    debugPrint('Đã ghi đè authServiceProvider bằng MockAuthService');
  });

  tearDown(() {
    debugPrint('--- Kết thúc Test case ---\n');
    container.dispose();
  });

  group('Auth Service & Provider Tests', () {
    test('signIn trả về Success khi thông tin hợp lệ', () async {
      debugPrint('>>> Bắt đầu test: signIn thành công');
      
      // Stubbing: Giả lập thành công
      when(() => mockAuth.signIn(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async {
            debugPrint('MockAuthService: Nhận lệnh signIn -> Trả về Success(mockCredential)');
            return Success(mockCredential);
          });

      debugPrint('Ứng dụng: Gọi signIn qua Provider...');
      final result = await container.read(authServiceProvider).signIn(
            email: 'test@example.com',
            password: 'password123',
          );

      debugPrint('Kết quả nhận được: isSuccess = ${result.isSuccess}');
      expect(result.isSuccess, isTrue);
      expect(result, isA<Success<UserCredential>>());
      
      verify(() => mockAuth.signIn(
            email: 'test@example.com',
            password: 'password123',
          )).called(1);
      debugPrint('Xác minh: Hàm signIn đã được gọi đúng 1 lần với tham số hợp lệ.');
    });

    test('signIn trả về Failure khi email không hợp lệ (không chứa @)', () async {
      debugPrint('>>> Bắt đầu test: signIn thất bại (Email sai định dạng)');

      // Stubbing: Giả lập lỗi định dạng email bằng Matcher
      when(() => mockAuth.signIn(
            email: any(named: 'email', that: isNot(contains('@'))),
            password: any(named: 'password'),
          )).thenAnswer((_) async {
            debugPrint('MockAuthService: Nhận email không hợp lệ -> Trả về Failure(AppError.invalidEmail)');
            return const Failure(AppError.invalidEmail);
          });

      debugPrint('Ứng dụng: Gọi signIn với email "invalid-email"...');
      final result = await container.read(authServiceProvider).signIn(
            email: 'invalid-email',
            password: 'password123',
          );

      debugPrint('Kết quả nhận được: isFailure = ${result.isFailure}');
      expect(result.isFailure, isTrue);
      result.fold(
        onSuccess: (_) => fail('Nên trả về Failure'),
        onFailure: (error) {
          debugPrint('Lỗi nhận được: code = ${error.code}, message = ${error.message}');
          expect(error, AppError.invalidEmail);
        },
      );
    });

    test('signOut gọi đúng vào AuthService', () async {
      debugPrint('>>> Bắt đầu test: signOut');
      when(() => mockAuth.signOut()).thenAnswer((_) async {
        debugPrint('MockAuthService: Nhận lệnh signOut -> Trả về Success(null)');
        return const Success(null);
      });

      debugPrint('Ứng dụng: Gọi signOut qua Provider...');
      final result = await container.read(authServiceProvider).signOut();

      debugPrint('Kết quả nhận được: isSuccess = ${result.isSuccess}');
      expect(result.isSuccess, isTrue);
      verify(() => mockAuth.signOut()).called(1);
      debugPrint('Xác minh: Hàm signOut đã được gọi.');
    });
  });
}
