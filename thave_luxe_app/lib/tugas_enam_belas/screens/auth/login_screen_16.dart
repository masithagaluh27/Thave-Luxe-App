import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thave_luxe_app/constant/app_color.dart';
import 'package:thave_luxe_app/helper/preference_handler.dart';
import 'package:thave_luxe_app/tugas_enam_belas/api/api_provider.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/app_models.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/homescreen.dart'; // Import model tunggal app_models.dart

class LoginScreen16 extends StatefulWidget {
  const LoginScreen16({super.key});
  static const String id = '/login16';

  @override
  State<LoginScreen16> createState() => _LoginScreen16State();
}

class _LoginScreen16State extends State<LoginScreen16> {
  late final Timer _slideshowTimer;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar("Please fill in all fields correctly.", AppColors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Menggunakan ApiResponse<AuthData> karena login mengembalikan AuthData
      final ApiResponse<AuthData> response = await _apiProvider.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Cek jika login sukses dan ada data AuthData (yang berisi token dan user)
      if (response.data != null &&
          response.data!.token != null &&
          response.data!.user != null) {
        // Simpan token
        await PreferenceHandler.setToken(response.data!.token!);
        // Simpan data user lainnya (objek User)
        await PreferenceHandler.setUserData(response.data!.user!);

        final savedToken = await PreferenceHandler.getToken();
        print('DEBUG – token setelah login: $savedToken');

        _showSnackBar(response.message ?? "Login successful!", AppColors.green);

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, HomeScreen16.id);
      } else {
        // Jika response.data, token, atau user null meskipun status 200, berarti ada masalah di data API
        throw Exception(
          response.message ?? "Login failed: Invalid response from server.",
        );
      }
    } on Exception catch (e) {
      print('Login Error: $e');
      String errorMessage = "An unexpected error occurred.";
      if (e.toString().contains("Invalid credentials")) {
        errorMessage = "Invalid email or password.";
      } else if (e.toString().contains("Validation failed.")) {
        errorMessage = "Validation failed. Please check your inputs.";
      } else if (e.toString().contains("Exception: ")) {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      } else {
        errorMessage = e.toString();
      }
      _showSnackBar(errorMessage, AppColors.redAccent);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
            itemBuilder:
                (context, index) => Image.asset(
                  _imagePaths[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
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
                        'Welcome Back',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 32,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
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
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters long';
                          }
                          return null;
                        },
                        toggleVisibility:
                            () => setState(
                              () => _isPasswordVisible = !_isPasswordVisible,
                            ),
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
                            onPressed: _isLoading ? null : _login,
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
                              'Login',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 18,
                                color: AppColors.textDark,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed:
                            () => Navigator.pushNamed(context, '/register16'),
                        child: Text.rich(
                          TextSpan(
                            text: "Don't have an account? ",
                            style: GoogleFonts.montserrat(
                              color: Colors.white.withOpacity(0.85),
                              fontStyle: FontStyle.italic,
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(
                                text: 'Signup',
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
    TextInputAction textInputAction = TextInputAction.next,
  }) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.montserrat(color: Colors.white),
      obscureText: isPassword,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autocorrect: false,
      enableSuggestions: false,
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
