import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:thave_luxe_app/constant/app_color.dart';
import 'package:thave_luxe_app/tugas_enam_belas/api/api_provider.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/app_models.dart'; // <<< ONLY THIS IMPORT FOR MODELS
import 'package:thave_luxe_app/tugas_enam_belas/screens/product/product_detail_screen.dart';

class BrandDetailScreen16 extends StatefulWidget {
  final int brandId;
  final String brandName;

  const BrandDetailScreen16({
    super.key,
    required this.brandId,
    required this.brandName,
  });

  static const String id = '/brandDetail16';

  @override
  State<BrandDetailScreen16> createState() => _BrandDetailScreen16State();
}

class _BrandDetailScreen16State extends State<BrandDetailScreen16> {
  final ApiProvider _apiProvider = ApiProvider();

  List<Product> _products = [];

  bool _isLoadingInitialData = true;
  String? _initialDataErrorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProductsByBrand();
  }

  Future<void> _fetchProductsByBrand() async {
    setState(() {
      _isLoadingInitialData = true;
      _initialDataErrorMessage = null;
    });

    try {
      final productResponse =
          await _apiProvider
              .getProducts(); // Returns ApiResponse<List<Product>>
      print(
        'BrandDetailScreen16: Raw API Response Message: ${productResponse.message}',
      );
      if (productResponse.data != null) {
        print(
          'BrandDetailScreen16: Raw API Response Data (first 500 chars): ${productResponse.data.toString().substring(0, productResponse.data!.length > 500 ? 500 : productResponse.data!.length)}',
        );
      } else {
        print('BrandDetailScreen16: Raw API Response Data: null');
      }

      if (mounted) {
        List<Product> allFetchedProducts = productResponse.data ?? [];

        print(
          'BrandDetailScreen16: Total products fetched from API: ${allFetchedProducts.length}',
        );
        print(
          'BrandDetailScreen16: Filtering for brandId: ${widget.brandId} (${widget.brandName})',
        );

        List<Product> filteredProducts =
            allFetchedProducts.where((p) {
              // Add more verbose logging for each product's brandId
              print(
                'BrandDetailScreen16: Checking product "${p.name}" (ID: ${p.id}) with brandId: ${p.brandId}, brandName: ${p.brandName}',
              );
              return p.brandId == widget.brandId;
            }).toList();

        print(
          'BrandDetailScreen16: Total products after filtering: ${filteredProducts.length}',
        );

        setState(() {
          _products = filteredProducts;
          _isLoadingInitialData = false;
        });
        print(
          'BrandDetailScreen16: Displaying ${filteredProducts.length} products for brand: ${widget.brandName}',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _initialDataErrorMessage =
              'Failed to load products: ${e.toString().replaceFirst('Exception: ', '')}';
          _isLoadingInitialData = false;
        });
        print('BrandDetailScreen16: Error fetching products: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingInitialData) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Center(
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
                'Loading products for ${widget.brandName}...',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_initialDataErrorMessage != null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Center(
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
                  _initialDataErrorMessage!,
                  style: GoogleFonts.montserrat(
                    color: AppColors.errorRed,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _fetchProductsByBrand,
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
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              child: _buildSearchBar(),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildProductGrid(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.backgroundLight,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Text(
        widget.brandName,
        style: GoogleFonts.playfairDisplay(
          color: AppColors.textDark,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: <Widget>[
        IconButton(
          icon: const Icon(
            Icons.notifications_none_outlined,
            color: AppColors.subtleText,
            size: 28,
          ),
          onPressed: () {
            print('Notifications Tapped from Brand Detail Screen');
          },
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.searchBarBackground,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.searchBarBorder),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.search, color: AppColors.subtleText),
          const SizedBox(width: 10),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(fontSize: 16, color: AppColors.textDark),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.camera_alt_outlined,
              color: AppColors.subtleText,
            ),
            onPressed: () {
              print('Camera search tapped');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    if (_products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'No products found for this brand, or brand ID is not available in API response.',
            style: GoogleFonts.montserrat(
              color: AppColors.subtleText,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 0.75,
        ),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          return _buildProductCard(_products[index]);
        },
      );
    }
  }

  Widget _buildProductCard(Product product) {
    String imageUrlToDisplay = '';
    if (product.imageUrls != null && product.imageUrls!.isNotEmpty) {
      imageUrlToDisplay = product.imageUrls!.first;
    }

    final NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    final double productPrice = product.price?.toDouble() ?? 0.0;

    String displayCurrentPrice = currencyFormatter.format(productPrice);

    // Use brandName and categoryName from Product model
    final String brandNameToDisplay = product.brandName ?? 'Unknown Brand';
    final String categoryNameToDisplay =
        product.categoryName ?? 'Unknown Category';

    return GestureDetector(
      onTap: () {
        print('Tapped on product: ${product.name}');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ProductDetailScreen(
                  product: product,
                  brandName: brandNameToDisplay,
                  categoryName: categoryNameToDisplay,
                ),
          ),
        );
      },
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                  child: Image.network(
                    imageUrlToDisplay,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          height: 120,
                          color: AppColors.imagePlaceholderLight,
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: AppColors.accentGrey,
                            ),
                          ),
                        ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackgroundLight,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.textDark.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.favorite_border,
                      color: AppColors.subtleText,
                      size: 20,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryGold,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: AppColors.lightText),
                      onPressed: () {
                        print('Add ${product.name} to cart');
                      },
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '$brandNameToDisplay · $categoryNameToDisplay',
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      color: AppColors.subtleText,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    product.name ?? 'Unknown Product',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        displayCurrentPrice,
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGold,
                        ),
                      ),
                    ],
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
