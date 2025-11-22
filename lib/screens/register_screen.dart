import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';

import '../services/api_service.dart';
import '../services/face_storage_service.dart';
import '../models/face_data.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late CameraController _cameraController;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nimController = TextEditingController();
  final TextEditingController _nidnController = TextEditingController();
  final TextEditingController _mataKuliahController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  bool _isCameraInitialized = false;
  bool _isProcessing = false;

  XFile? _selectedImage;
  String selectedRole = "mahasiswa"; // default

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();

      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras[0],
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
      );

      await _cameraController.initialize();

      setState(() => _isCameraInitialized = true);
    } catch (e) {
      _showSnackBar("Kamera gagal diinisialisasi", false);
    }
  }

  Future<void> _captureImage() async {
    try {
      final image = await _cameraController.takePicture();
      setState(() => _selectedImage = image);
    } catch (e) {
      _showSnackBar("Gagal mengambil foto", false);
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _selectedImage = image);
      }
    } catch (e) {
      _showSnackBar("Gagal memilih foto", false);
    }
  }

  Future<void> _registerFace() async {
    if (_nameController.text.isEmpty) {
      _showSnackBar("Nama wajib diisi", false);
      return;
    }

    if (selectedRole == "mahasiswa" && _nimController.text.isEmpty) {
      _showSnackBar("NIM wajib diisi untuk Mahasiswa", false);
      return;
    }

    if (selectedRole == "dosen" &&
        (_nidnController.text.isEmpty || _mataKuliahController.text.isEmpty)) {
      _showSnackBar("NIDN & Mata Kuliah wajib diisi untuk Dosen", false);
      return;
    }

    if (_selectedImage == null) {
      _showSnackBar("Ambil/pilih foto terlebih dahulu", false);
      return;
    }

    if (_emailController.text.isEmpty) {
      _showSnackBar("Email wajib diisi", false);
      return;
    }

    if (_passwordController.text.isEmpty) {
      _showSnackBar("Password wajib diisi", false);
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final imageBytes = await _selectedImage!.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      // ===== Simpan lokal JSON =====
      final faceData = FaceData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nama: _nameController.text,
        imageBase64: base64Image,
        createdAt: DateTime.now(),
      );

      await FaceStorageService.saveFaceData(faceData);

      // ===== Kirim ke API sesuai role =====
      Map<String, dynamic> result;

      if (selectedRole == "mahasiswa") {
        result = await ApiService.registerMahasiswa(
          _nameController.text,
          _nimController.text,
          _emailController.text,
          _passwordController.text,
          base64Image,
        );
      } else {
        result = await ApiService.registerDosen(
          _nameController.text,
          _nidnController.text,
          _emailController.text,
          _passwordController.text,
          _mataKuliahController.text,
          base64Image,
        );
      }

      if (result["success"] == true) {
        _showSnackBar("Registrasi berhasil!", true);

        await Future.delayed(const Duration(seconds: 2));
        Navigator.pop(context);
      } else {
        _showSnackBar(result["message"] ?? "Registrasi gagal", false);
      }
    } catch (e) {
      _showSnackBar("Terjadi error: $e", false);
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showSnackBar(String message, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _nameController.dispose();
    _nimController.dispose();
    _nidnController.dispose();
    _mataKuliahController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registrasi User")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ================= ROLE DROPDOWN =================
            DropdownButtonFormField<String>(
              value: selectedRole,
              items: const [
                DropdownMenuItem(value: "mahasiswa", child: Text("Mahasiswa")),
                DropdownMenuItem(value: "dosen", child: Text("Dosen")),
              ],
              onChanged: (v) => setState(() => selectedRole = v!),
              decoration: InputDecoration(
                labelText: "Pilih Role",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // ================= CAMERA / IMAGE =================
            _selectedImage != null
                ? Image.file(
                    File(_selectedImage!.path),
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                  )
                : _isCameraInitialized
                    ? SizedBox(
                        width: double.infinity,
                        height: 300,
                        child: CameraPreview(_cameraController),
                      )
                    : const CircularProgressIndicator(),

            const SizedBox(height: 16),

            if (_selectedImage == null)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _captureImage,
                      icon: Icon(Icons.camera_alt),
                      label: Text("Ambil Foto"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickImageFromGallery,
                      icon: Icon(Icons.image),
                      label: Text("Galeri"),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 20),

            // ================= FORM NAMA =================
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Nama Lengkap",
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // ================= FORM MAHASISWA =================
            if (selectedRole == "mahasiswa") ...[
              TextField(
                controller: _nimController,
                decoration: InputDecoration(
                  labelText: "NIM Mahasiswa",
                  prefixIcon: Icon(Icons.badge),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ================= FORM DOSEN =================
            if (selectedRole == "dosen") ...[
              TextField(
                controller: _nidnController,
                decoration: InputDecoration(
                  labelText: "NIDN Dosen",
                  prefixIcon: Icon(Icons.badge),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _mataKuliahController,
                decoration: InputDecoration(
                  labelText: "Mata Kuliah",
                  prefixIcon: Icon(Icons.book),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ================= EMAIL & PASSWORD (SEMUA ROLE) =================
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Email",
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: "Password",
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),

            const SizedBox(height: 24),

            // ================= BUTTON REGISTER =================
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _registerFace,
                child: _isProcessing
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Daftar User"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
