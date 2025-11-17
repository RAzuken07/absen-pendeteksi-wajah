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
  final ImagePicker _imagePicker = ImagePicker();
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  XFile? _selectedImage;
  String? _statusMessage;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        // Cari kamera depan (front camera)
        final frontCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => cameras[
              0], // Fallback ke kamera pertama jika tidak ada front camera
        );

        _cameraController = CameraController(
          frontCamera,
          ResolutionPreset.medium,
        );

        await _cameraController.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      _showSnackBar('Gagal menginisialisasi kamera: $e', false);
    }
  }

  Future<void> _captureImage() async {
    try {
      final image = await _cameraController.takePicture();
      if (mounted) {
        setState(() => _selectedImage = image);
      }
    } catch (e) {
      _showSnackBar('Error: $e', false);
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null && mounted) {
        setState(() => _selectedImage = image);
      }
    } catch (e) {
      _showSnackBar('Error: $e', false);
    }
  }

  Future<void> _registerFace() async {
    if (_nameController.text.isEmpty) {
      _showSnackBar('Masukkan nama terlebih dahulu', false);
      return;
    }

    if (_selectedImage == null) {
      _showSnackBar('Ambil/pilih foto terlebih dahulu', false);
      return;
    }

    try {
      setState(() => _isProcessing = true);

      final imageBytes = await _selectedImage!.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      // Simpan ke JSON lokal
      final faceData = FaceData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nama: _nameController.text,
        imageBase64: base64Image,
        createdAt: DateTime.now(),
      );

      final savedToJson = await FaceStorageService.saveFaceData(faceData);

      // Kirim ke API
      final result = await ApiService.registerFace(
        _nameController.text,
        base64Image,
      );

      if (mounted) {
        if (result['success'] == true || savedToJson) {
          setState(() {
            _statusMessage = 'Registrasi berhasil!';
            _isSuccess = true;
          });

          _showSnackBar(
            'User ${_nameController.text} berhasil didaftarkan',
            true,
          );

          await Future.delayed(const Duration(seconds: 2));
          if (mounted) {
            Navigator.pop(context);
          }
        } else {
          _showSnackBar(
            result['message'] ?? 'Registrasi gagal',
            false,
          );
        }
      }
    } catch (e) {
      _showSnackBar('Error: $e', false);
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showSnackBar(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _resetForm() {
    setState(() {
      _nameController.clear();
      _selectedImage = null;
      _statusMessage = null;
      _isSuccess = false;
    });
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrasi Wajah'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Preview Image
              if (_selectedImage != null)
                Card(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      File(_selectedImage!.path),
                      width: double.infinity,
                      height: 300,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else if (_isCameraInitialized)
                Card(
                  child: SizedBox(
                    width: double.infinity,
                    height: 300,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CameraPreview(_cameraController),
                    ),
                  ),
                )
              else
                Card(
                  child: SizedBox(
                    width: double.infinity,
                    height: 300,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // Camera Controls
              if (_selectedImage == null)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _captureImage,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Ambil Foto'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _pickImageFromGallery,
                        icon: const Icon(Icons.image),
                        label: const Text('Pilih Galeri'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 20),

              // Name Input
              TextField(
                controller: _nameController,
                enabled: !_isProcessing,
                decoration: InputDecoration(
                  labelText: 'Nama Pengguna',
                  prefixIcon: const Icon(Icons.person),
                  hintText: 'Masukkan nama lengkap',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              if (_selectedImage != null)
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isProcessing ? null : _registerFace,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          disabledBackgroundColor: Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isProcessing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Daftar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: _isProcessing ? null : _resetForm,
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Batal'),
                      ),
                    ),
                  ],
                ),

              // Status Message
              if (_statusMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _isSuccess
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isSuccess
                            ? Colors.green.withOpacity(0.5)
                            : Colors.red.withOpacity(0.5),
                      ),
                    ),
                    child: Text(
                      _statusMessage ?? '',
                      style: TextStyle(
                        color: _isSuccess ? Colors.green : Colors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
