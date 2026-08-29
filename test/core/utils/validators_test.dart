import 'package:flutter_test/flutter_test.dart';
import 'package:chat_app/core/utils/validators.dart';

void main() {
  group('validateEmail', () {
    test('rỗng -> báo lỗi trống ô', () {
      expect(Validators.validateEmail(""), "Vui lòng đừng để trống các ô!");
    });

    test('null -> báo lỗi trống ô', () {
      expect(Validators.validateEmail(null), "Vui lòng đừng để trống các ô!");
    });

    test('sai định dạng (thiếu @) -> báo lỗi định dạng', () {
      expect(Validators.validateEmail("abcgmail.com"),
          "Email không đúng định dạng!");
    });

    test('sai định dạng (thiếu domain) -> báo lỗi định dạng', () {
      expect(Validators.validateEmail("abc@"), "Email không đúng định dạng!");
    });

    test('email hợp lệ -> null', () {
      expect(Validators.validateEmail("test@gmail.com"), null);
    });

    test('email có khoảng trắng thừa vẫn được trim và pass', () {
      expect(Validators.validateEmail("  test@gmail.com  "), null);
    });
  });

  group('validatePassword', () {
    test('rỗng -> báo lỗi trống ô', () {
      expect(Validators.validatePassword(""), "Vui lòng đừng để trống các ô!");
    });

    test('ít hơn 10 ký tự -> báo lỗi độ dài', () {
      expect(Validators.validatePassword("Abc123!"),
          "Mật khẩu phải có ít nhất 10 ký tự!");
    });

    test('đúng 10 ký tự, đủ số + ký tự đặc biệt -> null (biên hợp lệ)', () {
      expect(Validators.validatePassword("Abcdef123!"), null);
    });

    test('đủ 10 ký tự nhưng thiếu chữ số -> báo lỗi thiếu số', () {
      expect(Validators.validatePassword("Abcdefghi!"),
          "Mật khẩu phải chứa ít nhất 1 chữ số!");
    });

    test(
        'đủ 10 ký tự, có số nhưng thiếu ký tự đặc biệt -> báo lỗi thiếu ký tự đặc biệt',
        () {
      expect(Validators.validatePassword("Abcdefgh12"),
          "Mật khẩu phải chứa ít nhất 1 ký tự đặc biệt!");
    });

    test('mật khẩu mạnh đầy đủ, dài hơn 10 -> null', () {
      expect(Validators.validatePassword("MyP@ssw0rd2024"), null);
    });
  });

  group('validateConfirmPassword', () {
    test('rỗng -> báo lỗi trống ô', () {
      expect(Validators.validateConfirmPassword("123456", ""),
          "Vui lòng đừng để trống các ô!");
    });

    test('không khớp password -> báo lỗi không trùng khớp', () {
      expect(Validators.validateConfirmPassword("123456", "654321"),
          "Mật khẩu xác nhận không trùng khớp!");
    });

    test('khớp password -> null', () {
      expect(Validators.validateConfirmPassword("123456", "123456"), null);
    });

    test(
        'password null, confirm rỗng -> báo lỗi trống ô (ưu tiên check rỗng trước)',
        () {
      expect(Validators.validateConfirmPassword(null, ""),
          "Vui lòng đừng để trống các ô!");
    });
  });
}
