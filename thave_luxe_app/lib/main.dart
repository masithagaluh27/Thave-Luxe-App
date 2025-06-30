import 'package:flutter/material.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/admin/manage_product_screen.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/auth/login_screen_16.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/auth/profile_screen.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/auth/register_screen_16.dart';
// Brands
import 'package:thave_luxe_app/tugas_enam_belas/screens/brands/brand_screen.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/brands/brands_detail_Screen.dart';
// Cart & Checkout
import 'package:thave_luxe_app/tugas_enam_belas/screens/cart/cart_screen.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/cart/checkout_detail_screen.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/category/category_detail_screen.dart';
// Categories
import 'package:thave_luxe_app/tugas_enam_belas/screens/category/category_screen.dart';
// History
import 'package:thave_luxe_app/tugas_enam_belas/screens/history/history_screen.dart';
// Home & Profile
import 'package:thave_luxe_app/tugas_enam_belas/screens/homescreen.dart';
// Splash, Auth & Welcome Screens
import 'package:thave_luxe_app/tugas_enam_belas/screens/splash_screen.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/welcome_screen_16.dart';

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
        // Welcome & Auth Routes
        SplashScreen16.id: (context) => const SplashScreen16(),
        WelcomeScreen16.id: (context) => const WelcomeScreen16(),
        LoginScreen16.id: (context) => const LoginScreen16(),
        RegisterScreen16.id: (context) => const RegisterScreen16(),

        // Main App Routes
        HomeScreen16.id: (context) => const HomeScreen16(),
        ProfileScreen16.id: (context) => const ProfileScreen16(),
        CartScreen16.id: (context) => const CartScreen16(),
        CheckoutScreen16.id: (context) => const CheckoutScreen16(),
        HistoryScreen.id: (context) => const HistoryScreen(),

        // Category Routes
        CategoryScreen.id: (context) => const CategoryScreen(),
        CategoryDetailScreen.id: (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return CategoryDetailScreen(
            categoryId: args['categoryId'],
            categoryName: args['categoryName'],
          );
        },

        // Admin Routes
        // AdminDashboardScreen16.id: (context) => const AdminDashboardScreen16(),
        // ViewOrdersScreen16.id: (context) => const ViewOrdersScreen16(),
        ManageProductsScreen16.id: (context) => const ManageProductsScreen16(),

        // Brand Routes
        BrandScreen16.id: (context) => const BrandScreen16(),
        BrandDetailScreen16.id: (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return BrandDetailScreen16(
            brandId: args['brandId'],
            brandName: args['brandName'],
          );
        },
      },
    );
  }
}
