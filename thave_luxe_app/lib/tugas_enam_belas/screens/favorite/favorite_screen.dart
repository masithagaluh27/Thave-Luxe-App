// lib/tugas_enam_belas/screens/favorite/favorite_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thave_luxe_app/constant/app_color.dart';

class FavoriteScreen16 extends StatelessWidget {
  const FavoriteScreen16({super.key});

  static const String id = '/favorite16';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        title: Text(
          'My wishlist',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Text(
          'No wishlist items yet.',
          style: GoogleFonts.montserrat(
            color: AppColors.subtleText,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
