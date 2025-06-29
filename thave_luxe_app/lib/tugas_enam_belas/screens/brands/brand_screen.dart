// Path: lib/tugas_enam_belas/screens/brand/brand_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:thave_luxe_app/constant/app_color.dart';
import 'package:thave_luxe_app/tugas_enam_belas/api/store_provider.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/brand_response.dart'; // Make sure this path is correct
import 'package:thave_luxe_app/tugas_enam_belas/screens/brands/brands_detail_Screen.dart'; // This path should now be correct

class BrandScreen16 extends StatefulWidget {
  const BrandScreen16({super.key});

  static const String id = '/brandScreen16';

  @override
  State<BrandScreen16> createState() => _BrandScreen16State();
}

class _BrandScreen16State extends State<BrandScreen16> {
  final ApiProvider _apiProvider = ApiProvider();
  List<Brand> _brands = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchBrands();
  }

  Future<void> _fetchBrands() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final brandResponse = await _apiProvider.getBrands();
      if (mounted) {
        setState(() {
          if (brandResponse.data is List) {
            _brands = List<Brand>.from(
              (brandResponse.data as List).map(
                (x) => Brand.fromJson(x as Map<String, dynamic>),
              ),
            );
          } else {
            _brands = []; // No data or invalid data format
            _errorMessage = 'Invalid data format for brands.';
            print('BrandScreen16: getBrands did not return a List.');
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'Failed to load brands: ${e.toString().replaceFirst('Exception: ', '')}';
          _isLoading = false;
        });
        print('BrandScreen16: Error fetching brands: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: _buildAppBar(),
      body:
          _isLoading
              ? _buildLoadingState()
              : _errorMessage != null
              ? _buildErrorState()
              : _buildBrandList(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.backgroundLight,
      elevation: 0,
      title: Text(
        'Brands',
        style: GoogleFonts.playfairDisplay(
          color: AppColors.textDark,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: <Widget>[
        // FIX: Added const keyword as the icon doesn't change
        IconButton(
          icon: const Icon(
            // Line 294 in your original code
            Icons.notifications_none_outlined,
            color: AppColors.subtleText,
            size: 28,
          ),
          onPressed: () {
            print('Notifications Tapped from Brand Screen');
          },
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.network(
            'https://lottie.host/786a3449-6f92-4938-b715-e2f9d863f69b/nI52w1S9hP.json',
            width: 150,
            height: 150,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading brands...',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.errorRed,
              size: 40,
            ),
            const SizedBox(height: 10),
            Text(
              _errorMessage!,
              style: GoogleFonts.montserrat(
                color: AppColors.errorRed,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchBrands,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: Text(
                'Retry',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandList() {
    if (_brands.isEmpty) {
      return Center(
        child: Text(
          'No brands found.',
          style: GoogleFonts.montserrat(
            color: AppColors.subtleText,
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _brands.length,
      itemBuilder: (context, index) {
        final brand = _brands[index];
        return BrandCard(
          brand: brand,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => BrandDetailScreen16(
                      brandId:
                          brand.id!, // Assuming brand.id is never null here
                      brandName:
                          brand.name!, // Assuming brand.name is never null here
                    ),
              ),
            );
          },
        );
      },
    );
  }
}

class BrandCard extends StatelessWidget {
  final Brand brand;
  final VoidCallback onTap;

  const BrandCard({super.key, required this.brand, required this.onTap});

  @override
  Widget build(BuildContext context) {
    String imageUrlToDisplay = brand.imageUrl ?? '';
    if (imageUrlToDisplay.isEmpty) {
      imageUrlToDisplay =
          'https://placehold.co/100x100/EEEEEE/333333?text=${brand.name?.substring(0, 1) ?? 'B'}';
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.cardBackgroundLight,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imageUrlToDisplay,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      width: 70,
                      height: 70,
                      color: AppColors.imagePlaceholderLight,
                      child: const Icon(
                        Icons.broken_image,
                        color: AppColors.accentGrey,
                        size: 30,
                      ),
                    ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    brand.name ?? 'Unknown Brand',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    brand.description ?? 'No description available.',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: AppColors.subtleText,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.subtleText,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
