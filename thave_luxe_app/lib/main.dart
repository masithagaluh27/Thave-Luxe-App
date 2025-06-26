import 'package:flutter/material.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/admin/admi_product_screen.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/admin/admin_dashboard_screen.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/admin/view_order_screen_admin_screen.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/cart/cart_screen.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/cart/checkout_detail_screen.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/favorite/favorite_screen.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/homescreen.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/profile/login_screen_16.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/profile/profile_screen.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/splash_screen.dart';

import 'tugas_enam_belas/screens/brands/brand_screen.dart';
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
        BrandsScreen16.id: (context) => const BrandsScreen16(),
        FavoriteScreen16.id: (context) => const FavoriteScreen16(),
        CheckoutScreen16.id: (context) => const CheckoutScreen16(),
        AdminDashboardScreen16.id: (context) => const AdminDashboardScreen16(),
        ViewOrdersScreen16.id: (context) => const ViewOrdersScreen16(),
        ManageProductsScreen16.id: (context) => const ManageProductsScreen16(),
      },
    );
  }
}
