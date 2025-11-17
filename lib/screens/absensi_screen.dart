import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:convert';
import '../services/api_service.dart';

class AbsensiScreen extends StatefulWidget {
  const AbsensiScreen({Key? key}) : super(key: key);

  @override
  State<AbsensiScreen> createState() => _AbsensiScreenState();
}

class _AbsensiScreenState extends State<AbsensiScreen> {
  late CameraController _cameraController;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  String? _recognitionResult;
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
      _showMessage('Gagal menginisialisasi kamera: $e', false);
    }
  }

  Future<void> _captureAndRecognize() async {
    if (_isProcessing || !_isCameraInitialized) return;

    try {
      setState(() => _isProcessing = true);

      final image = await _cameraController.takePicture();
      final imageBytes = await image.readAsBytes();

      // Convert to base64
      final base64Image = base64Encode(imageBytes);

      // Send to API
      final result = await ApiService.recognizeFace(base64Image);

      if (mounted) {
        if (result['success'] == true) {
          // Handle data response
          String nama = 'Unknown';

          if (result['data'] != null) {
            final data = result['data'];

            // Jika data adalah List, ambil elemen pertama
            if (data is List && data.isNotEmpty) {
              nama = data[0]?['nama'] ?? 'Unknown';
            }
            // Jika data adalah Map, ambil langsung
            else if (data is Map) {
              nama = data['nama'] ?? 'Unknown';
            }
            // Jika data adalah String
            else if (data is String) {
              nama = data;
            }
          }

          setState(() {
            _recognitionResult = nama;
            _statusMessage = 'Absensi berhasil: ${_recognitionResult}';
            _isSuccess = true;
          });

          // Auto-dismiss after 3 seconds
          await Future.delayed(const Duration(seconds: 3));
          if (mounted) {
            Navigator.pop(context);
          }
        } else {
          _showMessage(result['message'] ?? 'Wajah tidak dikenali', false);
        }
      }
    } catch (e) {
      _showMessage('Error: $e', false);
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showMessage(String message, bool isSuccess) {
    setState(() {
      _statusMessage = message;
      _isSuccess = isSuccess;
    });

    if (!isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Absensi Wajah'),
        elevation: 0,
      ),
      body: _isCameraInitialized
          ? Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      // Camera Preview
                      CameraPreview(_cameraController),

                      // Success overlay
                      if (_isSuccess)
                        Container(
                          color: Colors.black.withOpacity(0.3),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 80,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  _statusMessage ?? '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Guide text
                      if (!_isSuccess)
                        Positioned(
                          top: 20,
                          left: 20,
                          right: 20,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Posisikan wajah di tengah layar\nTekan tombol untuk absensi',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Bottom control panel
                Container(
                  padding: const EdgeInsets.all(24),
                  color: Colors.white,
                  child: Column(
                    children: [
                      if (_statusMessage != null && !_isSuccess)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.red.withOpacity(0.5),
                              ),
                            ),
                            child: Text(
                              _statusMessage ?? '',
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed:
                              _isProcessing ? null : _captureAndRecognize,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            disabledBackgroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isProcessing
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Ambil Foto untuk Absensi',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
