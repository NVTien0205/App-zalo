import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_app/core/errors/result.dart';
import 'package:chat_app/core/errors/auth_error_mapper.dart';

/// Tách "gọi Firebase" khỏi "hiển thị" — page sẽ gọi qua đây thay vì
/// gọi thẳng FirebaseAuth.instance (xem audit: 7 chỗ đang gọi trực tiếp).
/// Chưa nối page nào (đúng AC T-06) — page migrate ở T-08.
class AuthService {
  final FirebaseAuth _firebaseAuth;

  AuthService({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  Future<Result<UserCredential>> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Success(credential);
    } on FirebaseAuthException catch (ex) {
      return Failure(AuthErrorMapper.map(ex.code));
    }
  }

  Future<Result<UserCredential>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Success(credential);
    } on FirebaseAuthException catch (ex) {
      return Failure(AuthErrorMapper.map(ex.code));
    }
  }

  Future<Result<void>> signOut() async {
    try {
      await _firebaseAuth.signOut();
      return const Success(null);
    } on FirebaseAuthException catch (ex) {
      return Failure(AuthErrorMapper.map(ex.code));
    }
  }

  Future<Result<void>> resetPassword({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return const Success(null);
    } on FirebaseAuthException catch (ex) {
      return Failure(AuthErrorMapper.map(ex.code));
    }
  }
}