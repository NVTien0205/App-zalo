class CommentModel {
  final String authorName;
  final String text;

  const CommentModel({
    required this.authorName,
    required this.text,
  });

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      authorName: map['authorName'] ?? '',
      text: map['text'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'authorName': authorName,
      'text': text,
    };
  }
}

class ArticleModel {
  final String postId;
  final String avatarUrl;
  final String authorName;
  final String content;
  final String imageFileUrl;
  final int likes;
  final bool initialLikes;
  final List<CommentModel> comments;
  final int timestamp;
  final bool isHide;

  const ArticleModel({
    required this.postId,
    required this.avatarUrl,
    required this.authorName,
    required this.content,
    required this.imageFileUrl,
    this.likes = 0,
    this.initialLikes = false,
    this.comments = const [],
    required this.timestamp,
    this.isHide = false,
  });

  ArticleModel copyWith({
    String? postId,
    String? avatarUrl,
    String? authorName,
    String? content,
    String? imageFileUrl,
    int? likes,
    bool? initialLikes,
    List<CommentModel>? comments,
    int? timestamp,
    bool? isHide,
  }) {
    return ArticleModel(
      postId: postId ?? this.postId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      authorName: authorName ?? this.authorName,
      content: content ?? this.content,
      imageFileUrl: imageFileUrl ?? this.imageFileUrl,
      likes: likes ?? this.likes,
      initialLikes: initialLikes ?? this.initialLikes,
      comments: comments ?? this.comments,
      timestamp: timestamp ?? this.timestamp,
      isHide: isHide ?? this.isHide,
    );
  }

  factory ArticleModel.fromMap(Map<String, dynamic> map, String docId) {
    final List<dynamic>? commentsData = map['comments'];
    final List<CommentModel> commentsList = commentsData != null
        ? commentsData
            .map<CommentModel>((c) => CommentModel.fromMap(Map<String, dynamic>.from(c)))
            .toList()
        : [];

    return ArticleModel(
      postId: docId,
      avatarUrl: map['avatarUrl'] ?? '',
      authorName: map['authorName'] ?? '',
      content: map['content'] ?? '',
      imageFileUrl: map['imageFileUrl'] ?? '',
      likes: map['likes'] ?? 0,
      initialLikes: map['initialLikes'] ?? false,
      comments: commentsList,
      timestamp: map['timestamp'] ?? 0,
      isHide: map['hide'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'avatarUrl': avatarUrl,
      'authorName': authorName,
      'content': content,
      'imageFileUrl': imageFileUrl,
      'likes': likes,
      'initialLikes': initialLikes,
      'comments': comments.map((c) => c.toMap()).toList(),
      'timestamp': timestamp,
      'hide': isHide,
    };
  }
}
