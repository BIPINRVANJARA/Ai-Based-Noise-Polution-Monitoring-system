class UserProfile {
  final String userId;
  final String name;
  final String email;
  final String role;
  final String? organization;
  final String? photoUrl;

  UserProfile({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    this.organization,
    this.photoUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      organization: json['organization'] as String?,
      photoUrl: json['photoUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'role': role,
      'organization': organization,
      'photoUrl': photoUrl,
    };
  }
}
