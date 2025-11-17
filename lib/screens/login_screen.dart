import 'package:absensiwajahdoang/screens/dosen_dashboard.dart';
import 'package:absensiwajahdoang/screens/mahasiswa_dashboard.dart';
import 'package:absensiwajahdoang/screens/register_screen.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'mahasiswa';
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // For testing
    _emailController.text = _selectedRole == 'dosen' ? 'admin@kampus.id' : '';
    _passwordController.text = _selectedRole == 'dosen' ? 'admin123' : '';
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.login(
        _emailController.text.trim(),
        _passwordController.text,
        _selectedRole,
      );

      if (mounted) {
        if (result['success'] == true) {
          // Simpan user data dan navigasi sesuai role
          final userData = result['data'];
          final user = User.fromJson(userData);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => _selectedRole == 'dosen'
                  ? DosenDashboard(user: user)
                  : MahasiswaDashboard(user: user),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Login gagal'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Header
              const Icon(
                Icons.face_retouching_natural,
                size: 80,
                color: Color(0xFF2196F3),
              ),
              const SizedBox(height: 16),
              const Text(
                'Sistem Absensi Wajah',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Login sebagai ${_selectedRole == 'dosen' ? 'Dosen' : 'Mahasiswa'}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 32),

              // Role Selector
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() {
                          _selectedRole = 'dosen';
                          _emailController.text = 'admin@kampus.id';
                          _passwordController.text = 'admin123';
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedRole == 'dosen'
                                ? Colors.blue.withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(12),
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.school,
                                color: _selectedRole == 'dosen'
                                    ? Colors.blue
                                    : Colors.grey,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Dosen',
                                style: TextStyle(
                                  fontWeight: _selectedRole == 'dosen'
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: _selectedRole == 'dosen'
                                      ? Colors.blue
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() {
                          _selectedRole = 'mahasiswa';
                          _emailController.clear();
                          _passwordController.clear();
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedRole == 'mahasiswa'
                                ? Colors.green.withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: const BorderRadius.horizontal(
                              right: Radius.circular(12),
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.person,
                                color: _selectedRole == 'mahasiswa'
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Mahasiswa',
                                style: TextStyle(
                                  fontWeight: _selectedRole == 'mahasiswa'
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: _selectedRole == 'mahasiswa'
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Email/Username Field
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: _selectedRole == 'dosen' ? 'Email' : 'Nama',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return _selectedRole == 'dosen'
                        ? 'Email harus diisi'
                        : 'Nama harus diisi';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Password Field (hanya untuk dosen)
              if (_selectedRole == 'dosen')
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password harus diisi';
                    }
                    return null;
                  },
                ),

              const SizedBox(height: 32),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _selectedRole == 'dosen' ? Colors.blue : Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Login sebagai ${_selectedRole == 'dosen' ? 'Dosen' : 'Mahasiswa'}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Register Link untuk mahasiswa
              if (_selectedRole == 'mahasiswa')
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: const Text('Belum terdaftar? Daftar di sini'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
