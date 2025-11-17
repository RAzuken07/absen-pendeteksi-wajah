# Face Storage Service - Dokumentasi

## 📋 Daftar Isi
- [Pengenalan](#pengenalan)
- [Fitur](#fitur)
- [Cara Kerja](#cara-kerja)
- [Integrasi](#integrasi)
- [Contoh Penggunaan](#contoh-penggunaan)

## Pengenalan

`FaceStorageService` adalah service untuk menyimpan dan mengelola data wajah dalam format JSON di perangkat lokal. Semua data wajah yang didaftarkan akan disimpan secara otomatis ke file `faces_data.json` di directory documents aplikasi.

## Fitur

✅ **Menyimpan Data Wajah**
- Simpan nama, ID, base64 image, dan timestamp

✅ **Membaca Data Wajah**
- Ambil semua data wajah dari JSON
- Cari wajah berdasarkan nama

✅ **Menghapus Data Wajah**
- Hapus wajah berdasarkan nama
- Hapus semua wajah sekaligus

✅ **Export & Import**
- Export semua data ke format JSON string
- Debugging dan monitoring

## Cara Kerja

### File Penyimpanan
- **Lokasi**: `AppDocumentsDirectory/faces_data.json`
- **Format**: JSON Array
- **Struktur Data**:
```json
[
  {
    "id": "1234567890",
    "nama": "John Doe",
    "imageBase64": "iVBORw0KGgoAAAANSUhEUgAAA...",
    "createdAt": "2025-11-12T10:30:45.123456"
  }
]
```

## Integrasi

### 1. Import Service
```dart
import '../services/face_storage_service.dart';
import '../model/face_data.dart';
```

### 2. Menyimpan Data Wajah
Data wajah otomatis disimpan saat registrasi di `RegisterScreen`:
```dart
final faceData = FaceData(
  id: DateTime.now().millisecondsSinceEpoch.toString(),
  nama: _nameController.text,
  imageBase64: base64Image,
  createdAt: DateTime.now(),
);

final savedToJson = await FaceStorageService.saveFaceData(faceData);
```

## Contoh Penggunaan

### Mendapatkan Semua Data Wajah
```dart
final faces = await FaceStorageService.getAllFaces();
for (final face in faces) {
  print('${face.nama} - ${face.createdAt}');
}
```

### Mencari Wajah Berdasarkan Nama
```dart
final face = await FaceStorageService.getFaceByName('John Doe');
if (face != null) {
  print('Wajah ditemukan: ${face.nama}');
}
```

### Menghapus Wajah
```dart
final success = await FaceStorageService.deleteFace('John Doe');
if (success) {
  print('Wajah berhasil dihapus');
}
```

### Menampilkan Data yang Tersimpan (Debug)
```dart
import '../services/face_storage_debugger.dart';

FaceStorageDebugger.showStoredFaces(context);
```

### Export Data ke JSON
```dart
final jsonData = await FaceStorageService.exportFacesAsJson();
print(jsonData);
```

### Mendapatkan Jumlah Data
```dart
final count = await FaceStorageService.getFaceCount();
print('Total wajah tersimpan: $count');
```

### Mendapatkan Path File
```dart
final filePath = await FaceStorageService.getFilePath();
print('File disimpan di: $filePath');
```

## Method Reference

| Method | Parameter | Return | Deskripsi |
|--------|-----------|--------|-----------|
| `saveFaceData()` | FaceData | Future<bool> | Simpan atau update data wajah |
| `getAllFaces()` | - | Future<List<FaceData>> | Ambil semua data wajah |
| `getFaceByName()` | String nama | Future<FaceData?> | Cari wajah berdasarkan nama |
| `deleteFace()` | String nama | Future<bool> | Hapus wajah berdasarkan nama |
| `clearAllFaces()` | - | Future<bool> | Hapus semua wajah |
| `getFilePath()` | - | Future<String> | Dapatkan path file penyimpanan |
| `exportFacesAsJson()` | - | Future<String> | Export ke JSON string |
| `getFaceCount()` | - | Future<int> | Hitung jumlah wajah |

## Catatan

⚠️ **Penting**:
- Data wajah disimpan dalam format base64 yang cukup besar
- Pastikan perangkat memiliki ruang penyimpanan yang cukup
- Base64 image tidak terenkripsi, pertimbangkan enkripsi untuk data sensitif di production
- Data tersimpan di directory documents, akan terhapus jika app diuninstall
