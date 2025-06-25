import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thave_luxe_app/constant/app_color.dart'; // Ensure this path is correct
import 'package:thave_luxe_app/tugas_enam_belas/models/produk_response.dart'; // Assuming Product model is defined here

class CartScreen16 extends StatefulWidget {
  const CartScreen16({super.key});
  static const String id = '/cart16'; // Define a static ID for routing

  @override
  State<CartScreen16> createState() => _CartScreen16State();
}

class _CartScreen16State extends State<CartScreen16> {
  List<CartItem> _cartItems = [];

  @override
  void initState() {
    super.initState();
    _loadMockCartItems(); // Load some dummy data when the screen initializes
  }

  // Simulates loading cart items (replace with actual data fetching in production)
  void _loadMockCartItems() {
    setState(() {
      _cartItems = [
        CartItem(
          product: Product(
            id: 1,
            name: "Classic Diamond Ring 18K White Gold",
            description:
                "An exquisite engagement ring featuring a brilliant-cut diamond.",
            price: 7500000000,
            // imageUrl: 'https://placehold.co/100x100/1e1e1e/b49a81?text=Ring' // Example if you had image URLs
          ),
          quantity: 1,
        ),
        CartItem(
          product: Product(
            id: 2,
            name: "Midnight Sapphire Drop Necklace",
            description:
                "A breathtaking necklace adorned with a deep blue sapphire pendant.",
            price: 1200000000,
            // imageUrl: 'https://placehold.co/100x100/1e1e1e/b49a81?text=Necklace'
          ),
          quantity: 2,
        ),
        CartItem(
          product: Product(
            id: 3,
            name: "Artisan Gold Chronograph Watch",
            description:
                "A luxury timepiece with intricate mechanical details and a polished gold finish.",
            price: 5000000000,
            // imageUrl: 'https://placehold.co/100x100/1e1e1e/b49a81?text=Watch'
          ),
          quantity: 1,
        ),
      ];
    });
  }

  // Calculates the total price of all items in the cart
  double _calculateTotalPrice() {
    return _cartItems.fold(
      0.0,
      (sum, item) => sum + (item.product.price! * item.quantity),
    );
  }

