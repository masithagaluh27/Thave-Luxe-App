import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:thave_luxe_app/constant/app_color.dart';
import 'package:thave_luxe_app/tugas_enam_belas/api/api_provider.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/app_models.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/brands/brands_detail_screen.dart';

class BrandScreen16 extends StatefulWidget {
  static const String id = '/brandScreen16';

  final Brand? selectedBrand;
  final int? brandId; // Made optional

  const BrandScreen16({super.key, this.selectedBrand, this.brandId});

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

    // Jika sudah dikirimi 1 brand, langsung buka BrandDetail
    if (widget.selectedBrand != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (_) => BrandDetailScreen16(
                  brandId: widget.selectedBrand!.id!,
                  brandName: widget.selectedBrand!.name ?? '',
                ),
          ),
        );
      });
    } else if (widget.brandId != null) {
      _fetchSpecificBrandAndNavigate(widget.brandId!);
    } else {
      _fetchBrands();
    }
  }

  Future<void> _fetchSpecificBrandAndNavigate(int brandId) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final brandResponse = await _apiProvider.getBrands();
      final specificBrand = brandResponse.data?.firstWhere(
        (brand) => brand.id == brandId,
        orElse: () => throw Exception('Brand with ID $brandId not found.'),
      );

      if (mounted && specificBrand != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (_) => BrandDetailScreen16(
                  brandId: specificBrand.id!,
                  brandName: specificBrand.name ?? '',
                ),
          ),
        );
      } else {
        setState(() {
          _errorMessage = 'Brand with ID $brandId not found.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            'Failed to load specific brand: ${e.toString().replaceFirst('Exception: ', '')}';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchBrands() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final brandResponse = await _apiProvider.getBrands();
      setState(() {
        _brands = brandResponse.data ?? [];
        _isLoading = false;
        if (_brands.isEmpty && brandResponse.status != 'success') {
          // Only show error if status is not success
          _errorMessage =
              brandResponse.message?.isNotEmpty == true
                  ? brandResponse.message
                  : 'No brands found.';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage =
            'Failed to load brands: ${e.toString().replaceFirst('Exception: ', '')}';
        _isLoading = false;
      });
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

  PreferredSizeWidget _buildAppBar() => AppBar(
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
    actions: [
      IconButton(
        icon: const Icon(
          Icons.notifications_none_outlined,
          color: AppColors.subtleText,
          size: 28,
        ),
        onPressed: () => debugPrint('Notifications tapped'),
      ),
      const SizedBox(width: 10),
    ],
  );

  Widget _buildLoadingState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.network(
          'https://lottie.host/786a3449-6f92-4938-b715-e2f9d863f69b/nI52w1S9hP.json',
          width: 150,
          height: 150,
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

  Widget _buildErrorState() => Center(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppColors.errorRed, size: 40),
          const SizedBox(height: 10),
          Text(
            _errorMessage ?? '',
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              'Retry',
              style: GoogleFonts.montserrat(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildBrandList() => ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: _brands.length,
    itemBuilder: (_, i) {
      final brand = _brands[i];
      return BrandCard(
        brand: brand,
        onTap: () {
          if (brand.id != null && brand.name != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => BrandDetailScreen16(
                      brandId: brand.id!,
                      brandName: brand.name ?? '',
                    ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Invalid brand data',
                  style: GoogleFonts.montserrat(color: Colors.white),
                ),
                backgroundColor: AppColors.redAccent,
              ),
            );
          }
        },
      );
    },
  );
}

class BrandCard extends StatelessWidget {
  final Brand brand;
  final VoidCallback onTap;
  const BrandCard({super.key, required this.brand, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
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
          Expanded(
            child: Text(
              brand.name ?? 'Unknown Brand',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            color:
                AppColors.subtleGrey, // Changed to subtleGrey for consistency
            size: 20,
          ),
        ],
      ),
    ),
  );
}
