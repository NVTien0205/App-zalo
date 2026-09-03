import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';

const String defaultProfilePictureUrl =
    'https://firebasestorage.googleapis.com/v0/b/YOUR_PROJECT/o/defaults%2Fdefault_avatar.png?alt=media';

/// Kết quả chọn ảnh — tách khỏi State cụ thể để dùng chung giữa nhiều feature
/// (Register, ProfileSetup, và các nơi cần chọn/upload ảnh sau này).
class PickedImage {
  final XFile file;
  final Uint8List bytes;

  const PickedImage({required this.file, required this.bytes});
}

/// Service thuần cho việc chọn ảnh + upload avatar lên Firebase Storage.
/// Không phụ thuộc Riverpod/State — ViewModel gọi trực tiếp, dễ test/tái sử dụng.
class ImageService {
  Future<PickedImage?> pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile == null) return null;
    final bytes = await pickedFile.readAsBytes();
    return PickedImage(file: pickedFile, bytes: bytes);
  }

  Future<String> uploadAvatar({
    required String uid,
    required PickedImage? image,
  }) async {
    if (image == null) return defaultProfilePictureUrl;

    UploadTask uploadTask;
    if (kIsWeb) {
      uploadTask = FirebaseStorage.instance
          .ref('profilepictures')
          .child(uid)
          .putData(image.bytes);
    } else {
      final bytes = await image.file.readAsBytes();
      uploadTask = FirebaseStorage.instance
          .ref('profilepictures')
          .child(uid)
          .putData(bytes);
    }

    final snapshot = await uploadTask;
    return snapshot.ref.getDownloadURL();
  }
}