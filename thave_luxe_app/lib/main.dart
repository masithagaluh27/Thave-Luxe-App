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
        SplashScreen16.id: (context) => const SplashScreen16(),
        WelcomeScreen16.id: (context) => const WelcomeScreen16(),
        LoginScreen16.id: (context) => const LoginScreen16(),
        RegisterScreen16.id: (context) => const RegisterScreen16(),

        HomeScreen16.id: (context) => const HomeScreen16(),
        ProfileScreen16.id: (context) => const ProfileScreen16(),
        CartScreen16.id: (context) => const CartScreen16(),
        CheckoutScreen16.id: (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          if (args == null || args['checkoutData'] == null) {
            return const Scaffold(
              body: Center(child: Text('Checkout data missing')),
            );
          }
          return CheckoutScreen16(checkoutData: args['checkoutData']);
        },
        HistoryScreen.id: (context) => const HistoryScreen(),

        CategoryScreen.id: (context) => const CategoryScreen(),

        CategoryDetailScreen.id: (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;

          if (args == null ||
              args['categoryId'] == null ||
              args['categoryName'] == null) {
            return const Scaffold(
              body: Center(child: Text('Category data missing')),
            );
          }

          return CategoryDetailScreen(
            categoryId: args['categoryId'],
            categoryName: args['categoryName'],
          );
        },

        ManageProductScreen.id: (context) {
          final brandId = ModalRoute.of(context)?.settings.arguments as String?;
          if (brandId == null) {
            return const Scaffold(
              body: Center(child: Text('Brand ID tidak ditemukan')),
            );
          }
          return ManageProductScreen();
        },

        BrandScreen16.id: (ctx) {
          final brandId = ModalRoute.of(ctx)?.settings.arguments as String?;
          if (brandId == null) {
            return const Scaffold(
              body: Center(child: Text('Brand ID is missing')),
            );
          }
          return BrandScreen16(brandId: int.tryParse(brandId));
        },

        BrandDetailScreen16.id: (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;

          if (args == null ||
              args['brandId'] == null ||
              args['brandName'] == null) {
            return const Scaffold(
              body: Center(child: Text('Brand data missing')),
            );
          }

          return BrandDetailScreen16(
            brandId: args['brandId'],
            brandName: args['brandName'],
          );
        },
      },
    );
  }
}
