import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_app/core/errors/result.dart';

abstract interface class AuthService {
  Future<Result<UserCredential>> signUp({
    required String email,
    required String password,
    required String fullName,
  });

  Future<Result<UserCredential>> signIn({
    required String email,
    required String password,
  });

  Future<Result<void>> signOut();

  Future<Result<void>> resetPassword({required String email});

  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword
  });

  Future<Result<void>> updateDisplayName({ required String newName });
}