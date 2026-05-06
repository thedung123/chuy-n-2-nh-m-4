class UserModel {
  final String id;
  final String username;

  UserModel({required this.id, required this.username});

  // Chuyển dữ liệu từ Map (JSON) sang Object
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      username: json['username'] ?? '',
    );
  }
}
