import 'package:chat_app/app/app.dart';
import 'package:chat_app/features/auth/domain/auth_service.dart';
import 'package:chat_app/features/auth/domain/auth_status.dart';
import 'package:chat_app/features/auth/register/register_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterViewModel extends Notifier<RegisterState>{
  @override
  RegisterState build() => const RegisterState();

  AuthService get _authServices => ref.read(authServiceProvider);

  void setEmail(String email) {
    state = state.copyWith(email: email, error: null);
  }

  void setPassword(String password) {
    state = state.copyWith(password: password, error: null);
  }

  void setConfirmPassword(String confirmPassword) {
    state = state.copyWith(confirmPassword: confirmPassword, error: null);
  }

  void setFullName(String fullName) {
    state = state.copyWith(fullName: fullName, error: null);
  }

  Future<void> register() async {
    if (state.status == AuthStatus.loading) return;

    state = state.copyWith(status: AuthStatus.loading, error: null);

    final result = await _authServices.signUp(
      email: state.email,
      password: state.password,
      fullName: state.fullName,
    );

    result.fold(
      onSuccess: (_) {
        state = state.copyWith(status: AuthStatus.success, error: null);
      },
      onFailure: (err) {
        state = state.copyWith(status: AuthStatus.failure, error: err);
      }
    );
  }
}
  final registerViewModelProvider = NotifierProvider.autoDispose
  <RegisterViewModel, RegisterState> (
    RegisterViewModel.new);
