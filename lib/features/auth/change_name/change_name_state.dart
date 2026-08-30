import 'package:chat_app/core/errors/app_error.dart';
import 'package:chat_app/features/auth/domain/auth_service.dart';

class ChangeNameState {
  final AuthStatus status; // dùng lại enum chung, dù không thuộc AuthService
  final String newFullName;
  final AppError? error;

  const ChangeNameState({
    this.status = AuthStatus.idle,
    this.newFullName = '',
    this.error,
  });

  ChangeNameState copyWith({
    AuthStatus? status,
    String? newFullName,
    AppError? error,
  }) {
    return ChangeNameState(
      status: status ?? this.status,
      newFullName: newFullName ?? this.newFullName,
      error: error,
    );
  }
}