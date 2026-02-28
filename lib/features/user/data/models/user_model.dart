class UserModel {
  final String? id;
  final String fullName;
  final String? email;
  final String? profilePicture;

  UserModel({this.id, required this.fullName, this.email, this.profilePicture});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'],
      fullName: json['fullName'] ?? '',
      email: json['email'],
      profilePicture: json['profilePicture'],
    );
  }
}
