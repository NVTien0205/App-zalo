import 'package:flutter_test/flutter_test.dart';
import 'package:chat_app/core/errors/app_error.dart';
import 'package:chat_app/core/errors/result.dart';

void main() {
  group('Result.fold', () {
    test('Success gọi đúng nhánh onSuccess với giá trị đúng', () {
      const result = Success<int>(42);

      final output = result.fold<String>(
        onSuccess: (value) => "OK: $value",
        onFailure: (error) => "FAIL: ${error.message}",
      );

      expect(output, "OK: 42");
    });

    test('Failure gọi đúng nhánh onFailure với AppError đúng', () {
      const error = AppError(message: "Sai mật khẩu", code: "wrong-password");
      const result = Failure<int>(error);

      final output = result.fold<String>(
        onSuccess: (value) => "OK: $value",
        onFailure: (err) => "FAIL: ${err.message}",
      );

      expect(output, "FAIL: Sai mật khẩu");
    });

    test('isSuccess / isFailure trả đúng giá trị', () {
      const success = Success<String>("hello");
      const failure = Failure<String>(AppError(message: "lỗi", code: "x"));

      expect(success.isSuccess, true);
      expect(success.isFailure, false);
      expect(failure.isSuccess, false);
      expect(failure.isFailure, true);
    });

    test('AppError so sánh bằng nhau đúng theo message + code', () {
      const e1 = AppError(message: "a", code: "b");
      const e2 = AppError(message: "a", code: "b");
      const e3 = AppError(message: "a", code: "different");

      expect(e1, equals(e2));
      expect(e1 == e3, false);
    });

    test('fold hoạt động đúng với generic type khác nhau (Map)', () {
      const result = Success<Map<String, int>>({"count": 5});

      final output = result.fold<int>(
        onSuccess: (value) => value["count"]!,
        onFailure: (_) => -1,
      );

      expect(output, 5);
    });
  });
}