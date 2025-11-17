import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:convert';
import '../models/user.dart';
import '../services/api_service.dart';

class MahasiswaFaceAttendance extends StatefulWidget {
  final User user;
  final String barcodeData;
  final Map<String, dynamic> sessionData;

  const MahasiswaFaceAttendance({
    Key? key,
    required this.user,
    required this.barcodeData,
    required this.sessionData,
  }) : super(key: key);

  @override
  State<MahasiswaFaceAttendance> createState() => _MahasiswaFaceAttendanceState();
}

class _MahasiswaFaceAttendanceState extends State<MahasiswaFaceAttendance> {
  late CameraController _cameraController;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  String? _statusMessage;
  bool _isSuccess = false;
  Map<String, dynamic>? _attendanceResult;

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

  Future<void> _captureAndVerifyFace() async {
    if (_isProcessing || !_isCameraInitialized) return;

    try {
      setState(() => _isProcessing = true);

      final image = await _cameraController.takePicture();
      final imageBytes = await image.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      // Kirim ke API untuk absensi
      final result = await ApiService.mahasiswaAttendance(
        widget.user.id,
        widget.sessionData['session_id'],
        widget.barcodeData,
        base64Image,
      );

      if (mounted) {
        if (result['success'] == true) {
          setState(() {
            _attendanceResult = result['data'];
            _statusMessage = result['message'] ?? 'Absensi berhasil!';
            _isSuccess = true;
          });

          // Auto kembali ke dashboard setelah 3 detik
          await Future.delayed(const Duration(seconds: 3));
          if (mounted) {
            Navigator.popUntil(context, (route) => route.isFirst);
          }
        } else {
          _showMessage(result['message'] ?? 'Absensi gagal', false);
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

  Widget _buildSessionInfo() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Sesi Absen',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Mata Kuliah', widget.sessionData['mata_kuliah']),
            _buildInfoRow('Dosen', widget.sessionData['dosen_name']),
            _buildInfoRow('Session ID', widget.sessionData['session_id']),
            _buildInfoRow('Waktu', 
              DateTime.parse(widget.sessionData['timestamp']).toLocal().toString().split('.')[0]
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 80,
            ),
            const SizedBox(height: 20),
            Text(
              _statusMessage ?? 'Absensi Berhasil!',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (_attendanceResult != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      _attendanceResult!['nama'] ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Mata Kuliah: ${_attendanceResult!['mata_kuliah'] ?? ''}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      'Waktu: ${_attendanceResult!['waktu'] ?? ''}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 10),
            const Text(
              'Kembali ke dashboard...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
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
        title: const Text('Verifikasi Wajah'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildSessionInfo(),
          
          Expanded(
            child: Stack(
              children: [
                if (_isCameraInitialized && !_isSuccess)
                  CameraPreview(_cameraController),
                
                if (_isSuccess)
                  _buildSuccessView(),

                // Overlay guide
                if (!_isSuccess && _isCameraInitialized)
                  Positioned(
                    top: 20,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.black.withOpacity(0.6),
                      child: const Text(
                        'Posisikan wajah di tengah layar untuk verifikasi',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Bottom control
          if (!_isSuccess)
            Container(
              padding: const EdgeInsets.all(24),
              color: Colors.white,
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _captureAndVerifyFace,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
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
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Ambil Foto & Absen',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),

          // Status message
          if (_statusMessage != null && !_isSuccess)
            Container(
              padding: const EdgeInsets.all(16),
              color: _isSuccess 
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              child: Text(
                _statusMessage!,
                style: TextStyle(
                  color: _isSuccess ? Colors.green : Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}