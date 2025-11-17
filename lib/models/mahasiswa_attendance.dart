class MahasiswaAttendance {
  final String id;
  final String mahasiswaId;
  final String nama;
  final String mataKuliah;
  final String sessionId;
  final String dosen;
  final String tanggal;
  final String waktu;
  final String status;

  MahasiswaAttendance({
    required this.id,
    required this.mahasiswaId,
    required this.nama,
    required this.mataKuliah,
    required this.sessionId,
    required this.dosen,
    required this.tanggal,
    required this.waktu,
    required this.status,
  });

  factory MahasiswaAttendance.fromJson(Map<String, dynamic> json) {
    return MahasiswaAttendance(
      id: json['id'] ?? '',
      mahasiswaId: json['mahasiswa_id'] ?? '',
      nama: json['nama'] ?? '',
      mataKuliah: json['mata_kuliah'] ?? '',
      sessionId: json['session_id'] ?? '',
      dosen: json['dosen'] ?? '',
      tanggal: json['tanggal'] ?? '',
      waktu: json['waktu'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mahasiswa_id': mahasiswaId,
      'nama': nama,
      'mata_kuliah': mataKuliah,
      'session_id': sessionId,
      'dosen': dosen,
      'tanggal': tanggal,
      'waktu': waktu,
      'status': status,
    };
  }
}