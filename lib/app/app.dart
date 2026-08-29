import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_app/models/firebase_helper.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/pages/home_page.dart';
import 'package:chat_app/pages/main_page.dart';
import 'package:chat_app/features/auth/domain/auth_service.dart';
import 'package:chat_app/features/auth/data/firebase_auth_service.dart';
import 'package:chat_app/app/routes.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final databaseServiceProvider = Provider((ref) => FirebaseHelper());

/// Fetch UserModel từ Firestore theo uid — tách riêng theo family để
/// Riverpod tự cache/rebuild đúng khi uid đổi.
final userModelProvider =
    FutureProvider.family<UserModel?, String>((ref, uid) async {
  return ref.watch(databaseServiceProvider).getUserModelById(uid);
});

/// UI/widget chỉ phụ thuộc vào abstract AuthService, không biết gì về
/// FirebaseAuthService cụ thể — đúng yêu cầu Repository Pattern của lead.
final authServiceProvider = Provider<AuthService>((ref) {
  return FirebaseAuthService();
});

class ChatApp extends ConsumerWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat App',
      routes: AppRoutes.routes,
      home: authState.when(
        data: (user) {
          if (user == null) {
            // Chưa đăng nhập -> giữ nguyên UX cũ
            return HomePage();
          }
          // Đã đăng nhập -> fetch UserModel thật từ Firestore
          final userModelAsync = ref.watch(userModelProvider(user.uid));
          return userModelAsync.when(
            data: (userModel) {
              if (userModel != null) {
                return MainPage(userModel: userModel, firebaseUser: user);
              }
              // Có Auth user nhưng không lấy được model -> về HomePage
              // (khớp đúng hành vi main.dart gốc)
              return HomePage();
            },
            loading: () => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => HomePage(),
          );
        },
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => const Scaffold(
          body: Center(child: Text('lỗi khi load trạng thái xác thực')),
        ),
      ),
    );
  }
}
