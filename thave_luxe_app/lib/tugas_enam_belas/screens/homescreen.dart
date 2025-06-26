import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thave_luxe_app/constant/app_color.dart';
import 'package:thave_luxe_app/tugas_enam_belas/api/store_provider.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/produk_response.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/brands/brand_screen.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/cart/cart_screen.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/favorite/favorite_screen.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/profile/profile_screen.dart';

class HomeScreen16 extends StatefulWidget {
  const HomeScreen16({super.key});
  static const String id = '/home16';

  @override
  State<HomeScreen16> createState() => _HomeScreen16State();
}

class _HomeScreen16State extends State<HomeScreen16> {
  final ApiProvider _productProvider = ApiProvider();
  List<Product> _allProducts = [];
  List<Product> _products = [];
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();

  int _selectedIndex = 0;
  int _currentBannerIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);

  final List<Map<String, dynamic>> _banners = [
    {
      'title': 'Up to 50% Off!',
      'subtitle': '& other Stories',
      'image': 'assets/images/banner1.jpg',
      'bgColor': AppColors.imagePlaceholderLight,
      'textColor': AppColors.textDark,
    },
    {
      'title': 'New Arrivals',
      'subtitle': 'Explore the latest trends',
      'image':
          'assets/images/banner2.jpg', // Placeholder, replace with actual assets
      'bgColor': AppColors.primaryGold.withOpacity(0.2),
      'textColor': AppColors.textDark,
    },
    {
      'title': 'Limited Edition',
      'subtitle': 'Don\'t miss out!',
      'image':
          'assets/images/banner3.jpg', // Placeholder, replace with actual assets
      'bgColor': AppColors.cardBackgroundLight,
      'textColor': AppColors.textDark,
    },
  ];

  // Changed to Brands list
  final List<String> _brands = [
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

  @override
  void initState() {
    super.initState();
    _fetchProducts(); // Fetch products when the screen initializes

    //untuk gerak sendiri
    // Future.delayed(Duration(seconds: 3), () {
    //   if (mounted) {
    //     _pageController.animateToPage(
    //       (_currentBannerIndex + 1) % _banners.length,
    //       duration: Duration(milliseconds: 500),
    //       curve: Curves.easeIn,
    //     );
    //   }
    // });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose(); // Dispose the PageController
    super.dispose();
  }

  // --- Fetch Products Logic ---
  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null; // Clear previous errors
    });

    try {
      final ProductResponse response = await _productProvider.getProducts();
      if (response.data is List) {
        setState(() {
          _allProducts = List<Product>.from(
            response.data!.map((x) => Product.fromJson(x)),
          );
          _products = _allProducts; // Initially display all products
        });
      } else {
        setState(() {
          _errorMessage =
              "Invalid product data format received. Expected a list.";
        });
      }
    } on Exception catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // --- Search Filtering Logic ---
  void _filterProducts(String query) {
    if (query.isEmpty) {
      setState(() {
        _products = _allProducts; // Show all products if search is empty
      });
    } else {
      setState(() {
        _products =
            _allProducts.where((product) {
              return product.name!.toLowerCase().contains(query.toLowerCase());
            }).toList();
      });
    }
  }

  // Helper method to show SnackBar messages
  void _showSnackBar(String message, Color color) {
    if (mounted) {
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
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        // Navigate to Brands screen
        Navigator.pushNamed(context, BrandsScreen16.id);

        break;
      case 2:
        // Navigate to Cart screen
        Navigator.pushNamed(context, CartScreen16.id);

        break;
      case 3:
        // Navigate to Favorite screen
        Navigator.pushNamed(context, FavoriteScreen16.id);

        break;
      case 4:
        // Navigate to Profile screen
        Navigator.pushNamed(context, ProfileScreen16.id);

        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Thavé Luxe Store', // Retained original title
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.backgroundLight,
        elevation: 0, // Flat AppBar
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(
                Icons.notifications_outlined, // Changed to notification icon
                color: AppColors.primaryGold,
              ),
              onPressed: () {
                _showSnackBar('Notifications soon!', AppColors.blue);
                // Navigate to Notifications screen
              },
            );
          },
        ),
        actions: [],
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
        child: RefreshIndicator(
          onRefresh: _fetchProducts,
          color: AppColors.primaryGold,
          child:
              _isLoading
                  ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryGold,
                      ),
                    ),
                  )
                  : _errorMessage != null
                  ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Error: $_errorMessage',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.redAccent,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _fetchProducts,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGold,
                              foregroundColor: AppColors.textDark,
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
                  )
                  : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search Bar
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 10.0,
                          ),
                          child: TextField(
                            controller: _searchController,
                            style: GoogleFonts.montserrat(
                              color: AppColors.textDark,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search for products...',
                              hintStyle: GoogleFonts.montserrat(
                                color: AppColors.subtleText,
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: AppColors.subtleText,
                              ),
                              filled: true,
                              fillColor: AppColors.searchBarBackground,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.searchBarBorder,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.searchBarBorder,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.primaryGold,
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 14.0,
                              ),
                            ),
                            onChanged: _filterProducts, // Real-time filtering
                            onSubmitted: (query) {
                              _showSnackBar(
                                'Search submitted for: $query',
                                Colors.blueGrey,
                              );
                            },
                          ),
                        ),
                        // -Brands Tabs (horizontal menu)
                        SizedBox(
                          height: 50,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            itemCount: _brands.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 12.0),
                                child: Chip(
                                  label: Text(
                                    _brands[index],
                                    style: GoogleFonts.montserrat(
                                      color: AppColors.textDark,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  backgroundColor: AppColors.backgroundLight,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                    side: const BorderSide(
                                      color: AppColors.subtleGrey,
                                      width: 0.5,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 8,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 15),

                        // main banner
                        SizedBox(
                          height: 180,
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: _banners.length,
                            onPageChanged: (index) {
                              setState(() {
                                _currentBannerIndex = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              final banner = _banners[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: banner['bgColor'],
                                    borderRadius: BorderRadius.circular(15),
                                    image:
                                        banner['image'] != null
                                            ? DecorationImage(
                                              image: AssetImage(
                                                banner['image'],
                                              ),
                                              fit: BoxFit.cover,
                                              opacity: 0.6,
                                            )
                                            : null,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        banner['title'],
                                        style: GoogleFonts.playfairDisplay(
                                          color: banner['textColor'],
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        banner['subtitle'],
                                        style: GoogleFonts.montserrat(
                                          color: AppColors.subtleText,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _banners.length,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                              width: 8.0,
                              height: 8.0,
                              decoration: BoxDecoration(
                                color:
                                    _currentBannerIndex == index
                                        ? AppColors.primaryGold
                                        : AppColors.subtleGrey,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),

                        //"You Might Like These" Section (Horizontal Products)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'You Might Like These',
                            style: GoogleFonts.playfairDisplay(
                              color: AppColors.textDark,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          height: 280,
                          child:
                              _products.isEmpty
                                  ? Center(
                                    child: Text(
                                      'No products to show in this section.',
                                      style: GoogleFonts.montserrat(
                                        color: AppColors.subtleText,
                                      ),
                                    ),
                                  )
                                  : ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                    ),
                                    itemCount: _products.length,
                                    itemBuilder: (context, index) {
                                      final product = _products[index];
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          right: 16.0,
                                        ),
                                        child: _buildProductCard(product),
                                      );
                                    },
                                  ),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppColors.primaryGold,
        unselectedItemColor: AppColors.accentGrey,
        backgroundColor: AppColors.backgroundLight,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.montserrat(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: GoogleFonts.montserrat(
          fontWeight: FontWeight.w500,
          fontSize: 11,
        ),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            label: 'Brands', // Changed label to Brands
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return SizedBox(
      width: 160,
      child: Card(
        elevation: 4,
        color: AppColors.cardBackgroundLight, // Use a lighter card background
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () {
            _showSnackBar('Tapped on ${product.name}', Colors.blueGrey);
            // Implement navigation to product detail screen here
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color:
                          AppColors
                              .imagePlaceholderLight, // Use lighter placeholder
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.shopping_bag_outlined, // Placeholder icon
                      color: AppColors.subtleText,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product.name ?? 'Unknown Product',
                  style: GoogleFonts.montserrat(
                    // Changed font to montserrat for consistency
                    color: AppColors.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Rp ${product.price?.toStringAsFixed(0) ?? 'N/A'}',
                  style: GoogleFonts.montserrat(
                    // Changed font to montserrat for consistency
                    color: AppColors.primaryGold,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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
