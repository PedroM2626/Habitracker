class UserModel {
  final String uid;
  final String email;
  final String name;
  final String? bio;
  final String? photoUrl;
  final int totalXp;
  final int level;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.bio,
    this.photoUrl,
    this.totalXp = 0,
    this.level = 1,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      bio: map['bio'],
      photoUrl: map['photoUrl'],
      totalXp: map['totalXp'] ?? 0,
      level: map['level'] ?? 1,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'bio': bio,
      'photoUrl': photoUrl,
      'totalXp': totalXp,
      'level': level,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? email,
    String? name,
    String? bio,
    String? photoUrl,
    int? totalXp,
    int? level,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid,
      email: email ?? this.email,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      photoUrl: photoUrl ?? this.photoUrl,
      totalXp: totalXp ?? this.totalXp,
      level: level ?? this.level,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}