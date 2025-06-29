import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:thave_luxe_app/constant/app_color.dart';
import 'package:thave_luxe_app/tugas_enam_belas/api/store_provider.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/category_response.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/produk_response.dart'
    hide ProductCategory; // <--- ADD THIS
import 'package:thave_luxe_app/tugas_enam_belas/screens/category/category_detail_screen.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/error_response.dart';

// ... rest of your code
class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});
  static const String id = '/category';

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final ApiProvider _apiService = ApiProvider();

  List<Category> _categories = [];
  Map<int, int> _productsCountMap = {}; // Maps categoryId to product count

  // Combined loading state for initial data
  bool _isLoadingInitialData = true;
  String? _initialDataErrorMessage;

  // Lottie animation URL to be used for all category icons
  static const String _lottieCategoryIconUrl =
      'https://lottie.host/f85bc0f6-2c32-4483-aa18-52345c4800c1/sVb4wfsdET.json'; // A general category icon

  @override
  void initState() {
    super.initState();
    _fetchInitialData(); // Fetch all necessary data when the screen initializes
  }

  // Function to fetch all initial data (categories and products)
  Future<void> _fetchInitialData() async {
    setState(() {
      _isLoadingInitialData = true;
      _initialDataErrorMessage = null;
    });

    try {
      await Future.wait([
        _fetchCategories(), // Fetch categories
        _fetchProductsAndCount(), // Fetch products and populate count map
      ]);

      if (mounted) {
        setState(() {
          _isLoadingInitialData = false;
        });
      }
    } on ErrorResponse catch (e) {
      if (mounted) {
        setState(() {
          _initialDataErrorMessage = e.message;
          _isLoadingInitialData = false;
        });
        print('CategoryScreen: Error fetching initial data: ${e.message}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _initialDataErrorMessage =
              'CategoryScreen: Failed to load initial data: ${e.toString()}';
          _isLoadingInitialData = false;
        });
        print('CategoryScreen: Unexpected error fetching initial data: $e');
      }
    }
  }

  // Function to fetch categories from the API
  Future<void> _fetchCategories() async {
    try {
      final CategoryResponse response = await _apiService.getCategories();
      if (mounted) {
        setState(() {
          _categories = response.data ?? [];
        });
        print('Categories fetched successfully: ${_categories.length} items');
      }
    } on ErrorResponse catch (e) {
      if (mounted) {
        _initialDataErrorMessage =
            _initialDataErrorMessage != null
                ? '${_initialDataErrorMessage}\nCategories: ${e.message}'
                : 'Categories: ${e.message}';
        print('Error fetching categories: ${e.message}');
      }
    } catch (e) {
      if (mounted) {
        _initialDataErrorMessage =
            _initialDataErrorMessage != null
                ? '${_initialDataErrorMessage}\nCategories: ${e.toString()}'
                : 'Categories: ${e.toString()}';
        print('Unexpected error fetching categories: $e');
      }
    }
  }

  // Function to fetch all products and then count them per category
  Future<void> _fetchProductsAndCount() async {
    try {
      final ProductResponse response = await _apiService.getProducts();
      if (mounted) {
        final Map<int, int> tempCountMap = {};
        for (var product in response.data ?? []) {
          if (product.categoryId != null) {
            tempCountMap.update(
              product.categoryId!,
              (value) => value + 1,
              ifAbsent: () => 1,
            );
          }
        }
        setState(() {
          _productsCountMap = tempCountMap;
        });
        print('Product counts per category calculated.');
      }
    } on ErrorResponse catch (e) {
      if (mounted) {
        _initialDataErrorMessage =
            _initialDataErrorMessage != null
                ? '${_initialDataErrorMessage}\nProducts: ${e.message}'
                : 'Products: ${e.message}';
        print('Error fetching products for count: ${e.message}');
      }
    } catch (e) {
      if (mounted) {
        _initialDataErrorMessage =
            _initialDataErrorMessage != null
                ? '${_initialDataErrorMessage}\nProducts: ${e.toString()}'
                : 'Products: ${e.toString()}';
        print('Unexpected error fetching products for count: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground, // Changed to dark background
      appBar: _buildAppBar(context), // Custom AppBar for category screen
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.darkBackground, AppColors.backgroundGradientEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 10.0,
                ),
                child: _buildSearchBar(), // Search bar for categories
              ),
              const SizedBox(height: 20),

              _buildSectionHeader('All Categories', null),
              const SizedBox(height: 15),

              _buildCategoryList(),
              const SizedBox(height: 20), // Padding at the bottom
            ],
          ),
        ),
      ),
    );
  }

  // Custom AppBar for the Category Screen
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.darkBackground, // Changed to dark background
      elevation: 0,
      title: Text(
        'Categories',
        style: GoogleFonts.playfairDisplay(
          // Using Playfair Display
          color: AppColors.lightText, // Changed to light text
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: <Widget>[
        IconButton(
          icon: const Icon(
            Icons.notifications_none_outlined,
            color: AppColors.subtleGrey, // Changed to subtle grey
            size: 28,
          ), // Notification icon
          onPressed: () {
            print('Notifications Tapped from Category Screen');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Notifications (Coming Soon!)',
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

  // Builds the Search Bar (reused for consistency)
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color:
            AppColors.cardBackgroundDark, // Changed to darker card background
        borderRadius: BorderRadius.circular(
          16,
        ), // Adjusted to 16 for consistency
        border: Border.all(
          color: AppColors.subtleGrey,
        ), // Changed to subtle grey border
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3), // Darker shadow
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.search,
            color: AppColors.subtleGrey,
          ), // Changed to subtle grey
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search categories...', // More specific hint
                hintStyle: GoogleFonts.montserrat(
                  color: AppColors.subtleText, // Changed to subtle text
                ),
                border: InputBorder.none, // No underline
                isDense: true, // Reduce vertical space
                contentPadding: EdgeInsets.zero, // Remove internal padding
              ),
              style: GoogleFonts.montserrat(
                fontSize: 16,
                color: AppColors.lightText, // Changed to light text
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.camera_alt_outlined,
              color: AppColors.subtleGrey, // Changed to subtle grey
            ), // Camera icon
            onPressed: () {
              print('Camera search tapped');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Camera Search (Coming Soon!)',
                    style: GoogleFonts.montserrat(color: AppColors.lightText),
                  ),
                  backgroundColor: AppColors.blue,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Builds a standard section header with an optional "See All" link
  Widget _buildSectionHeader(String title, VoidCallback? onSeeAllTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            title,
            style: GoogleFonts.playfairDisplay(
              // Using Playfair Display
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.lightText, // Changed to light text
            ),
          ),
          if (onSeeAllTap != null) // Only show "See All" if onTap is provided
            TextButton(
              onPressed: onSeeAllTap,
              child: Text(
                'See All',
                style: GoogleFonts.montserrat(
                  // Using Montserrat
                  color: AppColors.primaryGold, // Changed to primary gold
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Builds the list of categories (now with product count)
  Widget _buildCategoryList() {
    if (_isLoadingInitialData) {
      // Use combined loading state
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(
            color: AppColors.primaryGold,
          ), // Changed to primary gold
        ),
      );
    } else if (_initialDataErrorMessage != null) {
      // Use combined error message
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            _initialDataErrorMessage!,
            style: GoogleFonts.montserrat(
              color: AppColors.errorRed, // Changed to error red
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else if (_categories.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'No categories found.',
            style: GoogleFonts.montserrat(
              color: AppColors.subtleText, // Changed to subtle text
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else {
      return ListView.builder(
        shrinkWrap: true, // Take only as much space as needed
        physics:
            const NeverScrollableScrollPhysics(), // Disable scrolling within this list
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          // Get product count for the current category, default to 0 if not found
          final int productCount = _productsCountMap[category.id] ?? 0;
          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withOpacity(
                      0.1,
                    ), // Using primary gold
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Lottie.network(
                      _lottieCategoryIconUrl,
                      fit: BoxFit.cover,
                      width: 50,
                      height: 50,
                      repeat: true,
                      errorBuilder:
                          (context, error, stackTrace) => const Icon(
                            Icons.category_outlined,
                            color: AppColors.primaryGold, // Fallback icon color
                          ), // Fallback
                    ),
                  ),
                ),
                title: Text(
                  category.name ?? 'Unknown Category',
                  style: GoogleFonts.montserrat(
                    // Using Montserrat
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightText, // Changed to light text
                  ),
                ),
                subtitle: Text(
                  '$productCount products', // Display product count
                  style: GoogleFonts.montserrat(
                    // Using Montserrat
                    fontSize: 13,
                    color: AppColors.subtleText, // Changed to subtle text
                  ),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.subtleGrey, // Changed to subtle grey
                  size: 20,
                ),
                onTap: () {
                  print('Tapped on ${category.name}');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => CategoryDetailScreen(
                            categoryId: category.id!,
                            categoryName: category.name ?? 'Unknown Category',
                          ),
                    ),
                  );
                },
              ),
              const Divider(
                height: 1,
                indent: 70,
                endIndent: 16,
                color: AppColors.dividerDark, // Changed to divider color
              ), // Divider below the item
            ],
          );
        },
      );
    }
  }
}
