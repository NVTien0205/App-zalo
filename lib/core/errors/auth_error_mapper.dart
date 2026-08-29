import 'app_error.dart';

/// Map mã lỗi FirebaseAuthException.code sang message tiếng Việt.
/// Danh sách case dựa trên audit thực tế: Login-Page.dart hiện đang
/// silent-catch (print only, không xử lý theo code cụ thể) — đây là
/// nguồn gốc chính cần mapper này giải quyết khi migrate ở T-08.

class AuthErrorMapper {
  AuthErrorMapper._();

  static AppError map(String code) {
    switch (code) {
      case "email-already-in-use":
        return const AppError(
            code: "email-already-in-use",
            message: "Email này đã được sử dụng để đăng ký!");
      case "weak-password":
        return const AppError(
            code: "weak-password",
            message:
                "Mật khẩu quá yếu!, vui lòng sử dụng mật khẩu trên 10 ký tự!");
      case "invalid-email":
        return AppError.invalidEmail;
      case 'user-not-found':
        return const AppError(
          code: 'user-not-found',
          message: 'Không tìm thấy tài khoản tương ứng',
        );
      case 'wrong-password':
        return AppError.wrongPassword;
      case 'invalid-credential':
        return const AppError(
          code: 'invalid-credential',
          message: 'Sai email hoặc mật khẩu',
        );
      case "network-request-failed":
        return const AppError(
          code: "network-request-failed",
          message: "Lỗi kết nối mạng, vui lòng thử lại!",
        );
      case 'too-many-requests':
        return const AppError(
          code: 'too-many-requests',
          message: 'Bạn thao tác quá nhiều lần, vui lòng thử lại sau!',
        );
      case "user-disabled":
        return const AppError(
          code: "user-disabled",
          message: "Tài khoản đã bị vô hiệu hóa",
        );
      // Các mã lỗi ít gặp khác có thể bổ sung dần sau
      default:
        return AppError(
          code: code,
          message: 'Đã xảy ra lỗi, vui lòng thử lại sau!',
        );
    }
  }
}
