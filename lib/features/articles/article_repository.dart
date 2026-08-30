import 'dart:typed_data';

import 'package:chat_app/core/errors/app_error.dart';
import 'package:chat_app/core/errors/result.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:image_picker/image_picker.dart';

import 'models/article_model.dart';

abstract class IArticleRepository {
  Future<Result<List<ArticleModel>>> getPosts();
  Stream<List<ArticleModel>> watchPosts();
  Future<Result<String>> createPost({
    required String content,
    required String authorName,
    required String avatarUrl,
    XFile? imageFile,
    Uint8List? imageBytes,
  });
  Future<Result<void>> toggleLike({
    required String postId,
    required bool isLiked,
    required int likesCount,
  });
  Future<Result<void>> addComment({
    required String postId,
    required CommentModel comment,
    required List<CommentModel> currentComments,
  });
  Future<Result<void>> updatePostContent({
    required String postId,
    required String newContent,
  });
  Future<Result<void>> toggleHidePost({
    required String postId,
    required bool isHide,
  });
  Future<Result<void>> deletePost(String postId);
}

class ArticleRepository implements IArticleRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  ArticleRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  void _logRepositoryFlow(String message) {
    debugPrint('ArticlesRepository debug -> $message');
  }

  @override
  Future<Result<List<ArticleModel>>> getPosts() async {
    try {
      _logRepositoryFlow('getPosts start -> collection: posts');

      final querySnapshot = await _firestore
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .get();

      _logRepositoryFlow(
        'getPosts success -> raw doc count: ${querySnapshot.docs.length}',
      );

      final posts = querySnapshot.docs
          .map((doc) => ArticleModel.fromMap(doc.data(), doc.id))
          .toList();

      _logRepositoryFlow('getPosts mapped -> post count: ${posts.length}');
      return Success(posts);
    } catch (e) {
      _logRepositoryFlow('getPosts error -> $e');
      return Failure(AppError(message: 'Lỗi khi tải bài viết: $e'));
    }
  }

  @override
  Stream<List<ArticleModel>> watchPosts() {
    _logRepositoryFlow('watchPosts subscribe -> collection: posts');

    return _firestore
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      _logRepositoryFlow(
        'watchPosts event -> raw doc count: ${snapshot.docs.length}',
      );

      final posts = snapshot.docs
          .map((doc) => ArticleModel.fromMap(doc.data(), doc.id))
          .toList();

      _logRepositoryFlow('watchPosts mapped -> post count: ${posts.length}');
      return posts;
    });
  }

  Future<String> _uploadImage(XFile imageFile, Uint8List? imageBytes) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ref = _storage.ref().child('posts').child('image_$timestamp.jpg');

    _logRepositoryFlow(
      'uploadImage start -> path: posts/image_$timestamp.jpg | isWeb: $kIsWeb',
    );

    if (kIsWeb && imageBytes != null) {
      _logRepositoryFlow(
        'uploadImage source -> web bytes length: ${imageBytes.length}',
      );
      await ref.putData(imageBytes);
    } else {
      final bytes = imageBytes ?? await imageFile.readAsBytes();
      _logRepositoryFlow(
        'uploadImage source -> native bytes length: ${bytes.length}',
      );
      await ref.putData(bytes);
    }

    final downloadUrl = await ref.getDownloadURL();
    _logRepositoryFlow('uploadImage success -> downloadUrl: $downloadUrl');
    return downloadUrl;
  }

  @override
  Future<Result<String>> createPost({
    required String content,
    required String authorName,
    required String avatarUrl,
    XFile? imageFile,
    Uint8List? imageBytes,
  }) async {
    try {
      _logRepositoryFlow(
        'createPost start -> author: $authorName | contentLength: ${content.length} | hasImage: ${imageFile != null}',
      );
      _logRepositoryFlow(
        'createPost payload -> trimmedLength: ${content.trim().length} | avatarUrlEmpty: ${avatarUrl.isEmpty}',
      );

      String imageUrl = '';
      if (imageFile != null) {
        _logRepositoryFlow(
            'createPost branch -> upload image before Firestore write');
        imageUrl = await _uploadImage(imageFile, imageBytes);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final postMap = {
        'hide': false,
        'avatarUrl': avatarUrl,
        'authorName': authorName,
        'content': content,
        'imageFileUrl': imageUrl,
        'likes': 0,
        'initialLikes': false,
        'comments': [],
        'timestamp': timestamp,
      };

      _logRepositoryFlow(
        'createPost payload ready -> likes: ${postMap['likes']} | commentsCount: ${(postMap['comments'] as List).length} | timestamp: $timestamp',
      );
      _logRepositoryFlow('createPost write -> collection: posts');
      final docRef = await _firestore.collection('posts').add(postMap);
      _logRepositoryFlow('createPost success -> postId: ${docRef.id}');
      return Success(docRef.id);
    } catch (e) {
      _logRepositoryFlow('createPost error -> $e');
      return Failure(AppError(message: 'Lỗi khi đăng bài viết: $e'));
    }
  }

  @override
  Future<Result<void>> toggleLike({
    required String postId,
    required bool isLiked,
    required int likesCount,
  }) async {
    try {
      _logRepositoryFlow(
        'toggleLike start -> postId: $postId | isLiked: $isLiked | likesCount: $likesCount',
      );

      await _firestore
          .collection('posts')
          .doc(postId)
          .update({'initialLikes': isLiked, 'likes': likesCount});

      _logRepositoryFlow('toggleLike success -> postId: $postId');
      return const Success(null);
    } catch (e) {
      _logRepositoryFlow('toggleLike error -> $e');
      return Failure(AppError(message: 'Lỗi khi cập nhật lượt thích: $e'));
    }
  }

  @override
  Future<Result<void>> addComment({
    required String postId,
    required CommentModel comment,
    required List<CommentModel> currentComments,
  }) async {
    try {
      _logRepositoryFlow(
        'addComment start -> postId: $postId | currentComments: ${currentComments.length}',
      );

      final updatedComments = [...currentComments, comment];
      await _firestore.collection('posts').doc(postId).update({
        'comments': updatedComments.map((c) => c.toMap()).toList(),
      });

      _logRepositoryFlow(
        'addComment success -> postId: $postId | updatedComments: ${updatedComments.length}',
      );
      return const Success(null);
    } catch (e) {
      _logRepositoryFlow('addComment error -> $e');
      return Failure(AppError(message: 'Lỗi khi thêm bình luận: $e'));
    }
  }

  @override
  Future<Result<void>> updatePostContent({
    required String postId,
    required String newContent,
  }) async {
    try {
      _logRepositoryFlow(
        'updatePostContent start -> postId: $postId | newContentLength: ${newContent.length}',
      );

      await _firestore
          .collection('posts')
          .doc(postId)
          .update({'content': newContent});

      _logRepositoryFlow('updatePostContent success -> postId: $postId');
      return const Success(null);
    } catch (e) {
      _logRepositoryFlow('updatePostContent error -> $e');
      return Failure(AppError(message: 'Lỗi khi sửa bài viết: $e'));
    }
  }

  @override
  Future<Result<void>> toggleHidePost({
    required String postId,
    required bool isHide,
  }) async {
    try {
      _logRepositoryFlow(
        'toggleHidePost start -> postId: $postId | isHide: $isHide',
      );

      await _firestore.collection('posts').doc(postId).update({'hide': isHide});

      _logRepositoryFlow('toggleHidePost success -> postId: $postId');
      return const Success(null);
    } catch (e) {
      _logRepositoryFlow('toggleHidePost error -> $e');
      return Failure(AppError(message: 'Lỗi khi ẩn/hiện bài viết: $e'));
    }
  }

  @override
  Future<Result<void>> deletePost(String postId) async {
    try {
      _logRepositoryFlow('deletePost start -> postId: $postId');
      await _firestore.collection('posts').doc(postId).delete();
      _logRepositoryFlow('deletePost success -> postId: $postId');
      return const Success(null);
    } catch (e) {
      _logRepositoryFlow('deletePost error -> $e');
      return Failure(AppError(message: 'Lỗi khi xóa bài viết: $e'));
    }
  }
}
