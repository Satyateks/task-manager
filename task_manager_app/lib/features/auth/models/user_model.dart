class UserModel {
  final int id;
  final String name;
  final String email;
  final String accessToken;
  final String refreshToken;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.accessToken,
    required this.refreshToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final userData = json.containsKey('user') ? json['user'] : json;
    return UserModel(
      id: userData['id'] as int,
      name: userData['name'] as String,
      email: userData['email'] as String,
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }
}