/// Firestore collection path constants.
/// Giá trị string PHẢI khớp chính xác với dữ liệu đã tồn tại trên Firestore —
/// không đổi giá trị dù tên biến Dart không theo đúng convention camelCase.
class FirestorePaths {
  FirestorePaths._();

  static const String users = "users";
  static const String messages = "messages";

  // Lưu ý: giá trị thật trên Firestore là "chatrooms" (viết thường liền),
  // không phải "chatRooms". Xem ChatRoom-Page.dart:50,58,225.
  static const String chatRooms = "chatrooms";

  // Chưa có dữ liệu thật nào dùng collection này — chuẩn bị cho tính năng tương lai.
  static const String friendRequests = "friendRequests";

  static String messagesOf(String roomId) => "$chatRooms/$roomId/$messages";
}