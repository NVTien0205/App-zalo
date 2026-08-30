import 'dart:typed_data';

import 'package:chat_app/models/articles_model.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';

class ArticleService {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  ArticleService({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  Future<List<Post>> fetchPosts() async {
    final querySnapshot = await _firestore
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      final commentsData = data['comments'] as List<dynamic>?;
      final comments = commentsData != null
          ? commentsData.map<Comment>((comment) {
              return Comment(
                authorName: comment['authorName'] ?? '',
                text: comment['text'] ?? '',
              );
            }).toList()
          : <Comment>[];

      return Post(
        postId: doc.id,
        isHide: data['hide'] ?? false,
        avatarUrl: data['avatarUrl'] ?? '',
        authorName: data['authorName'] ?? '',
        content: data['content'] ?? '',
        imageFileUrl: data['imageFileUrl'] ?? '',
        likes: data['likes'] ?? 0,
        initialLikes: data['initialLikes'] ?? false,
        comments: comments,
        timestamp: data['timestamp'] ?? 0,
      );
    }).toList();
  }

  Future<String?> uploadPostImage({
    required XFile selectedImageFile,
    Uint8List? selectedImageBytes,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ref = _storage.ref().child('posts').child('image_$timestamp.jpg');

    if (kIsWeb && selectedImageBytes != null) {
      await ref.putData(selectedImageBytes);
    } else if (!kIsWeb) {
      final bytes = await selectedImageFile.readAsBytes();
      await ref.putData(bytes);
    }

    return ref.getDownloadURL();
  }

  Future<Post> createPost({
    required UserModel userModel,
    required String postText,
    String? imageUrl,
  }) async {
    final newPost = Post(
      isHide: false,
      postId: '',
      avatarUrl: userModel.profilepicture ?? '',
      authorName: userModel.fullname ?? '',
      content: postText,
      imageFileUrl: imageUrl ?? '',
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    final postRef = await _firestore.collection('posts').add({
      'hide': false,
      'avatarUrl': newPost.avatarUrl,
      'authorName': newPost.authorName,
      'content': newPost.content,
      'imageFileUrl': imageUrl,
      'likes': newPost.likes,
      'initialLikes': newPost.initialLikes,
      'comments': newPost.comments
          .map(
            (comment) => {
              'authorName': comment.authorName,
              'text': comment.text,
            },
          )
          .toList(),
      'timestamp': newPost.timestamp,
    });

    newPost.postId = postRef.id;
    return newPost;
  }

  Future<bool> deletePostById(String postId) async {
    final postRef = _firestore.collection('posts').doc(postId);
    final postSnapshot = await postRef.get();

    if (!postSnapshot.exists) {
      return false;
    }

    await postRef.delete();
    return true;
  }

  Future<bool> updatePostContent({
    required String postId,
    required String content,
  }) async {
    final postRef = _firestore.collection('posts').doc(postId);
    final postSnapshot = await postRef.get();

    if (!postSnapshot.exists) {
      return false;
    }

    await postRef.update({'content': content});
    return true;
  }

  Future<void> updateLikes({
    required String postId,
    required bool isLike,
    required int likes,
  }) async {
    await _firestore.collection('posts').doc(postId).update({
      'initialLikes': isLike,
      'likes': likes,
    });
  }

  Future<void> setPostHidden({
    required String postId,
    required bool hide,
  }) async {
    await _firestore.collection('posts').doc(postId).update({'hide': hide});
  }
}
