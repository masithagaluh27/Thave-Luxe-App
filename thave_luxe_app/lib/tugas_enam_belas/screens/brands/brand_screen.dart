import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thave_luxe_app/constant/app_color.dart';

class BrandsScreen16 extends StatelessWidget {
  const BrandsScreen16({super.key});

  static const String id = '/brands16';

  final List<String> _brands = const [
    'Ekin',
    'Adidos',
    'Pamu',
    'Guccai',
    'Prada',
    'Louis Vuitton',
    'Chanel',
    'Fila',
    'Vercace',
    'Burbrebry',
    'calvin clein',
    'Ralph Lauren',
  ];

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.montserrat(color: Colors.white),
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        title: Text(
          'Brands',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.backgroundLight,
              AppColors.backgroundGradientEnd,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: SizedBox(
            height: 160, // Tinggi kontainer brand
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _brands.length,
              itemBuilder: (context, index) {
                final brandName = _brands[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: _buildBrandCard(context, brandName),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandCard(BuildContext context, String brandName) {
    return SizedBox(
      width: 140, // Lebar tiap card
      child: Card(
        elevation: 5,
        color: AppColors.cardBackgroundLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: InkWell(
          onTap: () {
            // Ganti ini dengan nama screen produk brand kamu
            // Navigator.pushNamed(context, BrandProductsScreen16.id, arguments: brandName);

            _showSnackBar(
              context,
              'Viewing $brandName products!',
              AppColors.blue,
            );
          },
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star_border, size: 40, color: AppColors.primaryGold),
                const SizedBox(height: 10),
                Text(
                  brandName,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.playfairDisplay(
                    color: AppColors.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'View Collection',
                  style: GoogleFonts.montserrat(
                    color: AppColors.subtleText,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
