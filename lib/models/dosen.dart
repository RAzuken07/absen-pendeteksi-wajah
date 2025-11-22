class DosenModel {
  final int id;
  final String nama;
  final String email;
  final String nip;

  DosenModel({
    required this.id,
    required this.nama,
    required this.email,
    required this.nip,
  });

  factory DosenModel.fromJson(Map<String, dynamic> json) {
    return DosenModel(
      id: json['id'],
      nama: json['nama'],
      email: json['email'],
      nip: json['nip'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "nama": nama,
      "email": email,
      "nip": nip,
    };
  }
}
