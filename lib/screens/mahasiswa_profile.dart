import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class MahasiswaProfile extends StatefulWidget {
  final User user;

  const MahasiswaProfile({Key? key, required this.user}) : super(key: key);

  @override
  State<MahasiswaProfile> createState() => _MahasiswaProfileState();
}

class _MahasiswaProfileState extends State<MahasiswaProfile> {
  int _totalAttendance = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAttendanceStats();
  }

  Future<void> _loadAttendanceStats() async {
    try {
      final result = await ApiService.getAttendance('all');

      if (result['success'] == true && mounted) {
        final allAttendance = result['data'] ?? [];
        final myAttendance = allAttendance.where((attendance) {
          return attendance['nama']?.toLowerCase() ==
              widget.user.nama.toLowerCase();
        }).length;

        setState(() {
          _totalAttendance = myAttendance;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.green, Colors.green.shade700],
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: const Icon(
              Icons.person,
              size: 50,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.user.nama,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.user.nim?.isNotEmpty == true
                ? 'NIM: ${widget.user.nim}'
                : 'Mahasiswa',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Statistik Absensi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Total Absen', _totalAttendance.toString(),
                    Icons.check_circle),
                _buildStatItem('Status', 'Aktif', Icons.person),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.green, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Akun',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('ID', widget.user.id),
            _buildInfoRow('Nama', widget.user.nama),
            if (widget.user.nim?.isNotEmpty == true)
              _buildInfoRow('NIM', widget.user.nim!),
            _buildInfoRow('Email', widget.user.email),
            _buildInfoRow('Role', widget.user.role),
            _buildInfoRow('Terdaftar',
                widget.user.createdAt.toLocal().toString().split('.')[0]),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Mahasiswa'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildProfileHeader(),
                  _buildStatsCard(),
                  _buildInfoSection(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
