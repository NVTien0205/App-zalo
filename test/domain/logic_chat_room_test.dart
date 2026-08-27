import 'package:flutter_test/flutter_test.dart';
import 'package:chat_app/models/chat_room_uuid_model.dart';
import 'package:flutter/foundation.dart' show debugPrint;

void main() {
  group('Logic Test: ChatRoom ID Generation', () {
    const userA = 'user_123';
    const userB = 'user_456';

    test('Nghiệp vụ: ChatRoomId phải đồng nhất (như nhau) bất kể thứ tự tham số', () {
      debugPrint('>>> Bắt đầu Lab: Test ChatRoom ID Logic');

      // 1. Thực thi: Tạo ID theo 2 cách (A-B và B-A)
      final roomIdAB = ChatRoomUtil.generateChatRoomId(userA, userB);
      final roomIdBA = ChatRoomUtil.generateChatRoomId(userB, userA);

      debugPrint('Room ID (A -> B): $roomIdAB');
      debugPrint('Room ID (B -> A): $roomIdBA');

      // 2. Kiểm chứng: Hai ID phải giống hệt nhau
      expect(roomIdAB, equals(roomIdBA));
      
      // 3. Kiểm chứng: ID trả về phải là một chuỗi UUID hợp lệ (không phải chuỗi nối đơn giản)
      // UUID v5 có độ dài cố định 36 ký tự (bao gồm dấu gạch ngang)
      expect(roomIdAB.length, equals(36));
      expect(roomIdAB.contains('-'), isTrue);
      
      debugPrint('Xác nhận: Logic sắp xếp ID hoạt động tốt, đảm bảo 2 người luôn vào chung 1 phòng.');
    });

    test('Nghiệp vụ: ChatRoomId phải thay đổi nếu một trong hai User ID khác đi', () {
      const userC = 'user_789';
      
      final roomIdAB = ChatRoomUtil.generateChatRoomId(userA, userB);
      final roomIdAC = ChatRoomUtil.generateChatRoomId(userA, userC);

      debugPrint('Room ID (A-B): $roomIdAB');
      debugPrint('Room ID (A-C): $roomIdAC');

      expect(roomIdAB, isNot(equals(roomIdAC)));
      debugPrint('Xác nhận: Mỗi cặp người dùng có một ID phòng chat riêng biệt.');
    });
  });
}
