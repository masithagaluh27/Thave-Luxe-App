import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/auth/login_screen_16.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/auth/register_screen_16.dart';

class WelcomeScreen16 extends StatefulWidget {
  const WelcomeScreen16({super.key});
  static const String id = '/welcome_screen16';

  @override
  State<WelcomeScreen16> createState() => _WelcomeScreen16State();
}

class _WelcomeScreen16State extends State<WelcomeScreen16> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> _imagePaths = [
    'assets/images/model-1.jpeg',
    'assets/images/model-2.jpeg',
    'assets/images/model-3.jpeg',
  ];

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 4), (Timer timer) {
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
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image Slideshow
          PageView.builder(
            controller: _pageController,
            itemCount: _imagePaths.length,
            itemBuilder: (context, index) {
              return Image.asset(_imagePaths[index], fit: BoxFit.cover);
            },
          ),

          Container(color: Colors.black.withOpacity(0.5)),

          // Brand Name
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // THAVÉ LUXE
                  Text(
                    'THAVÉ LUXE',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                      color: const Color(0xFFFFFFFF),
                      shadows: [
                        Shadow(
                          color: Colors.amber.shade100.withOpacity(0.8),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),

                  // Subtitle
                  Text(
                    'Simplicity and Comfort for your daily basic needs',
                    style: GoogleFonts.openSans(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  // Buttons
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, RegisterScreen16.id);
                    },
                    child: const Text('SIGN UP'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, LoginScreen16.id);
                    },
                    child: const Text('LOG IN'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
