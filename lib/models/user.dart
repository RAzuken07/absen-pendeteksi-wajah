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

  // Fungsi yang aman untuk handle String / List / null
  static String? parseToString(dynamic value) {
    if (value == null) return null;

    // Kalau List -> ambil item pertama
    if (value is List) {
      if (value.isEmpty) return null;
      return value.first.toString();
    }

    // Kalau String -> langsung
    if (value is String) return value;

    // Jenis lain -> konversi ke string
    return value.toString();
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: parseToString(json['id']) ?? '',
      nama: parseToString(json['nama']) ?? '',
      email: parseToString(json['email']) ?? '',
      role: parseToString(json['role']) ?? '',
      nim: parseToString(json['nim']),
      nidn: parseToString(json['nidn']),
      mataKuliah: parseToString(json['mata_kuliah']),
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
