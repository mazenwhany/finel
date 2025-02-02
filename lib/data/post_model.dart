class Post {
  final String id;
  final String userId;
  final String photoUrl;
  final String username;
  final String? avatar_url; // Field added
  final String? caption;
  final DateTime createdAt;
  final DateTime updatedAt;

  Post({
    required this.id,
    required this.userId,
    required this.photoUrl,
    required this.username,
    this.avatar_url, // Added to constructor (optional)
    this.caption,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) => Post(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    photoUrl: json['photo_url'] as String,
    username: json['username'] as String,
    avatar_url: json['avatar_url'] as String?, // Parse from JSON
    caption: json['caption'] as String?,
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'photo_url': photoUrl,
    'username': username,
    'avatar_url': avatar_url, // Include in JSON
    'caption': caption,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}