import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thave_luxe_app/constant/app_color.dart';
import 'package:thave_luxe_app/tugas_enam_belas/api/product_provider.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/add_to_cart_response.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/produk_response.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/cart/cart_screen.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/profile/profile_screen.dart';

class HomeScreen16 extends StatefulWidget {
  const HomeScreen16({super.key});
  static const String id = '/home16';

  @override
  State<HomeScreen16> createState() => _HomeScreen16State();
}

class _HomeScreen16State extends State<HomeScreen16> {
  final ProductProvider _productProvider = ProductProvider();
  List<Product> _allProducts = []; // Stores the complete list of products
  List<Product> _products =
      []; // The list currently displayed (can be filtered)
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();

  int _selectedIndex = 0; // For Bottom Navigation Bar

  // Changed to Brands list
  final List<String> _brands = [
    'Nike',
    'Adidas',
    'Puma',
    'Gucci',
    'Prada',
    'Louis Vuitton',
    'Chanel',
    'Fila',
  ];

  @override
  void initState() {
    super.initState();
    _fetchProducts(); // Fetch products when the screen initializes
  }

  @override
  void dispose() {
    _searchController.dispose();
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

  // --- Add to Cart Logic ---
  Future<void> _addToCart(int productId) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGold),
            ),
          );
        },
      );

      final AddToCartResponse response = await _productProvider.addToCart(
        productId: productId,
        quantity: 1, // Assuming quantity of 1 for simplicity
      );

      if (mounted) {
        Navigator.of(context).pop(); // Dismiss loading dialog
        _showSnackBar(
          response.message ?? "Product added to cart!",
          AppColors.green,
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Dismiss loading dialog
        print('Add to Cart Error: $e'); // Log the error for debugging
        _showSnackBar(
          e.toString().replaceFirst('Exception: ', ''),
          AppColors.redAccent,
        );
      }
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

    // Handle navigation based on selected index
    switch (index) {
      case 0:
        // Already on Home, do nothing or refresh
        _showSnackBar('Home Tapped', AppColors.blue);
        break;
      case 1:
        // Navigate to Categories/Brands screen (placeholder)
        _showSnackBar('Brands Tapped', AppColors.blue);
        break;
      case 2:
        // Navigate to Cart screen
        Navigator.pushNamed(context, CartScreen16.id);
        break;
      case 3:
        // Navigate to Favorite screen (placeholder)
        _showSnackBar('Favorite Tapped', AppColors.blue);
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
                Icons.menu,
                color: AppColors.textDark,
              ), // Hamburger menu
              onPressed: () {
                Scaffold.of(
                  context,
                ).openDrawer(); // For a potential side drawer
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.search,
              color: AppColors.textDark,
            ), // Search icon
            onPressed: () {
              // Now search has a function: filter products
              _showSnackBar('Search icon tapped!', AppColors.blue);
              // You could expand this to open a dedicated search UI
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined, // Changed to notification icon
              color: AppColors.primaryGold,
            ),
            onPressed: () {
              _showSnackBar('Notifications Tapped!', AppColors.blue);
              // Navigate to Notifications screen
            },
          ),
        ],
      ),
      drawer: Drawer(
        // Placeholder for the side drawer
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(color: AppColors.primaryGold),
              child: Text(
                'Menu',
                style: GoogleFonts.playfairDisplay(
                  color: AppColors.darkBackground,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                _onItemTapped(0); // Simulate tapping home in bottom nav
              },
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Brands'), // Changed to Brands in drawer
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(1);
              },
            ),
            // Add more drawer items as needed
          ],
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
        child: RefreshIndicator(
          // Keep RefreshIndicator for the whole scrollable content
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
                    // Changed to SingleChildScrollView
                    physics:
                        const AlwaysScrollableScrollPhysics(), // Ensures it's always scrollable even if content is small
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start, // Align content to start
                      children: [
                        // --- Search Bar ---
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
                        // --- Brands Tabs (horizontal menu) ---
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

                        // --- Main Banner/Carousel Placeholder (Card Slide) ---
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Container(
                            height: 180, // Height for the banner
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.imagePlaceholderBackground,
                              borderRadius: BorderRadius.circular(15),
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
                                  'Up to 50% Off!',
                                  style: GoogleFonts.playfairDisplay(
                                    color: AppColors.textDark,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '& other Stories',
                                  style: GoogleFonts.montserrat(
                                    color: AppColors.subtleText,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  // Page indicators
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    3,
                                    (index) => Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 4.0,
                                      ),
                                      width: 8.0,
                                      height: 8.0,
                                      decoration: BoxDecoration(
                                        color:
                                            index == 0
                                                ? AppColors.primaryGold
                                                : AppColors.subtleGrey,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),

                        // --- "You Might Like These" Section (Horizontal Products) ---
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
                          height: 280, // Height for horizontal product list
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
                        const SizedBox(height: 25),

                        // --- "Top Featured Brand To Grab!" Section ---
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'Top Featured Brand To Grab!',
                            style: GoogleFonts.playfairDisplay(
                              color: AppColors.textDark,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Container(
                            height: 150, // Height for brand banner
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.primaryGold.withOpacity(
                                0.2,
                              ), // Light gold background
                              borderRadius: BorderRadius.circular(15),
                              image: const DecorationImage(
                                image: AssetImage(
                                  'assets/images/tommy_hilfiger_banner.png',
                                ), // Placeholder image
                                fit: BoxFit.cover,
                                opacity: 0.6,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'TOMMY HILFIGER',
                              style: GoogleFonts.playfairDisplay(
                                color:
                                    AppColors
                                        .textDark, // Dark text over light background
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    // Text shadow for better visibility
                                    blurRadius: 5.0,
                                    color: Colors.black.withOpacity(0.3),
                                    offset: const Offset(2.0, 2.0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30), // Spacing at bottom
                      ],
                    ),
                  ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppColors.primaryGold, // Selected icon color
        unselectedItemColor: AppColors.accentGrey, // Unselected icon color
        backgroundColor: AppColors.backgroundLight, // Background of the bar
        type: BottomNavigationBarType.fixed, // Ensures labels are always shown
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
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            label: 'Favorite',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // Widget to build individual product cards (adjusted for horizontal list)
  Widget _buildProductCard(Product product) {
    return SizedBox(
      // Wrap in SizedBox to control width in horizontal list
      width: 160, // Fixed width for horizontal cards
      child: Card(
        elevation: 4, // Slightly less elevation for horizontal cards
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
                // Removed the "Add to Cart" button from horizontal cards
                // as Zalora often has it on detail page or a quick add option.
                // You can add it back if needed, but it makes horizontal cards dense.
                // If adding back, adjust card height to accommodate.
              ],
            ),
          ),
        ),
      ),
    );
  }
}