  // Helper method to show SnackBar messages for user feedback
  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating, // Makes it float above content
          margin: const EdgeInsets.all(10), // Adds margin around the snackbar
        ),
      );
    }
  }

  // Updates the quantity of a specific product in the cart
  void _updateQuantity(int productId, int delta) {
    setState(() {
      final index = _cartItems.indexWhere(
        (item) => item.product.id == productId,
      );
      if (index != -1) {
        _cartItems[index].quantity += delta;
        if (_cartItems[index].quantity <= 0) {
          _cartItems.removeAt(
            index,
          ); // Remove item if quantity drops to 0 or less
          _showSnackBar("Item removed from cart.", AppColors.redAccent);
        } else {
          _showSnackBar("Quantity updated.", AppColors.blue);
        }
      }
    });
  }

  // Removes a specific item completely from the cart
  void _removeItem(int productId) {
    setState(() {
      _cartItems.removeWhere((item) => item.product.id == productId);
      _showSnackBar("Item removed from cart.", AppColors.redAccent);
    });
  }

  // Placeholder for checkout functionality
  void _checkout() {
    if (_cartItems.isEmpty) {
      _showSnackBar(
        "Your cart is empty. Add items to checkout!",
        AppColors.redAccent,
      );
      return;
    }
    _showSnackBar(
      "Proceeding to checkout for total: Rp ${_calculateTotalPrice().toStringAsFixed(0)}",
      AppColors.primaryGold,
    );
    // TODO: Implement actual checkout process (e.g., navigate to payment screen, process order)
    // Navigator.pushNamed(context, CheckoutScreen.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.darkBackground, // Use dark background for luxury feel
      appBar: AppBar(
        title: Text(
          'Your Cart',
          style: GoogleFonts.playfairDisplay(
            // Elegant font for the title
            fontWeight: FontWeight.bold,
            color: AppColors.lightText,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.darkBackground,
        elevation: 0, // No shadow for a sleek look
        leading: IconButton(
          // Back button for navigation
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.lightText),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
      ),
      body: Container(
        // Luxurious gradient background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.darkBackground,
              AppColors.gradientDark, // Slightly lighter dark for subtle depth
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child:
                  _cartItems
                          .isEmpty // Display message if cart is empty
                      ? Center(
                        child: Text(
                          'Your cart is empty. Start adding some luxury items!',
                          style: GoogleFonts.playfairDisplay(
                            color: AppColors.subtleGrey,
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                      : ListView.builder(
                        // Display cart items in a scrollable list
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _cartItems.length,
                        itemBuilder: (context, index) {
                          final item = _cartItems[index];
                          return _buildCartItemCard(
                            item,
                          ); // Build each cart item card
                        },
                      ),
            ),
            // Cart Summary and Checkout Button always at the bottom
            // Only show if there are items in the cart
            _cartItems.isNotEmpty
                ? _buildCartSummary()
                : const SizedBox.shrink(), // Hides the summary if cart is empty
          ],
        ),
      ),
    );
  }

  // Helper widget to build each individual cart item card
  Widget _buildCartItemCard(CartItem item) {
    return Card(
      elevation: 5, // Subtle shadow for depth
      color: AppColors.cardBackground, // Dark card background
      margin: const EdgeInsets.symmetric(
        vertical: 8.0,
      ), // Spacing between cards
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ), // Rounded corners
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image Placeholder
            Container(
              width: 90, // Larger image placeholder
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.imagePlaceholderBackground,
                borderRadius: BorderRadius.circular(10),
                // If you had image URLs uncomment this section:
                // image: item.product.imageUrl != null && item.product.imageUrl!.isNotEmpty
                //     ? DecorationImage(
                //         image: NetworkImage(item.product.imageUrl!),
                //         fit: BoxFit.cover,
                //       )
                //     : null,
              ),
              alignment: Alignment.center,
              // If you were displaying network images, you'd use this:
              // child: item.product.imageUrl != null && item.product.imageUrl!.isNotEmpty
              //     ? ClipRRect(
              //         borderRadius: BorderRadius.circular(10),
              //         child: Image.network(
              //           item.product.imageUrl!,
              //           width: 90,
              //           height: 90,
              //           fit: BoxFit.cover,
              //           errorBuilder: (context, error, stackTrace) => const Icon(
              //             Icons.image_not_supported_outlined,
              //             color: AppColors.subtleGrey,
              //             size: 40,
              //           ),
              //         ),
              //       )
              //     :
              // This icon will always be shown now:
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: AppColors.subtleGrey,
                size: 45,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name ?? 'Unknown Product',
                    style: GoogleFonts.playfairDisplay(
                      color: AppColors.lightText,
                      fontSize: 17, // Slightly larger font for product name
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Price: Rp ${item.product.price?.toStringAsFixed(0) ?? 'N/A'}', // Display individual item price
                    style: GoogleFonts.playfairDisplay(
                      color:
                          AppColors
                              .subtleGrey, // Subtle grey for individual price
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Quantity control buttons
                      _buildQuantityButton(
                        Icons.remove,
                        () => _updateQuantity(item.product.id!, -1),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                          item.quantity.toString(),
                          style: GoogleFonts.playfairDisplay(
                            color: AppColors.lightText,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      _buildQuantityButton(
                        Icons.add,
                        () => _updateQuantity(item.product.id!, 1),
                      ),
                      const Spacer(), // Pushes the remove button to the right
                      // Remove button
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: AppColors.redAccent,
                          size: 24,
                        ),
                        onPressed: () => _removeItem(item.product.id!),
                        tooltip: 'Remove Item',
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

  // Reusable widget for quantity control buttons
  Widget _buildQuantityButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      // Using InkWell for a custom button feel with ripple effect
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.primaryGold.withOpacity(
            0.1,
          ), // Very subtle gold tint
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.primaryGold.withOpacity(0.3),
          ), // Light gold border
        ),
        child: Icon(icon, color: AppColors.primaryGold, size: 20),
      ),
    );
  }

  // Widget for displaying the cart summary and checkout button at the bottom
  Widget _buildCartSummary() {
    return Container(
      padding: const EdgeInsets.all(20.0), // More padding for a premium feel
      decoration: BoxDecoration(
        color: AppColors.cardBackground, // Matches card background
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ), // Rounded top corners
        boxShadow: [
          // Subtle shadow for elevation
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            spreadRadius: 5,
            blurRadius: 15,
            offset: const Offset(0, -5), // Shadow pointing upwards
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Takes minimum space
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Grand Total:', // More formal label
                style: GoogleFonts.playfairDisplay(
                  color: AppColors.lightText,
                  fontSize: 22, // Larger total text
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Rp ${_calculateTotalPrice().toStringAsFixed(0)}', // Formatted total price
                style: GoogleFonts.playfairDisplay(
                  color: AppColors.primaryGold, // Prominent gold for total
                  fontSize: 26, // Even larger for total price
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 25), // More spacing
          SizedBox(
            width: double.infinity, // Button spans full width
            child: ElevatedButton(
              onPressed: _checkout,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold, // Solid gold button
                foregroundColor: AppColors.darkBackground, // Dark text on gold
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    14,
                  ), // More rounded corners
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 18,
                ), // Taller button
              ),
              child: Text(
                'Proceed to Checkout',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 19, // Larger button text
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// A simple model for items in the cart.
// In a real app, you might have a more complex cart item structure
// that includes product details and quantity.
class CartItem {
  final Product product; // The product associated with this cart item
  int quantity; // The quantity of this product in the cart

  CartItem({required this.product, this.quantity = 1}); // Constructor
}
