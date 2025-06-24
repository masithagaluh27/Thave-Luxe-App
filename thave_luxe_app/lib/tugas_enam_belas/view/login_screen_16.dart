import 'dart:async'; // For Timer
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thave_luxe_app/tugas_enam_belas/api/service_api.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/auth_response.dart';
import 'package:thave_luxe_app/tugas_enam_belas/api/auth_provider.dart';

class LoginScreen16 extends StatefulWidget {
  const LoginScreen16({super.key});
  static const String id = '/login16';

  @override
  State<LoginScreen16> createState() => _LoginScreen16State();
}

class _LoginScreen16State extends State<LoginScreen16> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Global key for the form to handle validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Service instance for API calls
  final TokoOnlineService _tokoOnlineService = TokoOnlineService();

  // State for loading indicator during API calls
  bool _isLoading = false;

  // Paths to your background images
  final List<String> _imagePaths = [
    'assets/image/model-1.JPEG',
    'assets/image/model-2.JPEG',
    'assets/image/model-3.JPEG',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize the auto-scrolling for the background images
    Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        // Check if pageController is attached to avoid errors
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
    // Dispose all controllers to prevent memory leaks
    _pageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- Login Logic ---
  Future<void> _login() async {
    // Validate the form before attempting login
    if (!_formKey.currentState!.validate()) {
      _showSnackBar("Please fill in all fields correctly.", Colors.orange);
      return;
    }

    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      final AuthResponse response = await _tokoOnlineService.loginUser(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Handle successful login
      _showSnackBar(response.message ?? "Login successful!", Colors.green);
      // Navigate to home screen or dashboard upon successful login
      // Example: Navigator.pushReplacementNamed(context, '/home');
    } on Exception catch (e) {
      // Handle login errors
      print('Login Error: $e'); // Log the full error for debugging

      String errorMessage = "An unexpected error occurred.";
      if (e.toString().contains("Invalid credentials")) {
        errorMessage = "Invalid email or password.";
      } else if (e.toString().contains("Validation failed.")) {
        // This means the API returned a 422 with validation errors
        errorMessage = "Validation failed. Please check your inputs.";
      } else {
        errorMessage = e.toString().replaceFirst(
          'Exception: ',
          '',
        ); // Clean up 'Exception: ' prefix
      }

      _showSnackBar(errorMessage, Colors.red);
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  // Helper method to show SnackBar messages
  void _showSnackBar(String message, Color color) {
    // Ensure the context is still valid before showing SnackBar
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: const Duration(seconds: 3),
          behavior:
              SnackBarBehavior
                  .floating, // Make it floating for better visibility
          margin: const EdgeInsets.all(10), // Add margin
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background slider
          PageView.builder(
            controller: _pageController,
            itemCount: _imagePaths.length,
            itemBuilder: (context, index) {
              return Image.asset(
                _imagePaths[index],
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity, // Ensure image fills height
              );
            },
          ),

          // Overlay gelap (dark overlay)
          Container(color: Colors.black.withOpacity(0.5)),

          // Login form content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                // Wrapped with Form for validation
                key: _formKey, // Assign the form key
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Keep column compact
                    children: [
                      Text(
                        'Welcome Back',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 32,
                          color: const Color.fromARGB(
                            255,
                            255,
                            255,
                            254,
                          ), // Gold/Off-white
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
                          // Basic email format validation
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
                        isPassword: true,
                        keyboardType: TextInputType.visiblePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          // Example minimum password length
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters long';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Login Button (with loading indicator)
                      _isLoading
                          ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color.fromARGB(255, 180, 154, 129),
                            ),
                          )
                          : ElevatedButton(
                            onPressed: _login, // Call the _login method
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                180,
                                154,
                                129, // Your desired gold/brownish color
                              ),
                              minimumSize: const Size(
                                double.infinity,
                                50,
                              ), // Full width button
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
                                color:
                                    Colors.black, // Text color for the button
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                      const SizedBox(height: 12),

                      // Sign up text button
                      TextButton(
                        onPressed: () {
                          // Navigate to the registration screen
                          // Ensure this route '/register16' is defined in your MaterialApp's routes
                          Navigator.pushNamed(context, '/register16');
                        },
                        child: Text(
                          'Don\'t have an account? Signup',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontStyle: FontStyle.italic,
                            fontSize: 14,
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

  // Helper widget for building text fields (uses TextFormField for validation)
  Widget _buildTextField(
    String hint, {
    TextEditingController? controller,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator, // Validator function for input
  }) {
    return TextFormField(
      // Changed to TextFormField for validation capabilities
      controller: controller,
      style: const TextStyle(color: Colors.white),
      obscureText: isPassword,
      keyboardType: keyboardType,
      validator: validator, // Assign the validator function
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          // Default border style when enabled
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          // Border style when focused
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 180, 154, 129),
            width: 2,
          ), // Highlight with accent color
        ),
        errorBorder: OutlineInputBorder(
          // Border style when validation error
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          // Border style when focused with error
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        errorStyle: const TextStyle(
          color: Colors.redAccent,
          fontSize: 12,
        ), // Style for error text
      ),
    );
  }
}
