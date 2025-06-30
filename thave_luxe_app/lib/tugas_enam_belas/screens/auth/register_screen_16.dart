import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thave_luxe_app/constant/app_color.dart';
import 'package:thave_luxe_app/helper/preference_handler.dart';
import 'package:thave_luxe_app/tugas_enam_belas/api/api_provider.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/app_models.dart'; // Import model tunggal app_models.dart

class RegisterScreen16 extends StatefulWidget {
  const RegisterScreen16({super.key});
  static const String id = '/register16';

  @override
  State<RegisterScreen16> createState() => _RegisterScreen16State();
}

class _RegisterScreen16State extends State<RegisterScreen16> {
  late final Timer _slideshowTimer;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiProvider _apiProvider = ApiProvider();

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  final List<String> _imagePaths = [
    'assets/images/model-1.jpeg',
    'assets/images/model-2.jpeg',
    'assets/images/model-3.jpeg',
  ];

  @override
  void initState() {
    super.initState();
    _slideshowTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        if (_currentPage < _imagePaths.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _slideshowTimer.cancel();
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar("Please fill in all fields correctly.", AppColors.orange);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Panggil _apiProvider.register yang mengembalikan ApiResponse<AuthData>
      final ApiResponse<AuthData> response = await _apiProvider.register(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Cek jika API mengembalikan data pengguna dan token setelah pendaftaran.
      // Ini terjadi jika API secara otomatis meng-login pengguna setelah register.
      if (response.data != null &&
          response.data!.token != null &&
          response.data!.user != null) {
        await PreferenceHandler.setToken(response.data!.token!); // Simpan token
        await PreferenceHandler.setUserData(
          response.data!.user!,
        ); // Simpan objek User

        _showSnackBar(
          response.message ?? "Registration successful! You are now logged in.",
          AppColors.green,
        );

        if (!mounted) return;
        // Navigasi ke HomeScreen setelah register dan login otomatis
        Navigator.pushReplacementNamed(
          context,
          '/home16',
        ); // Asumsi '/home16' adalah rute ke HomeScreen
      } else {
        // Jika API tidak mengembalikan token/user setelah register (hanya pesan sukses),
        // atau jika ada pesan sukses tapi tanpa data login, arahkan ke layar Login.
        _showSnackBar(
          response.message ?? "Registration successful! Please log in.",
          AppColors.green,
        );
        if (!mounted) return;
        Navigator.pop(context); // Kembali ke Login Screen
      }
    } on Exception catch (e) {
      print('Register Error: $e');
      String errorMessage = "An unexpected error occurred.";
      if (e.toString().contains("Email already exists")) {
        // Sesuaikan pesan error dari backend Anda
        errorMessage = "Email is already in use.";
      } else if (e.toString().contains("Validation failed.")) {
        // Contoh validasi backend
        errorMessage = "Validation failed. Please check your inputs.";
      } else if (e.toString().contains("Exception: ")) {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      } else {
        errorMessage = e.toString();
      }
      _showSnackBar(errorMessage, AppColors.redAccent);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.montserrat(color: Colors.white),
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _imagePaths.length,
            itemBuilder: (context, index) {
              return Image.asset(
                _imagePaths[index],
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              );
            },
          ),
          Container(color: Colors.black.withOpacity(0.5)),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Create Account',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 32,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildTextField(
                        'Name',
                        controller: _nameController,
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        'Email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        'Password',
                        controller: _passwordController,
                        isPassword: !_isPasswordVisible,
                        keyboardType: TextInputType.visiblePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters long';
                          }
                          return null;
                        },
                        toggleVisibility: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                        isPasswordType: true,
                        isCurrentPasswordVisible: _isPasswordVisible,
                      ),
                      const SizedBox(height: 24),
                      _isLoading
                          ? CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryGold,
                            ),
                          )
                          : ElevatedButton(
                            onPressed: _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGold,
                              minimumSize: const Size(double.infinity, 50),
                              elevation: 6,
                              shadowColor: Colors.black45,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Register',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 18,
                                color: AppColors.textDark,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Kembali ke Login Screen
                        },
                        child: Text.rich(
                          TextSpan(
                            text: 'Already have an account? ',
                            style: GoogleFonts.montserrat(
                              color: Colors.white.withOpacity(0.85),
                              fontStyle: FontStyle.italic,
                              fontSize: 14,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Login',
                                style: GoogleFonts.montserrat(
                                  color: AppColors.primaryGold,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String hint, {
    TextEditingController? controller,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    VoidCallback? toggleVisibility,
    bool isPasswordType = false,
    bool isCurrentPasswordVisible = false,
  }) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.montserrat(color: Colors.white),
      obscureText: isPassword,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.montserrat(color: Colors.white54),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryGold, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorRed, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorRed, width: 2),
        ),
        errorStyle: GoogleFonts.montserrat(
          color: AppColors.redAccent,
          fontSize: 12,
        ),
        suffixIcon:
            isPasswordType
                ? IconButton(
                  icon: Icon(
                    isCurrentPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.white54,
                  ),
                  onPressed: toggleVisibility,
                )
                : null,
      ),
    );
  }
}
