import 'dart:convert';

class UserModel {
  final String name;
  final String email;
  final String phone;
  final String bio;
  final String avatarUrl;

  UserModel({
    required this.name,
    required this.email,
    this.phone = '',
    this.bio = 'Productivity enthusiast & task master',
    this.avatarUrl = 'https://i.pravatar.cc/150?img=3',
  });

  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? bio,
    String? avatarUrl,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'bio': bio,
      'avatarUrl': avatarUrl,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      bio: map['bio'] ?? 'Productivity enthusiast & task master',
      avatarUrl: map['avatarUrl'] ?? 'https://i.pravatar.cc/150?img=3',
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));
}
