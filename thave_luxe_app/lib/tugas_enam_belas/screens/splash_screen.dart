import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thave_luxe_app/helper/preference_handler.dart'; // Import your PreferenceHandler
import 'package:thave_luxe_app/tugas_enam_belas/screens/homescreen.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/welcome_screen_16.dart';

class SplashScreen16 extends StatefulWidget {
  const SplashScreen16({super.key});
  static const String id = '/splash_screen16';

  @override
  State<SplashScreen16> createState() => _SplashScreen16State();
}

class _SplashScreen16State extends State<SplashScreen16> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Wait for 3 seconds for the splash screen effect
    await Future.delayed(const Duration(seconds: 3));

    // Use PreferenceHandler to get the token
    final String? userToken = await PreferenceHandler.getToken();

    if (userToken != null && userToken.isNotEmpty) {
      // User is logged in, navigate to HomeScreen16
      Navigator.pushNamedAndRemoveUntil(
        context,
        HomeScreen16.id, // Navigate to your main home screen
        (route) => false,
      );
    } else {
      // User is not logged in, navigate to WelcomeScreen16
      Navigator.pushNamedAndRemoveUntil(
        context,
        WelcomeScreen16.id,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/blur.jpeg', fit: BoxFit.cover),
          Container(
            color: Colors.black.withOpacity(0.3), // Optional dark overlay
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'THAVÉ LUXE',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Dare to be Luxe',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
