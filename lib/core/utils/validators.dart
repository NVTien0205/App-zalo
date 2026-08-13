/// Validator thuần logic — không phụ thuộc Firebase/UI.
/// LƯU Ý: password policy ở đây SIẾT CHẶT HƠN logic cũ trong Register-Page.dart
/// (min 6 ký tự) — chưa đồng bộ ngược lại Register-Page.dart, sẽ áp dụng khi
/// migrate ở T-10. Cho tới lúc đó, 2 nơi có rule khác nhau, đây là chủ đích.
class Validators {
  Validators._();

  static final RegExp _emailRegex =
      RegExp(r"^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$");

  static final RegExp _digitRegex = RegExp(r'[0-9]');
  static final RegExp _specialCharRegex = RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-\[\]\\/;+=~`]');

  static const int _minPasswordLength = 10;

  /// Trả về null nếu hợp lệ, ngược lại trả về message lỗi tiếng Việt.
  static String? validateEmail(String? email) {
    final value = email?.trim() ?? "";
    if (value.isEmpty) {
      return "Vui lòng đừng để trống các ô!";
    }
    if (!_emailRegex.hasMatch(value)) {
      return "Email không đúng định dạng!";
    }
    return null;
  }

  static String? validatePassword(String? password) {
    final value = password?.trim() ?? "";
    if (value.isEmpty) {
      return "Vui lòng đừng để trống các ô!";
    }
    if (value.length < _minPasswordLength) {
      return "Mật khẩu phải có ít nhất $_minPasswordLength ký tự!";
    }
    if (!_digitRegex.hasMatch(value)) {
      return "Mật khẩu phải chứa ít nhất 1 chữ số!";
    }
    if (!_specialCharRegex.hasMatch(value)) {
      return "Mật khẩu phải chứa ít nhất 1 ký tự đặc biệt!";
    }
    return null;
  }

  static String? validateConfirmPassword(
      String? password, String? confirmPassword) {
    final value = confirmPassword?.trim() ?? "";
    if (value.isEmpty) {
      return "Vui lòng đừng để trống các ô!";
    }
    if (value != (password?.trim() ?? "")) {
      return "Mật khẩu xác nhận không trùng khớp!";
    }
    return null;
  }
}