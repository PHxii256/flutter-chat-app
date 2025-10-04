class User {
  final String id;
  final String email;
  final String username;
  final String? profilePic;

  User({required this.id, required this.email, required this.username, this.profilePic});

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] ?? '',
    email: json['email'] ?? '',
    username: json['username'] ?? '',
    profilePic: json['profilePic'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'username': username,
    'profilePic': profilePic,
  };
}
