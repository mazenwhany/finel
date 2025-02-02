import 'dart:convert';

class Story {
  final String id;
  final String userId;
  final String imageUrl;
  final String? avatarUrl;
  final String? username;
  final DateTime createdAt;

  Story({
    required this.id,
    required this.userId,
    required this.imageUrl,
    this.avatarUrl,
    this.username,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Story.fromJson(Map<String, dynamic> json) => Story(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    imageUrl: json['image_url'] as String,
    avatarUrl: json['avatar_url'] as String?,
    username: json['username'] as String?,
    createdAt: DateTime.parse(json['created_at'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'image_url': imageUrl,
    'avatar_url': avatarUrl,
    'username': username,
    'created_at': createdAt.toIso8601String(),
  };

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
