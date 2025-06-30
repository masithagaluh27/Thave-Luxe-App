import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:thave_luxe_app/constant/app_color.dart';
import 'package:thave_luxe_app/tugas_enam_belas/api/api_provider.dart'; // Menggunakan ApiProvider baru
import 'package:thave_luxe_app/tugas_enam_belas/models/app_models.dart'; // Menggunakan model tunggal
import 'package:thave_luxe_app/tugas_enam_belas/screens/category/category_detail_screen.dart'; // Path sudah benar

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});
  static const String id = '/category';

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final ApiProvider _apiService = ApiProvider(); // Menggunakan ApiProvider

  List<Category> _categories = [];
  Map<int, int> _productsCountMap = {}; // Maps categoryId to product count

  bool _isLoadingInitialData = true;
  String? _initialDataErrorMessage;

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
    } on Exception catch (e) {
      // Menggunakan Exception generik
      if (mounted) {
        setState(() {
          _initialDataErrorMessage =
              'CategoryScreen: Failed to load initial data: ${e.toString().replaceFirst('Exception: ', '')}';
          _isLoadingInitialData = false;
        });
        print('CategoryScreen: Error fetching initial data: $e');
      }
    }
  }

  // Function to fetch categories from the API
  Future<void> _fetchCategories() async {
    try {
      final ApiResponse<List<Category>> response =
          await _apiService
              .getCategories(); // Menggunakan ApiResponse<List<Category>>
      if (mounted) {
        setState(() {
          _categories = response.data ?? []; // Akses data via .data
        });
        print('Categories fetched successfully: ${_categories.length} items');
        if (_categories.isEmpty &&
            response.message != null &&
            response.message!.isNotEmpty) {
          // Hanya set error jika tidak ada data dan ada pesan dari API
          _initialDataErrorMessage = response.message;
        } else if (_categories.isEmpty) {
          // Pesan default jika tidak ada data
          _initialDataErrorMessage = 'No categories found.';
        }
      }
    } on Exception catch (e) {
      // Menggunakan Exception generik
      if (mounted) {
        // Gabungkan pesan error jika sudah ada
        _initialDataErrorMessage =
            _initialDataErrorMessage != null
                ? '$_initialDataErrorMessage\nCategories: ${e.toString().replaceFirst('Exception: ', '')}'
                : 'Categories: ${e.toString().replaceFirst('Exception: ', '')}';
        print('Error fetching categories: $e');
      }
    }
  }

  // Function to fetch all products and then count them per category
  Future<void> _fetchProductsAndCount() async {
    try {
      final ApiResponse<List<Product>> response =
          await _apiService
              .getProducts(); // Menggunakan ApiResponse<List<Product>>
      if (mounted) {
        final Map<int, int> tempCountMap = {};
        for (var product in response.data ?? []) {
          // Akses data via .data
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
    } on Exception catch (e) {
      // Menggunakan Exception generik
      if (mounted) {
        // Gabungkan pesan error jika sudah ada
        _initialDataErrorMessage =
            _initialDataErrorMessage != null
                ? '$_initialDataErrorMessage\nProducts: ${e.toString().replaceFirst('Exception: ', '')}'
                : 'Products: ${e.toString().replaceFirst('Exception: ', '')}';
        print('Unexpected error fetching products for count: $e');
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
          // Tambahkan RefreshIndicator
          onRefresh: _fetchInitialData,
          color: AppColors.primaryGold,
          child: SingleChildScrollView(
            // Bungkus dengan SingleChildScrollView
            physics:
                const AlwaysScrollableScrollPhysics(), // Selalu bisa di-scroll, bahkan jika kontennya kecil
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 10.0,
                  ),
                  child: _buildSearchBar(),
                ),
                const SizedBox(height: 20),

                _buildSectionHeader('All Categories', null),
                const SizedBox(height: 15),

                _buildCategoryList(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.darkBackground,
      elevation: 0,
      title: Text(
        'Categories',
        style: GoogleFonts.playfairDisplay(
          color: AppColors.lightText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: <Widget>[
        IconButton(
          icon: const Icon(
            Icons.notifications_none_outlined,
            color: AppColors.subtleGrey,
            size: 28,
          ),
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

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.subtleGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.search, color: AppColors.subtleGrey),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search categories...',
                hintStyle: GoogleFonts.montserrat(color: AppColors.subtleText),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: GoogleFonts.montserrat(
                fontSize: 16,
                color: AppColors.lightText,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.camera_alt_outlined,
              color: AppColors.subtleGrey,
            ),
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

  Widget _buildSectionHeader(String title, VoidCallback? onSeeAllTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            title,
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.lightText,
            ),
          ),
          if (onSeeAllTap != null)
            TextButton(
              onPressed: onSeeAllTap,
              child: Text(
                'See All',
                style: GoogleFonts.montserrat(
                  color: AppColors.primaryGold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryList() {
    if (_isLoadingInitialData) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: CircularProgressIndicator(color: AppColors.primaryGold),
        ),
      );
    } else if (_initialDataErrorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            // Menggunakan Column untuk pesan error dan tombol retry
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                onPressed: _fetchInitialData, // Tombol retry
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  foregroundColor: AppColors.darkBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Retry',
                  style: GoogleFonts.playfairDisplay(fontSize: 16),
                ),
              ),
            ],
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
              color: AppColors.subtleText,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
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
                    color: AppColors.primaryGold.withOpacity(0.1),
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
                            color: AppColors.primaryGold,
                          ),
                    ),
                  ),
                ),
                title: Text(
                  category.name ?? 'Unknown Category',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightText,
                  ),
                ),
                subtitle: Text(
                  '$productCount products',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: AppColors.subtleText,
                  ),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.subtleGrey,
                  size: 20,
                ),
                onTap: () {
                  print('Tapped on ${category.name}');
                  // Pastikan category.id tidak null sebelum navigasi
                  if (category.id != null) {
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
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Invalid category ID for navigation.',
                          style: GoogleFonts.montserrat(color: Colors.white),
                        ),
                        backgroundColor: AppColors.redAccent,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
              const Divider(
                height: 1,
                indent: 70,
                endIndent: 16,
                color: AppColors.dividerDark,
              ),
            ],
          );
        },
      );
    }
  }
}
