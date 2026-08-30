import 'package:chat_app/core/errors/app_error.dart';
import 'package:chat_app/features/auth/domain/auth_service.dart';

class ChangePasswordState {
  final AuthStatus status;
  final String currentPassword;
  final String newPassword;
  final AppError? error;

  const ChangePasswordState({
    this.status = AuthStatus.idle,
    this.currentPassword = '',
    this.newPassword = '',
    this.error,
  });

  ChangePasswordState copyWith({
    AuthStatus? status,
    String? currentPassword,
    String? newPassword,
    AppError? error,
  }) {
    return ChangePasswordState(
      status: status ?? this.status,
      currentPassword: currentPassword ?? this.currentPassword,
      newPassword: newPassword ?? this.newPassword,
      error: error,
    );
  }
}