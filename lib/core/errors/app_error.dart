/// Đại diện cho 1 lỗi trong tầng domain/data — thay thế cho việc quăng
/// Exception trực tiếp hoặc print(e) rải rác (xem danh sách 13 chỗ
/// try/catch cũ trong lib/pages/*.dart, sẽ migrate dần ở sprint sau).
class AppError {
  final String message;
  final String code;

  const AppError({required this.message, required this.code});

  @override
  String toString() => "AppError(code: $code, message: $message)";

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppError && other.message == message && other.code == code;

  @override
  int get hashCode => Object.hash(message, code);
}