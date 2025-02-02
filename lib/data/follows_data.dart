class Follow {
  final String followerId;
  final String followingId;
  final DateTime createdAt;
  final String followerUsername;
  final String followingUsername;

  Follow({
    required this.followerId,
    required this.followingId,
    required this.createdAt,
    required this.followerUsername,
    required this.followingUsername,
  });

  factory Follow.fromJson(Map<String, dynamic> json) {
    return Follow(
      followerId: json['follower_id'],
      followingId: json['following_id'],
      createdAt: DateTime.parse(json['created_at']),
      followerUsername: json['follower_username'],
      followingUsername: json['following_username'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'follower_id': followerId,
      'following_id': followingId,
      'created_at': createdAt.toIso8601String(),
      'follower_username': followerUsername,
      'following_username': followingUsername,
    };
  }
}