import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/app/app.dart';
import 'package:chat_app/features/auth/domain/auth_status.dart';
import 'package:chat_app/features/auth/domain/auth_service.dart';
import 'package:chat_app/features/auth/change_name/change_name_state.dart';
import 'package:chat_app/features/user/domain/user_repository.dart';

class ChangeNameViewModel extends Notifier<ChangeNameState> {
  @override
  ChangeNameState build() => const ChangeNameState();

  AuthService get _authService => ref.read(authServiceProvider);
  UserRepository get _userRepository => ref.read(userRepositoryProvider);

  void setNewFullName(String newFullName) {
    state = state.copyWith(newFullName: newFullName, error: null);
  }

  Future<void> updateName({required String uid}) async {
    if (state.status == AuthStatus.loading) return;

    state = state.copyWith(status: AuthStatus.loading, error: null);

    final authResult = await _authService.updateDisplayName(
      newName: state.newFullName,
    );

    final failed = authResult.fold(
      onSuccess: (_) => null,
      onFailure: (err) => err,
    );

    if (failed != null) {
      state = state.copyWith(status: AuthStatus.failure, error: failed);
      return;
    }

    final repoResult = await _userRepository.updateFullName(
      uid: uid,
      newFullName: state.newFullName,
    );

    repoResult.fold(
      onSuccess: (_) {
        state = state.copyWith(status: AuthStatus.success, error: null);
      },
      onFailure: (err) {
        state = state.copyWith(status: AuthStatus.failure, error: err);
      },
    );
  }
}

final changeNameViewModelProvider =
    NotifierProvider.autoDispose<ChangeNameViewModel, ChangeNameState>(
  ChangeNameViewModel.new,
);