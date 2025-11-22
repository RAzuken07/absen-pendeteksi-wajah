import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.91.229.67:5000/api';

  // Health check
  static Future<Map<String, dynamic>> checkHealth() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health'));
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Register face
  static Future<Map<String, dynamic>> registerFace(
      String nama, String imageBase64) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nama': nama,
          'image': imageBase64,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: ${e.toString()}'};
    }
  }

  // Recognize face
  static Future<Map<String, dynamic>> recognizeFace(String imageBase64) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/recognize'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'image': imageBase64}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: ${e.toString()}'};
    }
  }

  // Get attendance
  static Future<Map<String, dynamic>> getAttendance(String date) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/attendance?date=$date'),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: ${e.toString()}'};
    }
  }

  // Get users
  static Future<Map<String, dynamic>> getUsers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users'));
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: ${e.toString()}'};
    }
  }

  // Get stats
  static Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/stats'));
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: ${e.toString()}'};
    }
  }

  // LOGIN
  static Future<Map<String, dynamic>> login(
      String email, String password, String role) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'role': role,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: ${e.toString()}'};
    }
  }

  // START ABSENSI DOSEN
  static Future<Map<String, dynamic>> startDosenAttendance(String dosenId,
      String dosenName, String mataKuliah, String imageBase64) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/dosen/start-attendance'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'dosen_id': dosenId,
          'dosen_name': dosenName,
          'mata_kuliah': mataKuliah,
          'image': imageBase64,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: ${e.toString()}'};
    }
  }

  // ABSENSI MAHASISWA
  static Future<Map<String, dynamic>> mahasiswaAttendance(String mahasiswaId,
      String sessionId, String barcodeData, String imageBase64) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mahasiswa/attendance'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'mahasiswa_id': mahasiswaId,
          'session_id': sessionId,
          'barcode_data': barcodeData,
          'image': imageBase64,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: ${e.toString()}'};
    }
  }

  // REGISTER MAHASISWA - uses the general register endpoint
  static Future<Map<String, dynamic>> registerMahasiswa(String nama, String nim,
      String email, String password, String imageBase64) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nama': nama,
          'nim': nim,
          'email': email,
          'password': password,
          'image': imageBase64,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // REGISTER DOSEN - uses the register-dosen endpoint
  static Future<Map<String, dynamic>> registerDosen(
      String nama,
      String nidn,
      String email,
      String password,
      String mataKuliah,
      String imageBase64) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register-dosen'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nama': nama,
          'nidn': nidn,
          'email': email,
          'password': password,
          'mata_kuliah': mataKuliah,
          'image': imageBase64,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
