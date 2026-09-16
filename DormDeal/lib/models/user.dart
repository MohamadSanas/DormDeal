class User {
  final String id;
  final String name;
  final String email;
  final String? whatsappNumber;
  final String? university;
  final String? avatarUrl;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.whatsappNumber,
    this.university,
    this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      whatsappNumber: json['whatsapp_number'],
      university: json['university'],
      avatarUrl: json['avatar_url'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'whatsapp_number': whatsappNumber,
    'university': university,
    'avatar_url': avatarUrl,
  };
}
