import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thave_luxe_app/tugas_enam_belas/api/service_api.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/produk_response.dart';

import 'package:thave_luxe_app/tugas_enam_belas/models/add_to_cart_response.dart';

class HomeScreen16 extends StatefulWidget {
  const HomeScreen16({super.key});
  static const String id = '/home16';

  @override
  State<HomeScreen16> createState() => _HomeScreen16State();
}

class _HomeScreen16State extends State<HomeScreen16> {
  final TokoOnlineService _tokoOnlineService = TokoOnlineService();
  List<Product> _products = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProducts(); // Fetch products when the screen initializes
  }

  // --- Fetch Products Logic ---
  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null; // Clear previous errors
    });

    try {
      final ProductResponse response = await _tokoOnlineService.getProducts();
      // Safely check if data is a List and map it to Product objects
      if (response.data is List) {
        setState(() {
          _products = List<Product>.from(
            response.data!.map((x) => Product.fromJson(x)),
          );
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

  // --- Add to Cart Logic ---
  Future<void> _addToCart(int productId) async {
    try {
      // Assuming quantity of 1 for simplicity, you can make this dynamic
      final AddToCartResponse response = await _tokoOnlineService.addToCart(
        productId: productId,
        quantity: 1,
      );

      _showSnackBar(response.message ?? "Product added to cart!", Colors.green);
    } on Exception catch (e) {
      print('Add to Cart Error: $e'); // Log the error for debugging
      _showSnackBar(e.toString().replaceFirst('Exception: ', ''), Colors.red);
    } finally {
      // setState(() { _isLoading = false; }); // Uncomment if you uncommented global loading
    }
  }

  // Helper method to show SnackBar messages
  void _showSnackBar(String message, Color color) {
    if (mounted) {
      // Ensure the widget is still mounted before showing SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating, // Floating behavior
          margin: const EdgeInsets.all(10), // Margin for floating
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Thave Luxe Store',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(
              255,
              255,
              254,
              250,
            ), // Gold/Off-white for title
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black, // Dark app bar
        iconTheme: const IconThemeData(
          color: Color.fromARGB(255, 255, 254, 250),
        ), // Gold/Off-white icons
        // Add actions like Cart or Profile
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              // TODO: Navigate to Cart Screen
              _showSnackBar("Cart functionality coming soon!", Colors.blue);
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              // TODO: Navigate to Profile Screen
              _showSnackBar("Profile functionality coming soon!", Colors.blue);
            },
          ),
        ],
      ),
      body: Container(
        // Background gradient consistent with login/register screens
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black87, Colors.black54],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: RefreshIndicator(
          // Added Pull-to-Refresh functionality
          onRefresh: _fetchProducts,
          color: const Color.fromARGB(
            255,
            180,
            154,
            129,
          ), // Gold color for refresh indicator
          child:
              _isLoading
                  ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color.fromARGB(
                          255,
                          180,
                          154,
                          129,
                        ), // Gold loading indicator
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
                              color: Colors.redAccent,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _fetchProducts,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                180,
                                154,
                                129,
                              ),
                              foregroundColor: Colors.black, // Text color
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
                  : _products.isEmpty
                  ? Center(
                    child: Text(
                      'No products found.',
                      style: GoogleFonts.playfairDisplay(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                  )
                  : GridView.builder(
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // Two columns for products
                          crossAxisSpacing: 16.0,
                          mainAxisSpacing: 16.0,
                          childAspectRatio:
                              0.7, // Aspect ratio of each product card
                        ),
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      return _buildProductCard(product);
                    },
                  ),
        ),
      ),
    );
  }

  // Widget to build individual product cards
  Widget _buildProductCard(Product product) {
    return Card(
      elevation: 8,
      color: Colors.black.withOpacity(0.7), // Semi-transparent dark card
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Placeholder for product image (or you can integrate NetworkImage if URLs are available)
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[850], // Darker background for image area
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.shopping_bag_outlined, // Placeholder icon
                  color: Colors.white54,
                  size: 50,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              product.name ?? 'Unknown Product',
              style: GoogleFonts.playfairDisplay(
                color: const Color.fromARGB(
                  255,
                  255,
                  254,
                  250,
                ), // Gold/Off-white for product name
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis, // Handle long names
            ),
            const SizedBox(height: 4),
            Text(
              'Rp ${product.price?.toStringAsFixed(0) ?? 'N/A'}', // Format price
              style: GoogleFonts.playfairDisplay(
                color: const Color.fromARGB(
                  255,
                  180,
                  154,
                  129,
                ), // Gold price color
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                onPressed:
                    () => _addToCart(
                      product.id!,
                    ), // Pass product ID to add to cart
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(
                    255,
                    180,
                    154,
                    129,
                  ), // Gold button background
                  foregroundColor: Colors.black, // Button text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: const Text(
                  'Add to Cart',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
