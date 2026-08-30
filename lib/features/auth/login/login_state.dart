import 'package:chat_app/core/errors/app_error.dart';
import 'package:chat_app/features/auth/domain/auth_status.dart';

class LoginState {
  final AuthStatus status;
  final String email;
  final String password;
  final AppError? error;

  const LoginState({
    this.status = AuthStatus.idle,
    this.email = '',
    this.password = '',
    this.error
  });

  LoginState copyWith ({
    AuthStatus? status,
    String? email,
    String? password,
    AppError? error
  }) {
    return LoginState(
      status: status ?? this.status,
      email: email ?? this.email,
      password:  password ?? this.password,
      error: error
    );
  }
}