
import 'package:chat_app/core/errors/result.dart';

abstract interface class UserRepository {
  Future<Result<void>> updateFullName({
    required String uid,
    required String newFullName,
  });
   Future<Result<void>> updateProfilePicture({
    required String uid,
    required String profilePictureUrl,
  });
}

