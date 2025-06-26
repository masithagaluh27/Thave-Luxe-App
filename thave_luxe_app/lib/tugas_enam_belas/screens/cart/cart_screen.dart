import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thave_luxe_app/constant/app_color.dart'; // Ensure this path is correct
import 'package:thave_luxe_app/tugas_enam_belas/api/cart_provider.dart'; // Import the new CartProvider
import 'package:thave_luxe_app/tugas_enam_belas/models/cart_list_response.dart'; // Import CartListResponse which defines CartItem
import 'package:thave_luxe_app/tugas_enam_belas/screens/cart/checkout_detail_screen.dart';

class CartScreen16 extends StatefulWidget {
  const CartScreen16({super.key});
  static const String id = '/cart16'; // Define a static ID for routing

  @override
  State<CartScreen16> createState() => _CartScreen16State();
}

class _CartScreen16State extends State<CartScreen16> {
  final CartProvider _cartProvider = CartProvider(); // Instantiate CartProvider
  List<CartItem> _cartItems = []; // Use CartItem model
  bool _isLoading = true; // State for loading indicator
  String? _errorMessage; // State for error messages

  @override
  void initState() {
    super.initState();
    _fetchCartItems(); // Fetch real data when the screen initializes
  }

  // Fetches cart items from the API
  Future<void> _fetchCartItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null; // Clear previous errors
    });

    try {
      final cartListResponse = await _cartProvider.getCart();
      setState(() {
        _cartItems =
            cartListResponse; // CartProvider.getCart returns List<CartItem> directly now
      });
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

  // Calculates the total price of all items in the cart
  double _calculateTotalPrice() {
    return _cartItems.fold(
      0.0,
      // Safely access product price, defaulting to 0 if product or price is null
      (sum, item) => sum + (item.product?.price ?? 0) * (item.quantity ?? 0),
    );
  }

  // Helper method to show SnackBar messages for user feedback
  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.montserrat(
              color: AppColors.lightText,
            ), // Use lightText for SnackBar content
          ),
          backgroundColor: color,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating, // Makes it float above content
          margin: const EdgeInsets.all(10), // Adds margin around the snackbar
        ),
      );
    }
  }

  Future<void> _updateQuantity(int productInCartId, int delta) async {
    // Find the item in the current local cart list using product's ID
    final existingCartItemIndex = _cartItems.indexWhere(
      (item) =>
          item.product?.id == productInCartId, // Corrected to item.product?.id
    );
    CartItem? currentItem;
    if (existingCartItemIndex != -1) {
      currentItem = _cartItems[existingCartItemIndex];
    }

    // Ensure we have a valid current item, product, and product ID before proceeding
    if (currentItem == null ||
        currentItem.product?.id == null ||
        currentItem.quantity == null) {
      _showSnackBar(
        "Invalid cart item data for quantity update.",
        AppColors.redAccent,
      );
      return;
    }

    final newQuantity =
        (currentItem.quantity!) + delta; // quantity is nullable, so assert

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

    try {
      if (newQuantity <= 0) {
        // If new quantity is zero or less, delete the item from the cart
        if (currentItem.id != null) {
          // Check if cart item ID is not null
          await _cartProvider.deleteFromCart(cartItemId: currentItem.id!);
          _showSnackBar("Item removed from cart.", AppColors.redAccent);
        } else {
          _showSnackBar(
            "Cannot remove item: Cart item ID is null.", // More specific message
            AppColors.redAccent,
          );
        }
      } else {
        // If new quantity is positive, update it via addToCart
        await _cartProvider.addToCart(
          productId:
              currentItem.product!.id!, // Use the product's ID for the API call
          quantity: newQuantity,
        );
        _showSnackBar("Quantity updated.", AppColors.blue);
      }
      // Always re-fetch the cart to ensure UI is in sync with backend
      await _fetchCartItems();
    } on Exception catch (e) {
      _showSnackBar(
        'Failed to update quantity: ${e.toString().replaceFirst('Exception: ', '')}',
        AppColors.redAccent,
      );
    } finally {
      if (mounted) {
        Navigator.of(context).pop(); // Dismiss loading dialog
      }
    }
  }

  // Removes a specific item completely from the cart via API
  Future<void> _removeItem(int cartItemId) async {
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

    try {
      await _cartProvider.deleteFromCart(cartItemId: cartItemId);
      _showSnackBar("Item removed from cart.", AppColors.redAccent);
      await _fetchCartItems(); // Re-fetch cart after deletion
    } on Exception catch (e) {
      _showSnackBar(
        'Failed to remove item: ${e.toString().replaceFirst('Exception: ', '')}',
        AppColors.redAccent,
      );
    } finally {
      if (mounted) {
        Navigator.of(context).pop(); // Dismiss loading dialog
      }
    }
  }

  // Performs checkout via API
  Future<void> _checkout() async {
    if (_cartItems.isEmpty) {
      _showSnackBar(
        "Your cart is empty. Add items to checkout!",
        AppColors.redAccent,
      );
      return;
    }

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

    try {
      final response = await _cartProvider.checkout();
      _showSnackBar(
        response.message ?? "Checkout successful!",
        AppColors.green,
      );
      if (mounted) {
        Navigator.of(context).pop();
        Navigator.pushReplacementNamed(context, CheckoutScreen16.id);
      }
      setState(() {
        _cartItems = []; // Clear cart after successful checkout
      });
    } on Exception catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Dismiss loading dialog
        _showSnackBar(
          'Checkout failed: ${e.toString().replaceFirst('Exception: ', '')}',
          AppColors.redAccent,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: Text(
          'Your Cart',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: AppColors.lightText,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.lightText),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.darkBackground, AppColors.backgroundGradientEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
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
                                onPressed: _fetchCartItems,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryGold,
                                  foregroundColor: AppColors.darkBackground,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'Retry',
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      : _cartItems.isEmpty
                      ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40.0),
                          child: Text(
                            'Your cart is empty. Start adding some luxury items!',
                            style: GoogleFonts.playfairDisplay(
                              color: AppColors.subtleGrey,
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _cartItems.length,
                        itemBuilder: (context, index) {
                          final item = _cartItems[index];
                          return _buildCartItemCard(item);
                        },
                      ),
            ),
            _cartItems.isNotEmpty
                ? _buildCartSummary()
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  // Helper widget to build each individual cart item card
  Widget _buildCartItemCard(CartItem item) {
    // Add null checks for crucial properties before rendering the card.
    // If product, product ID, product name, or product price are null,
    // we can't display this item correctly, so show a placeholder/error card.
    if (item.product == null ||
        item.product!.id == null ||
        item.product!.name == null ||
        item.product!.price == null ||
        item.quantity == null) {
      return Card(
        elevation: 5,
        color: AppColors.cardBackgroundLight,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Invalid cart item data (missing product details). Please refresh.',
            style: GoogleFonts.montserrat(color: AppColors.redAccent),
          ),
        ),
      );
    }

    return Card(
      elevation: 5,
      color: AppColors.cardBackgroundLight,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image Placeholder or Network Image
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.imagePlaceholderLight,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: AppColors.subtleGrey,
                size: 50,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product!.name!, // Assert non-null after check above
                    style: GoogleFonts.playfairDisplay(
                      color: AppColors.textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Price: Rp ${item.product!.price!.toStringAsFixed(0)}', // Assert non-null
                    style: GoogleFonts.montserrat(
                      color: AppColors.subtleText,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildQuantityButton(
                        Icons.remove,
                        () => _updateQuantity(
                          item.product!.id!,
                          -1,
                        ), // Corrected: item.product!.id!
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          item.quantity.toString(),
                          style: GoogleFonts.montserrat(
                            color: AppColors.textDark,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      _buildQuantityButton(
                        Icons.add,
                        () => _updateQuantity(
                          item.product!.id!,
                          1,
                        ), // Corrected: item.product!.id!
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: AppColors.redAccent,
                          size: 28,
                        ),
                        onPressed: () {
                          if (item.id != null) {
                            // Check item.id before attempting removal
                            _removeItem(item.id!);
                          } else {
                            _showSnackBar(
                              "Cannot remove item: Cart item ID is null.",
                              AppColors.redAccent,
                            );
                          }
                        },
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
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.primaryGold.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.primaryGold.withOpacity(0.4),
            width: 1.5,
          ),
        ),
        child: Icon(icon, color: AppColors.primaryGold, size: 22),
      ),
    );
  }

  // Widget for displaying the cart summary and checkout button at the bottom
  Widget _buildCartSummary() {
    return Container(
      padding: const EdgeInsets.all(25.0),
      decoration: BoxDecoration(
        color: AppColors.darkBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Grand Total:',
                style: GoogleFonts.playfairDisplay(
                  color: AppColors.lightText,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Rp ${_calculateTotalPrice().toStringAsFixed(0)}',
                style: GoogleFonts.playfairDisplay(
                  color: AppColors.primaryGold,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _checkout,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                foregroundColor: AppColors.darkBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 20),
                elevation: 8,
              ),
              child: Text(
                'Proceed to Checkout',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
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
