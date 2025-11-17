import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import '../models/face_data.dart';

class FaceStorageService {
  static const String fileName = 'faces_data.json';

  // Get the file path
  static Future<File> _getFaceFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$fileName');
  }

  // Save face data to JSON
  static Future<bool> saveFaceData(FaceData faceData) async {
    try {
      final file = await _getFaceFile();

      // Read existing data
      List<FaceData> facesList = await getAllFaces();

      // Check if user already exists
      final existingIndex =
          facesList.indexWhere((face) => face.nama == faceData.nama);
      if (existingIndex != -1) {
        // Update existing face
        facesList[existingIndex] = faceData;
      } else {
        // Add new face
        facesList.add(faceData);
      }

      // Convert to JSON
      final jsonData = jsonEncode(
        facesList.map((face) => face.toJson()).toList(),
      );

      // Write to file
      await file.writeAsString(jsonData);
      return true;
    } catch (e) {
      print('Error saving face data: $e');
      return false;
    }
  }

  // Get all faces from JSON
  static Future<List<FaceData>> getAllFaces() async {
    try {
      final file = await _getFaceFile();

      if (!await file.exists()) {
        return [];
      }

      final contents = await file.readAsString();
      if (contents.isEmpty) {
        return [];
      }

      final jsonData = jsonDecode(contents) as List;
      return jsonData.map((face) => FaceData.fromJson(face)).toList();
    } catch (e) {
      print('Error reading face data: $e');
      return [];
    }
  }

  // Get face by name
  static Future<FaceData?> getFaceByName(String nama) async {
    try {
      final faces = await getAllFaces();
      for (final face in faces) {
        if (face.nama == nama) {
          return face;
        }
      }
      return null;
    } catch (e) {
      print('Error getting face by name: $e');
      return null;
    }
  }

  // Delete face by name
  static Future<bool> deleteFace(String nama) async {
    try {
      final file = await _getFaceFile();
      List<FaceData> facesList = await getAllFaces();

      // Remove the face
      facesList.removeWhere((face) => face.nama == nama);

      // Write back to file
      final jsonData = jsonEncode(
        facesList.map((face) => face.toJson()).toList(),
      );
      await file.writeAsString(jsonData);
      return true;
    } catch (e) {
      print('Error deleting face data: $e');
      return false;
    }
  }

  // Clear all faces
  static Future<bool> clearAllFaces() async {
    try {
      final file = await _getFaceFile();
      if (await file.exists()) {
        await file.delete();
      }
      return true;
    } catch (e) {
      print('Error clearing face data: $e');
      return false;
    }
  }

  // Get file path for debugging
  static Future<String> getFilePath() async {
    final file = await _getFaceFile();
    return file.path;
  }

  // Export all faces to JSON string
  static Future<String> exportFacesAsJson() async {
    try {
      final faces = await getAllFaces();
      return jsonEncode(
        faces.map((face) => face.toJson()).toList(),
      );
    } catch (e) {
      print('Error exporting faces: $e');
      return '[]';
    }
  }

  // Get total face count
  static Future<int> getFaceCount() async {
    final faces = await getAllFaces();
    return faces.length;
  }
}
