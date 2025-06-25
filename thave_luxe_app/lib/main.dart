import 'package:flutter/material.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/cart/cart_screen.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/homescreen.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/profile/login_screen_16.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/profile/profile_screen.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/splash_screen.dart';

import 'tugas_enam_belas/screens/profile/register_screen_16.dart';
import 'tugas_enam_belas/screens/welcome_screen_16.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: SplashScreen16.id,
      routes: {
        SplashScreen16.id: (context) => const SplashScreen16(),
        WelcomeScreen16.id: (context) => const WelcomeScreen16(),
        LoginScreen16.id: (context) => const LoginScreen16(),
        RegisterScreen16.id: (context) => const RegisterScreen16(),
        HomeScreen16.id: (context) => const HomeScreen16(),
        ProfileScreen16.id: (context) => const ProfileScreen16(),
        CartScreen16.id: (context) => const CartScreen16(),
      },
    );
  }
}
