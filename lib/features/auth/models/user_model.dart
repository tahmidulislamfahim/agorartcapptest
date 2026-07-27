class UserModel {
  final int id;
  final String username;
  final String email;
  final bool isOnline;
  final String createdAt;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.isOnline,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int? ?? 0,
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      isOnline: json['is_online'] as bool? ?? false,
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'is_online': isOnline,
      'created_at': createdAt,
    };
  }
}
