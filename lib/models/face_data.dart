class FaceData {
  final String id;
  final String nama;
  final String imageBase64;
  final DateTime createdAt;

  FaceData({
    required this.id,
    required this.nama,
    required this.imageBase64,
    required this.createdAt,
  });

  factory FaceData.fromJson(Map<String, dynamic> json) {
    return FaceData(
      id: json['id'] ?? '',
      nama: json['nama'] ?? '',
      imageBase64: json['imageBase64'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'imageBase64': imageBase64,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
