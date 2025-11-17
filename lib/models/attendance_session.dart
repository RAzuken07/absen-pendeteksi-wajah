class AttendanceSession {
  final String id;
  final String dosenId;
  final String dosenName;
  final String mataKuliah;
  final DateTime tanggal;
  final String waktuMulai;
  final String barcodeData;
  final bool isActive;

  AttendanceSession({
    required this.id,
    required this.dosenId,
    required this.dosenName,
    required this.mataKuliah,
    required this.tanggal,
    required this.waktuMulai,
    required this.barcodeData,
    required this.isActive,
  });

  factory AttendanceSession.fromJson(Map<String, dynamic> json) {
    return AttendanceSession(
      id: json['id'] ?? '',
      dosenId: json['dosen_id'] ?? '',
      dosenName: json['dosen_name'] ?? '',
      mataKuliah: json['mata_kuliah'] ?? '',
      tanggal: DateTime.parse(json['tanggal']),
      waktuMulai: json['waktu_mulai'] ?? '',
      barcodeData: json['barcode_data'] ?? '',
      isActive: json['is_active'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dosen_id': dosenId,
      'dosen_name': dosenName,
      'mata_kuliah': mataKuliah,
      'tanggal': tanggal.toIso8601String(),
      'waktu_mulai': waktuMulai,
      'barcode_data': barcodeData,
      'is_active': isActive,
    };
  }
}