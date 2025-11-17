class User {
  final String id;
  final String nama;
  final String email;
  final String role;
  final String? nim;
  final String? nidn;
  final String? mataKuliah;
  final DateTime createdAt;

  User({
    required this.id,
    required this.nama,
    required this.email,
    required this.role,
    this.nim,
    this.nidn,
    this.mataKuliah,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      nama: json['nama'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      nim: json['nim'],
      nidn: json['nidn'],
      mataKuliah: json['mata_kuliah'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
      'role': role,
      'nim': nim,
      'nidn': nidn,
      'mata_kuliah': mataKuliah,
      'created_at': createdAt.toIso8601String(),
    };
  }
}