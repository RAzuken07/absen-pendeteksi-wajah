import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:convert';
import '../services/api_service.dart';
import '../models/user.dart';

class DosenAttendanceSession extends StatefulWidget {
  final User user;

  const DosenAttendanceSession({Key? key, required this.user}) : super(key: key);

  @override
  State<DosenAttendanceSession> createState() => _DosenAttendanceSessionState();
}

class _DosenAttendanceSessionState extends State<DosenAttendanceSession> {
  late CameraController _cameraController;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  Map<String, dynamic>? _sessionData;
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
        final frontCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => cameras[0],
        );

        _cameraController = CameraController(
          frontCamera,
          ResolutionPreset.medium,
        );

        await _cameraController.initialize();
        if (mounted) {
          setState(() => _isCameraInitialized = true);
        }
      }
    } catch (e) {
      _showMessage('Gagal menginisialisasi kamera: $e', false);
    }
  }

  Future<void> _startAttendanceSession() async {
    if (_isProcessing || !_isCameraInitialized) return;

    try {
      setState(() => _isProcessing = true);

      final image = await _cameraController.takePicture();
      final imageBytes = await image.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      final result = await ApiService.startDosenAttendance(
        widget.user.id,
        widget.user.nama,
        widget.user.mataKuliah ?? 'Mata Kuliah',
        base64Image,
      );

      if (mounted) {
        if (result['success'] == true) {
          setState(() {
            _sessionData = result['data'];
            _statusMessage = 'Sesi absen berhasil dimulai!';
            _isSuccess = true;
          });
        } else {
          _showMessage(result['message'] ?? 'Gagal memulai sesi absen', false);
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
        title: const Text('Mulai Sesi Absen'),
      ),
      body: Column(
        children: [
          if (_sessionData == null) ...[
            Expanded(
              child: _isCameraInitialized
                  ? Stack(
                      children: [
                        CameraPreview(_cameraController),
                        // Overlay guide
                        Positioned(
                          top: 20,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            color: Colors.black.withOpacity(0.6),
                            child: const Text(
                              'Verifikasi wajah dosen untuk memulai sesi absen',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    )
                  : const Center(child: CircularProgressIndicator()),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _startAttendanceSession,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: _isProcessing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Verifikasi & Mulai Sesi Absen',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ),
          ] else ...[
            // Tampilkan QR Code
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 80,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Sesi Absen Aktif!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Mata Kuliah: ${widget.user.mataKuliah}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 32),
                    
                    // QR Code
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Scan QR Code untuk absen:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Image.memory(
                            base64Decode(_sessionData!['qr_code'].split(',').last),
                            width: 200,
                            height: 200,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Session ID: ${_sessionData!['session_id']}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    const Text(
                      'Berikan QR code ini kepada mahasiswa untuk melakukan absensi',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
          
          if (_statusMessage != null && !_isSuccess)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.red.withOpacity(0.1),
              child: Text(
                _statusMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}