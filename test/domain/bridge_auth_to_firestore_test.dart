import 'package:chat_app/app/app.dart';
import 'package:chat_app/models/firebase_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter/foundation.dart' show debugPrint;

// 1. Mock các đối tượng cần thiết
class MockUser extends Mock implements User {} // Mock User của Auth
class MockFirebaseHelper extends Mock implements FirebaseHelper {} // Mock Helper (không dùng static)

void main() {
  late MockFirebaseHelper mockHelper;
  late MockUser mockAuthUser;

  setUp(() {
    mockHelper = MockFirebaseHelper();
    mockAuthUser = MockUser();

    // Giả lập UID cho Auth User
    when(() => mockAuthUser.uid).thenReturn('12345678');
  });

  test('Nghiệp vụ: Khi Auth có User, UserModelProvider phải tự động fetch profile', () async {
    debugPrint('>>> Bắt đầu Lab: Bridge Auth to Firestore');

    // 2. Thiết lập giả lập cho Firestore
    final expectedModel = UserModel(
        uid: '12345678',
        fullname: 'Nguyễn Tiến',
        email: 'tien@test.com',
        friendList: [],
        profilepicture: ''
    );

    // Lưu ý: FirebaseHelper lúc này phải có hàm instance (không static) hoặc bọc qua service
    when(() => mockHelper.getUserModelById('12345678'))
        .thenAnswer((_) async => expectedModel);

    // 3. Khởi tạo Container với các Override
    final container = ProviderContainer(
      overrides: [
        // Ghi đè Auth State để giả lập người dùng đã đăng nhập
        authStateProvider.overrideWith((ref) => Stream.value(mockAuthUser)),

        // Ghi đè Helper để không gọi vào Database thật
        databaseServiceProvider.overrideWithValue(mockHelper),
      ],
    );

    debugPrint('Đang chờ Bridge hoạt động...');

    // 4. Đọc Future của userModelProvider
    // Lưu ý: Trong code của bạn là FutureProvider.family(uid), nên phải truyền uid vào
    final userModel = await container.read(userModelProvider('12345678').future);

    // 5. Kiểm tra kết quả
    debugPrint('Kết quả: Fullname = ${userModel?.fullname}');
    expect(userModel?.fullname, equals('Nguyễn Tiến'));
    expect(userModel?.uid, equals('12345678'));
  });

  test('Nghiệp vụ: Xử lý an toàn khi Firestore không có dữ liệu (User mới)', () async {
    when(() => mockHelper.getUserModelById('999')).thenAnswer((_) async => null);

    final container = ProviderContainer(overrides: [
      authStateProvider.overrideWith((ref) => Stream.value(mockAuthUser)),
      databaseServiceProvider.overrideWithValue(mockHelper),
    ]);

    // Kiểm tra xem nó có trả về null thay vì crash không
    final result = await container.read(userModelProvider('999').future);
    expect(result, isNull);
    debugPrint('Xác nhận: Trả về null an toàn khi không tìm thấy User');
  });
}