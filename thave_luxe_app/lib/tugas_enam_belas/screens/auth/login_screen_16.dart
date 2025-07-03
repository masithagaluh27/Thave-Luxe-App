import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thave_luxe_app/constant/app_color.dart';
import 'package:thave_luxe_app/helper/preference_handler.dart';
import 'package:thave_luxe_app/tugas_enam_belas/api/api_provider.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/app_models.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/homescreen.dart';

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
    debugPrint(
      'LOGIN_SCREEN: Login attempt started for: ${_emailController.text}',
    );

    try {
      final ApiResponse<AuthData> response = await _apiProvider.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // >>> NEW DEBUG PRINT: Print the raw API response status and message
      debugPrint(
        'LOGIN_SCREEN: Raw API Response Status: ${response.status}',
      ); // Add this
      debugPrint(
        'LOGIN_SCREEN: Raw API Response Message: ${response.message}',
      ); // Add this

      // YOUR CURRENT CONDITION: response.data != null && response.data!.token != null && response.data!.user != null
      // PREVIOUSLY SUGGESTED CONDITION: response.status == 'success'
      // Let's ensure 'response.status' is actually considered here.
      if (response.status == 'success' && // <--- CRITICAL: ADD THIS CHECK BACK!
          response.data != null &&
          response.data!.token != null &&
          response.data!.user != null) {
        debugPrint('LOGIN_SCREEN: Login successful conditions met.');

        await PreferenceHandler.setToken(response.data!.token!);
        await PreferenceHandler.setUserData(response.data!.user!);

        final savedToken = await PreferenceHandler.getToken();
        debugPrint('LOGIN_SCREEN: Token saved: $savedToken');

        // >>> NEW DEBUG PRINT: Print what message and color are used for YOUR snackbar
        String snackbarMessage = response.message ?? "Login successful!";
        Color snackbarColor = AppColors.successGreen;
        debugPrint(
          'LOGIN_SCREEN: Showing MY snackbar with message: "$snackbarMessage" and color: $snackbarColor',
        ); // Add this
        _showSnackBar(snackbarMessage, snackbarColor);

        debugPrint(
          'LOGIN_SCREEN: Mounted status BEFORE navigation check: $mounted',
        );
        if (!mounted) {
          debugPrint(
            'LOGIN_SCREEN: Widget is NOT mounted. Navigation aborted.',
          );
          return;
        }
        debugPrint(
          'LOGIN_SCREEN: Widget is mounted. Attempting to navigate to ${HomeScreen16.id}',
        );
        Navigator.pushReplacementNamed(context, HomeScreen16.id);
      } else {
        // If response.data, token, or user null even if status 200, it's an API data issue
        // OR if response.status is not 'success' (e.g., 'error')
        debugPrint(
          'LOGIN_SCREEN: Login failed: Invalid response data structure or status.',
        );
        String errorMessage =
            response.message ?? "Login failed. Invalid response from server.";
        if (response.error != null && response.error!.isNotEmpty) {
          errorMessage = response.error!;
        }
        // >>> NEW DEBUG PRINT: Print what message and color are used for MY error snackbar
        debugPrint(
          'LOGIN_SCREEN: Showing MY error snackbar with message: "$errorMessage" and color: ${AppColors.errorRed}',
        ); // Add this
        _showSnackBar(errorMessage, AppColors.errorRed); // Used errorRed
      }
    } on Exception catch (e) {
      debugPrint('LOGIN_SCREEN: Login Exception caught: $e');
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
      // >>> NEW DEBUG PRINT: Print what message and color are used for MY exception snackbar
      debugPrint(
        'LOGIN_SCREEN: Showing MY exception snackbar with message: "$errorMessage" and color: ${AppColors.redAccent}',
      ); // Add this
      _showSnackBar(errorMessage, AppColors.redAccent); // Used errorRed
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        debugPrint('LOGIN_SCREEN: _isLoading set to false.');
      } else {
        debugPrint(
          'LOGIN_SCREEN: Widget not mounted in finally block. Cannot set state.',
        );
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) {
      debugPrint('LOGIN_SCREEN: Cannot show snackbar, widget not mounted.');
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.montserrat(
            color: AppColors.textLight,
          ), // Use AppColors.textLight
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
                          color: AppColors.textLight, // Use AppColors.textLight
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
                              color: AppColors.textLight.withOpacity(
                                0.85,
                              ), // Use AppColors.textLight
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
      style: GoogleFonts.montserrat(
        color: AppColors.textLight,
      ), // Use AppColors.textLight
      obscureText: isPassword,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autocorrect: false,
      enableSuggestions: false,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.montserrat(
          color: AppColors.textLight.withOpacity(0.54),
        ), // Use AppColors.textLight
        filled: true,
        fillColor: AppColors.textLight.withOpacity(
          0.1,
        ), // Use AppColors.textLight
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
                    color: AppColors.textLight.withOpacity(
                      0.54,
                    ), // Use AppColors.textLight
                  ),
                  onPressed: toggleVisibility,
                )
                : null,
      ),
    );
  }
}
