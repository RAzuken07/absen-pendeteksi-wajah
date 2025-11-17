import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class MahasiswaAttendanceHistory extends StatefulWidget {
  final User user;

  const MahasiswaAttendanceHistory({Key? key, required this.user}) : super(key: key);

  @override
  State<MahasiswaAttendanceHistory> createState() => _MahasiswaAttendanceHistoryState();
}

class _MahasiswaAttendanceHistoryState extends State<MahasiswaAttendanceHistory> {
  List<dynamic> _attendanceHistory = [];
  bool _isLoading = true;
  String _selectedFilter = 'all'; // 'all', 'today', 'week', 'month'

  @override
  void initState() {
    super.initState();
    _loadAttendanceHistory();
  }

  Future<void> _loadAttendanceHistory() async {
    setState(() => _isLoading = true);

    try {
      final result = await ApiService.getAttendance('all');
      
      if (mounted && result['success'] == true) {
        final allAttendance = result['data'] ?? [];
        
        // Filter attendance untuk mahasiswa ini
        final myAttendance = allAttendance.where((attendance) {
          return attendance['nama']?.toLowerCase() == widget.user.nama.toLowerCase();
        }).toList();

        // Apply additional filters
        List<dynamic> filteredAttendance = _applyFilter(myAttendance);
        
        setState(() {
          _attendanceHistory = filteredAttendance;
          _isLoading = false;
        });
      } else {
        setState(() {
          _attendanceHistory = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _attendanceHistory = [];
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat riwayat: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<dynamic> _applyFilter(List<dynamic> attendance) {
    final now = DateTime.now();
    
    switch (_selectedFilter) {
      case 'today':
        final today = now.toString().split(' ')[0];
        return attendance.where((a) => a['tanggal'] == today).toList();
      case 'week':
        final weekAgo = now.subtract(const Duration(days: 7));
        return attendance.where((a) {
          final attendanceDate = DateTime.parse(a['tanggal']);
          return attendanceDate.isAfter(weekAgo);
        }).toList();
      case 'month':
        final monthAgo = now.subtract(const Duration(days: 30));
        return attendance.where((a) {
          final attendanceDate = DateTime.parse(a['tanggal']);
          return attendanceDate.isAfter(monthAgo);
        }).toList();
      default:
        return attendance;
    }
  }

  Widget _buildFilterChips() {
    const filters = [
      {'value': 'all', 'label': 'Semua'},
      {'value': 'today', 'label': 'Hari Ini'},
      {'value': 'week', 'label': 'Minggu Ini'},
      {'value': 'month', 'label': 'Bulan Ini'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter['value'];
          return FilterChip(
            selected: isSelected,
            label: Text(filter['label']!),
            onSelected: (selected) {
              setState(() {
                _selectedFilter = filter['value']!;
              });
              _loadAttendanceHistory();
            },
            backgroundColor: Colors.grey[200],
            selectedColor: Colors.green.withOpacity(0.2),
            checkmarkColor: Colors.green,
            labelStyle: TextStyle(
              color: isSelected ? Colors.green : Colors.black,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAttendanceCard(dynamic attendance) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attendance['mata_kuliah'] ?? 'Mata Kuliah',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dosen: ${attendance['dosen'] ?? 'Tidak diketahui'}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        attendance['tanggal'] ?? '',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.access_time, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        attendance['waktu'] ?? '',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                attendance['status'] ?? 'hadir',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada riwayat absensi',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Absensi akan muncul di sini setelah Anda melakukan absen',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Absensi'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAttendanceHistory,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          const SizedBox(height: 8),
          Text(
            'Total: ${_attendanceHistory.length} absensi',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _attendanceHistory.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadAttendanceHistory,
                        child: ListView.builder(
                          itemCount: _attendanceHistory.length,
                          itemBuilder: (context, index) {
                            return _buildAttendanceCard(_attendanceHistory[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}