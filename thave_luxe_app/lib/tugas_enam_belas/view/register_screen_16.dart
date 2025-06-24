import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thave_luxe_app/tugas_enam_belas/api/service_api.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/auth_response.dart'; // Assuming User model is here or similar
import 'package:thave_luxe_app/tugas_enam_belas/models/produk_response.dart';

// You might also need to import your AuthProvider if you use it for logout state management
// import 'package:thave_luxe_app/tugas_enam_belas/api/auth_provider.dart';

class HomeScreen16 extends StatefulWidget {
  const HomeScreen16({super.key});
  static const String id = '/home16';

  @override
  State<HomeScreen16> createState() => _HomeScreen16State();
}

class _HomeScreen16State extends State<HomeScreen16> {
  // Service instance for API calls
  final TokoOnlineService _tokoOnlineService = TokoOnlineService();

  // State for loading indicator
  bool _isLoading = true; // Start as loading to fetch initial data
  String? _errorMessage;
  List<Product> _products = [];
  // Removed _banners as per request
  List<Map<String, String>> _categories = [];
  User? _currentUser; // To store logged-in user info

  int _currentBottomNavIndex = 0; // State for bottom navigation bar

  @override
  void initState() {
    super.initState();
    _fetchHomeData();
  }

  // --- Fetch Home Data Logic ---
  Future<void> _fetchHomeData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null; // Clear previous errors
    });

    try {
      // Simulate fetching user profile (if available from your service)
      // For this example, we'll just mock a user.
      // In a real app, you'd likely get this from AuthProvider or a persistent store
      // after login, or fetch it from the API with a token.
      _currentUser = User(
        id: 1,
        name: "Luxury Lover",
        email: "user@example.com",
      ); // Mock user

      // Removed _banners fetching as per request
      _categories = await _tokoOnlineService.getCategories();
      _products = await _tokoOnlineService.getProducts();
    } on Exception catch (e) {
      print('Home Screen Data Fetch Error: $e');
      setState(() {
        _errorMessage =
            "Failed to load data: ${e.toString().replaceFirst('Exception: ', '')}";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // --- Logout Logic ---
  Future<void> _logout() async {
    // In a real application, you would:
    // 1. Clear any stored authentication tokens (e.g., SharedPreferences, secure storage).
    // 2. Update your authentication provider's state.
    // Example: await AuthProvider.of(context).logout();

    // For this example, we'll just navigate back to the login screen.
    Navigator.pushReplacementNamed(context, '/login16');
  }

  // Helper method to show SnackBar messages
  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(10),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900], // Dark background for consistency
      appBar: AppBar(
        backgroundColor: Colors.grey[900], // Match scaffold background
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Thave Luxe',
          style: GoogleFonts.playfairDisplay(
            color: const Color.fromARGB(255, 180, 154, 129), // Gold color
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white70),
            onPressed: () {
              _showSnackBar('Search tapped!', Colors.blue);
            },
            tooltip: 'Search',
          ),
          IconButton(
            icon: const Icon(
              Icons.shopping_cart_outlined,
              color: Colors.white70,
            ),
            onPressed: () {
              _showSnackBar('Shopping Cart tapped!', Colors.blue);
            },
            tooltip: 'Shopping Cart',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white70),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color.fromARGB(255, 180, 154, 129),
                  ),
                ),
              )
              : _errorMessage != null
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 50,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(
                          color: Colors.redAccent,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _fetchHomeData, // Retry button
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            180,
                            154,
                            129,
                          ),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Retry',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Message (moved below AppBar for consistency)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Welcome, ${_currentUser?.name ?? 'Guest'}!',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(
                            255,
                            255,
                            254,
                            250,
                          ), // Off-white
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Banners Carousel (Removed as per request)
                    // SizedBox(
                    //   height: 200, // Fixed height for banners
                    //   child: PageView.builder(
                    //     itemCount: _banners.length,
                    //     itemBuilder: (context, index) {
                    //       return Padding(
                    //         padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    //         child: ClipRRect(
                    //           borderRadius: BorderRadius.circular(12),
                    //           child: Image.network(
                    //             _banners[index],
                    //             fit: BoxFit.cover,
                    //             width: double.infinity,
                    //             errorBuilder: (context, error, stackTrace) => Container(
                    //               color: Colors.grey[800],
                    //               alignment: Alignment.center,
                    //               child: const Icon(Icons.broken_image, color: Colors.white54, size: 40),
                    //             ),
                    //           ),
                    //         ),
                    //       );
                    //     },
                    //   ),
                    // ),
                    // const SizedBox(height: 24), // Removed associated spacing

                    // Categories Section
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Text(
                        'Shop by Category',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: const Color.fromARGB(
                            255,
                            180,
                            154,
                            129,
                          ), // Gold color
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 100, // Fixed height for category row
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          return GestureDetector(
                            onTap: () {
                              _showSnackBar(
                                '${category['name']} Category tapped!',
                                Colors.blue,
                              );
                            },
                            child: Container(
                              width: 90,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundColor: const Color.fromARGB(
                                      255,
                                      180,
                                      154,
                                      129,
                                    ).withOpacity(0.2),
                                    child: Icon(
                                      // Corrected parsing of hex string to IconData
                                      IconData(
                                        int.parse(category['icon']!, radix: 16),
                                        fontFamily: 'MaterialIcons',
                                      ),
                                      color: const Color.fromARGB(
                                        255,
                                        180,
                                        154,
                                        129,
                                      ),
                                      size: 30,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    category['name']!,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.roboto(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Featured Products Grid
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Text(
                        'Featured Products',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: const Color.fromARGB(
                            255,
                            180,
                            154,
                            129,
                          ), // Gold color
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: GridView.builder(
                        shrinkWrap: true, // Important for nested scrolling
                        physics:
                            const NeverScrollableScrollPhysics(), // Disable grid scrolling
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, // 2 items per row
                              crossAxisSpacing: 12.0,
                              mainAxisSpacing: 12.0,
                              childAspectRatio:
                                  0.7, // Adjust as needed for card height
                            ),
                        itemCount: _products.length,
                        itemBuilder: (context, index) {
                          final product = _products[index];
                          return GestureDetector(
                            onTap: () {
                              _showSnackBar(
                                'Tapped on ${product.name}',
                                Colors.blue,
                              );
                            },
                            child: Card(
                              color: Colors.black.withOpacity(0.7),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(
                                  color: Color.fromARGB(
                                    255,
                                    180,
                                    154,
                                    129,
                                  ), // Gold border
                                  width: 0.5,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                    child: Image.network(
                                      product.imageUrl,
                                      height:
                                          150, // Fixed height for product image
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                                height: 150,
                                                width: double.infinity,
                                                color: Colors.grey[800],
                                                alignment: Alignment.center,
                                                child: const Icon(
                                                  Icons.broken_image,
                                                  color: Colors.white54,
                                                  size: 40,
                                                ),
                                              ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.brand ?? 'Unknown Brand',
                                          style: GoogleFonts.roboto(
                                            fontSize: 12,
                                            color: Colors.white54,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          product.name,
                                          style: GoogleFonts.playfairDisplay(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            if (product.oldPrice != null &&
                                                product.oldPrice! >
                                                    product.price)
                                              Text(
                                                '\$${product.oldPrice!.toStringAsFixed(2)}',
                                                style: GoogleFonts.roboto(
                                                  fontSize: 13,
                                                  color: Colors.white38,
                                                  decoration:
                                                      TextDecoration
                                                          .lineThrough,
                                                ),
                                              ),
                                            if (product.oldPrice != null &&
                                                product.oldPrice! >
                                                    product.price)
                                              const SizedBox(width: 8),
                                            Text(
                                              '\$${product.price.toStringAsFixed(2)}',
                                              style: GoogleFonts.roboto(
                                                fontSize: 16,
                                                color: const Color.fromARGB(
                                                  255,
                                                  255,
                                                  254,
                                                  250,
                                                ), // Off-white price
                                                fontWeight: FontWeight.w600,
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
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentBottomNavIndex,
        onTap: (index) {
          setState(() {
            _currentBottomNavIndex = index;
            // Handle navigation based on index
            if (index == 0) {
              _showSnackBar('Home tapped!', Colors.blue);
            } else if (index == 1) {
              _showSnackBar('Categories tapped!', Colors.blue);
            } else if (index == 2) {
              _showSnackBar('Wishlist tapped!', Colors.blue);
            } else if (index == 3) {
              _showSnackBar('Account tapped!', Colors.blue);
            }
          });
        },
        selectedItemColor: const Color.fromARGB(
          255,
          180,
          154,
          129,
        ), // Gold color
        unselectedItemColor: Colors.white54,
        backgroundColor: Colors.black, // Dark background
        type: BottomNavigationBarType.fixed, // Ensure all items are visible
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
