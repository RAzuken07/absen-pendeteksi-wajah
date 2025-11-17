import 'package:flutter/material.dart';
import '../services/api_service.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<dynamic> _users = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);

    final result = await ApiService.getUsers();

    if (mounted) {
      if (result['success'] == true && result['data'] != null) {
        setState(() {
          _users = result['data'] is List ? result['data'] : [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _users = [];
          _isLoading = false;
        });
        _showSnackBar(result['message'] ?? 'Gagal memuat data pengguna', false);
      }
    }
  }

  List<dynamic> get _filteredUsers {
  if (_searchQuery.isEmpty) {
    return _users;
  }

  return _users.where((user) {
    if (user is! Map) return false; // pastikan user adalah Map

    final namaRaw = user['nama'] ?? '';
    final namaStr = namaRaw is String ? namaRaw : namaRaw.toString();

    return namaStr.toLowerCase().contains(_searchQuery.toLowerCase());
  }).toList();
}

  void _showSnackBar(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showUserDetails(dynamic user) {
    final namaRaw = user['nama'] ?? 'N/A';
    final idRaw = user['id'] ?? 'N/A';
    final createdAtRaw = user['created_at'] ?? 'N/A';

    // Pastikan semua adalah String
    final nama = namaRaw is String ? namaRaw : namaRaw.toString();
    final id = idRaw is String ? idRaw : idRaw.toString();
    final createdAt =
        createdAtRaw is String ? createdAtRaw : createdAtRaw.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(nama),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'ID: $id',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Terdaftar: $createdAt',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pengguna'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          // Container(
          //   padding: const EdgeInsets.all(16),
          //   color: Colors.white,
          //   child: TextField(
          //     onChanged: (value) => setState(() => _searchQuery = value),
          //     decoration: InputDecoration(
          //       hintText: 'Cari pengguna...',
          //       prefixIcon: const Icon(Icons.search),
          //       suffixIcon: _searchQuery.isNotEmpty
          //           ? IconButton(
          //               icon: const Icon(Icons.clear),
          //               onPressed: () => setState(() => _searchQuery = ''),
          //             )
          //           : null,
          //       border: OutlineInputBorder(
          //         borderRadius: BorderRadius.circular(12),
          //         borderSide: BorderSide.none,
          //       ),
          //       filled: true,
          //       fillColor: Colors.grey[100],
          //       contentPadding: const EdgeInsets.symmetric(
          //         horizontal: 16,
          //         vertical: 12,
          //       ),
          //     ),
          //   ),
          // ),

          // User Count
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: Row(
              children: [
                Text(
                  'Total: ${_filteredUsers.length} pengguna',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Users List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 80,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'Tidak ada pengguna'
                                  : 'Pengguna tidak ditemukan',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadUsers,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = _filteredUsers[index];
                            return _buildUserCard(user);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(dynamic user) {

    if (user is String) {
    return _buildUserCard({'id': 'N/A', 'nama': user});
  }

  if (user is! Map) {
    return const Text('Invalid user data');
  }

    final namaRaw = user['nama'] ?? 'Unknown';
    final idRaw = user['id'] ?? 'N/A';

    // Pastikan nama dan id adalah String
    final nama = namaRaw is String ? namaRaw : namaRaw.toString();
    final id = idRaw is String ? idRaw : idRaw.toString();

    // Extract first letter for avatar
    final firstLetter = nama.isNotEmpty ? nama[0].toUpperCase() : '?';

    // Get color based on first letter
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.teal,
      Colors.indigo,
    ];

    final colorIndex = firstLetter.codeUnitAt(0) % colors.length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showUserDetails(user),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colors[colorIndex].withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    firstLetter,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colors[colorIndex],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nama,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: $id',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
