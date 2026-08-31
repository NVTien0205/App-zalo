import 'package:chat_app/features/auth/domain/auth_status.dart';
import 'package:chat_app/features/auth/domain/auth_service.dart';
import 'package:chat_app/features/auth/login/login_state.dart';
import 'package:chat_app/app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginViewModel extends Notifier<LoginState> {
  @override
  LoginState build() => const LoginState();
  AuthService get _authService => ref.read(authServiceProvider);

  void setEmail(String email) {
    state = state.copyWith(email: email, error: null);
  }

  void setPassword(String password) {
    state = state.copyWith(password: password, error: null);
  }

  Future<void> login() async {
    if (state.status == AuthStatus.loading) return; // tránh double-submit

    state = state.copyWith(status: AuthStatus.loading, error: null);

    final result = await _authService.signIn(
      email: state.email,
      password: state.password,
    );

    result.fold(
      onSuccess: (_) {
        state = state.copyWith(status: AuthStatus.success, error: null);
      },
      onFailure: (err) {
        state = state.copyWith(status: AuthStatus.failure, error: err);
      },
    );
  }
}

final loginViewModelProvider =
    NotifierProvider.autoDispose<LoginViewModel, LoginState>(
      LoginViewModel.new);