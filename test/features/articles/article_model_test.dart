import 'package:chat_app/features/articles/models/article_model.dart';
import 'package:chat_app/features/articles/models/articles_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ArticleModel Test', () {
    test('CommentModel toMap and fromMap should serialize correctly', () {
      const comment = CommentModel(authorName: 'Tien', text: 'Xin chao');
      final map = comment.toMap();

      expect(map['authorName'], 'Tien');
      expect(map['text'], 'Xin chao');

      final fromMapComment = CommentModel.fromMap(map);
      expect(fromMapComment.authorName, 'Tien');
      expect(fromMapComment.text, 'Xin chao');
    });

    test('ArticleModel copyWith should update specified fields', () {
      const article = ArticleModel(
        postId: '123',
        avatarUrl: 'http://avatar.png',
        authorName: 'Nguyen',
        content: 'Hello World',
        imageFileUrl: '',
        likes: 5,
        initialLikes: false,
        timestamp: 100000,
      );

      final updated = article.copyWith(likes: 6, initialLikes: true);

      expect(updated.likes, 6);
      expect(updated.initialLikes, true);
      expect(updated.content, 'Hello World');
    });
  });

  group('ArticlesState Test', () {
    test('ArticlesState copyWith clearSelectedImage should clear image data', () {
      const state = ArticlesState(
        isLoading: false,
      );

      final newState = state.copyWith(clearSelectedImage: true);
      expect(newState.selectedImageBytes, null);
      expect(newState.selectedImageFile, null);
    });
  });
}
