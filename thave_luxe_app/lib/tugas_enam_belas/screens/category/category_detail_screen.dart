import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thave_luxe_app/constant/app_color.dart'; // Your AppColors file
import 'package:thave_luxe_app/tugas_enam_belas/api/store_provider.dart'; // Corrected import to ApiProvider
import 'package:thave_luxe_app/tugas_enam_belas/models/error_response.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/produk_response.dart'; // This file should contain Product and ProductResponse
import 'package:thave_luxe_app/tugas_enam_belas/screens/product/product_detail_screen.dart'; // This import seems to be the correct ProductDetailScreen

class CategoryDetailScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const CategoryDetailScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });
  static const String id = '/detailcategory';

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  final ApiProvider _apiProvider = ApiProvider();
  List<Product> _products = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProductsByCategory();
  }

  Future<void> _fetchProductsByCategory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final ProductResponse response = await _apiProvider.getProducts(
        categoryId: widget.categoryId,
      );
      if (mounted) {
        setState(() {
          _products = response.data ?? [];
          _isLoading = false;
        });
        print(
          'Products for category ${widget.categoryName} fetched successfully: ${_products.length} items',
        );
      }
    } on ErrorResponse catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
          _isLoading = false;
        });
        print('CategoryDetailScreen: Error fetching products: ${e.message}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load products: ${e.toString()}';
          _isLoading = false;
        });
        print('CategoryDetailScreen: Unexpected error fetching products: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: _buildAppBar(context),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.darkBackground, AppColors.backgroundGradientEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _fetchProductsByCategory,
          color: AppColors.primaryGold,
          backgroundColor: AppColors.cardBackgroundDark,
          child: _buildBody(),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.darkBackground,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.lightText),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Text(
        widget.categoryName,
        style: GoogleFonts.playfairDisplay(
          color: AppColors.lightText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.search, color: AppColors.subtleGrey, size: 28),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Search in ${widget.categoryName} (Coming Soon!)',
                  style: GoogleFonts.montserrat(color: AppColors.lightText),
                ),
                backgroundColor: AppColors.blue,
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGold),
      );
    } else if (_errorMessage != null) {
      return SingleChildScrollView(
        physics:
            const AlwaysScrollableScrollPhysics(), // Ensures scrollability even if content is small
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: AppColors.errorRed,
                  size: 60,
                ),
                const SizedBox(height: 20),
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
                  onPressed: _fetchProductsByCategory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGold,
                    foregroundColor: AppColors.darkBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    'Retry',
                    style: GoogleFonts.playfairDisplay(
                      color: AppColors.darkBackground,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else if (_products.isEmpty) {
      return SingleChildScrollView(
        physics:
            const AlwaysScrollableScrollPhysics(), // Ensures scrollability even if content is small
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.sentiment_dissatisfied_outlined,
                  color: AppColors.subtleGrey,
                  size: 60,
                ),
                const SizedBox(height: 20),
                Text(
                  'No products found in this category.',
                  style: GoogleFonts.montserrat(
                    color: AppColors.subtleText,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _fetchProductsByCategory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGold,
                    foregroundColor: AppColors.darkBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    'Refresh',
                    style: GoogleFonts.playfairDisplay(
                      color: AppColors.darkBackground,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 0.7,
        ),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return _buildProductCard(product);
        },
      );
    }
  }

  Widget _buildProductCard(Product product) {
    // Corrected: Assuming `product.imageUrl` is directly available as a String?
    // If your Product model nests the image URL (e.g., in a list of image objects),
    // you'll need to adjust this line to access the correct property.
    final String? productImageUrl = product.imageUrl;

    return GestureDetector(
      onTap: () {
        // IMPORTANT: Ensure ProductDetailScreen's constructor matches these parameters.
        // Based on your previous BrandDetailScreen error, ProductDetailScreen
        // might require 'brandName' and 'categoryName'.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ProductDetailScreen(
                  product: product,
                  // You might need to add these if ProductDetailScreen requires them:
                  // brandName: product.brand?.name ?? 'Unknown Brand',
                  // categoryName: widget.categoryName, // Pass the current category name
                ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackgroundDark,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child:
                    // Corrected: Use productImageUrl variable
                    productImageUrl != null && productImageUrl.isNotEmpty
                        ? Image.network(
                          productImageUrl, // Use the extracted productImageUrl
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder:
                              (context, error, stackTrace) => Container(
                                color: AppColors.subtleGrey.withOpacity(0.2),
                                child: const Center(
                                  child: Icon(
                                    Icons.image_not_supported_outlined,
                                    color: AppColors.subtleText,
                                    size: 40,
                                  ),
                                ),
                              ),
                        )
                        : Container(
                          color: AppColors.subtleGrey.withOpacity(0.2),
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: AppColors.subtleText,
                              size: 40,
                            ),
                          ),
                        ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name ?? 'Unknown Product',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                      color: AppColors.lightText,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Corrected: Assuming `product.brand` is an object with a `name` property
                  Text(
                    product.brand?.name ?? 'Unknown Brand',
                    style: GoogleFonts.montserrat(
                      color: AppColors.subtleText,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      // Format price for currency if needed (e.g., using intl package)
                      'Rp ${product.price?.toStringAsFixed(0) ?? '0'}',
                      style: GoogleFonts.playfairDisplay(
                        color: AppColors.primaryGold,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
