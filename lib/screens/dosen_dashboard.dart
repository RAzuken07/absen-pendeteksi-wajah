import 'package:flutter/material.dart';
import 'dosen_attendance_session.dart';
import '../models/user.dart';

class DosenDashboard extends StatelessWidget {
  final User user;

  const DosenDashboard({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Dosen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      child: Icon(Icons.school, size: 30),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.nama,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'NIDN: ${user.nidn ?? '-'}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          Text(
                            'Mata Kuliah: ${user.mataKuliah ?? '-'}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Quick Actions
            const Text(
              'Menu Cepat',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildMenuCard(
                  icon: Icons.qr_code_scanner,
                  title: 'Mulai Absen',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DosenAttendanceSession(user: user),
                      ),
                    );
                  },
                ),
                _buildMenuCard(
                  icon: Icons.history,
                  title: 'Riwayat Absen',
                  color: Colors.orange,
                  onTap: () {
                    // Navigate to attendance history
                  },
                ),
                _buildMenuCard(
                  icon: Icons.people,
                  title: 'Data Mahasiswa',
                  color: Colors.green,
                  onTap: () {
                    // Navigate to students list
                  },
                ),
                _buildMenuCard(
                  icon: Icons.bar_chart,
                  title: 'Statistik',
                  color: Colors.purple,
                  onTap: () {
                    // Navigate to statistics
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}