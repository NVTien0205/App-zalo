import 'package:chat_app/core/errors/app_error.dart';
import 'package:chat_app/features/auth/domain/auth_service.dart';

class RegisterState {
  final AuthStatus status;
  final String email;
  final String password;
  final String confirmPassword;
  final AppError? error;

  const RegisterState({
    this.status = AuthStatus.idle,
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.error
  });

  RegisterState copyWith({
    AuthStatus? status,
    String? email,
    String? password,
    String? confirmPassword,
    AppError? error
  }) {
    return RegisterState(
      status : status ?? this.status,
      email : email ?? this.email,
      password : password ?? this.password,
      confirmPassword : confirmPassword ?? this.confirmPassword,
      error: error
    );
  }

} 