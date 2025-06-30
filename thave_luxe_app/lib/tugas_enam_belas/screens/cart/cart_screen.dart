import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:thave_luxe_app/constant/app_color.dart';
import 'package:thave_luxe_app/tugas_enam_belas/api/api_provider.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/app_models.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/cart/checkout_detail_screen.dart';

class CartScreen16 extends StatefulWidget {
  const CartScreen16({super.key});
  static const String id = '/cart16';

  @override
  State<CartScreen16> createState() => _CartScreen16State();
}

class _CartScreen16State extends State<CartScreen16> {
  final ApiProvider _apiService = ApiProvider();
  List<CartItem> _cartItems = [];
  bool _isLoading = true;
  String? _errorMessage;

  final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _fetchCartItems();
  }

  Future<void> _fetchCartItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final ApiResponse<List<CartItem>> response = await _apiService.getCart();
      if (mounted) {
        setState(() {
          _cartItems = response.data ?? [];
        });
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  double _calculateTotalPrice() {
    return _cartItems.fold(
      0.0,
      (sum, item) =>
          sum + (item.product?.price?.toDouble() ?? 0.0) * (item.quantity ?? 0),
    );
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.montserrat(
              color: AppColors.textLight,
            ), // Adjusted for light background snackbar
          ),
          backgroundColor: color,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(10),
        ),
      );
    }
  }

  Future<void> _updateQuantity(int productId, int delta) async {
    final existingCartItem = _cartItems.firstWhere(
      (item) => item.product?.id == productId,
      orElse: () => CartItem(),
    );

    if (existingCartItem.product?.id == null ||
        existingCartItem.quantity == null) {
      _showSnackBar(
        "Invalid cart item data for quantity update.",
        AppColors.redAccent,
      );
      return;
    }

    final newQuantity = (existingCartItem.quantity!) + delta;
    final int availableStock = existingCartItem.product?.stock ?? 0;

    if (newQuantity > availableStock) {
      _showSnackBar(
        "Cannot add more: Only $availableStock items in stock.",
        AppColors.redAccent,
      );
      return;
    }

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
        if (existingCartItem.id != null) {
          await _apiService.deleteCartItem(cartItemId: existingCartItem.id!);
          _showSnackBar("Item removed from cart.", AppColors.redAccent);
        } else {
          _showSnackBar(
            "Cannot remove item: Cart item ID is null.",
            AppColors.redAccent,
          );
        }
      } else {
        await _apiService.addToCart(
          productId: existingCartItem.product!.id!,
          quantity: newQuantity,
        );
        _showSnackBar("Quantity updated.", AppColors.blue);
      }
      await _fetchCartItems();
    } on Exception catch (e) {
      _showSnackBar(
        'Failed to update quantity: ${e.toString().replaceFirst('Exception: ', '')}',
        AppColors.redAccent,
      );
    } finally {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _removeItem(int cartItemId) async {
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
      await _apiService.deleteCartItem(cartItemId: cartItemId);
      _showSnackBar("Item removed from cart.", AppColors.redAccent);
      await _fetchCartItems();
    } on Exception catch (e) {
      _showSnackBar(
        'Failed to remove item: ${e.toString().replaceFirst('Exception: ', '')}',
        AppColors.redAccent,
      );
    } finally {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _checkout() async {
    if (_cartItems.isEmpty) {
      _showSnackBar(
        "Your cart is empty. Add items to checkout!",
        AppColors.redAccent,
      );
      return;
    }

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
      final ApiResponse<CheckoutResponseData> response =
          await _apiService.checkout();
      _showSnackBar(
        response.message ?? "Checkout successful!",
        AppColors.green,
      );
      if (mounted) {
        Navigator.of(context).pop();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CheckoutScreen16(checkoutData: response.data),
          ),
        );
      }
      setState(() {
        _cartItems = [];
      });
    } on Exception catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
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
      backgroundColor: AppColors.backgroundLight, // Changed to light background
      appBar: AppBar(
        title: Text(
          'Your Cart',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: AppColors.textDark, // Changed to dark text
          ),
        ),
        centerTitle: true,
        backgroundColor:
            Colors.transparent, // Transparent to show body gradient
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.iconColorDark,
          ), // Changed to dark icon
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            // Updated gradient for light background
            colors: [
              AppColors.backgroundLight,
              AppColors.backgroundGradientLight,
            ],
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
                                  foregroundColor:
                                      AppColors
                                          .textLight, // Adjusted for light background
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
                              color:
                                  AppColors
                                      .subtleText, // Changed for light theme
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

  Widget _buildCartItemCard(CartItem item) {
    if (item.product == null ||
        item.product!.id == null ||
        item.product!.name == null ||
        item.product!.price == null ||
        item.quantity == null) {
      return Card(
        elevation: 5,
        color: AppColors.cardBackground, // Changed to light card background
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

    final String imageUrlToDisplay =
        item.product!.imageUrls != null && item.product!.imageUrls!.isNotEmpty
            ? item.product!.imageUrls!.first
            : '';

    return Card(
      elevation: 5,
      color: AppColors.cardBackground, // Changed to light card background
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.imagePlaceholderLight,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child:
                    imageUrlToDisplay.isNotEmpty
                        ? Image.network(
                          imageUrlToDisplay,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder:
                              (context, error, stackTrace) => const Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  color: AppColors.subtleGrey,
                                  size: 50,
                                ),
                              ),
                        )
                        : const Center(
                          child: Icon(
                            Icons.shopping_bag_outlined,
                            color: AppColors.subtleGrey,
                            size: 50,
                          ),
                        ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product!.name!,
                    style: GoogleFonts.playfairDisplay(
                      color: AppColors.textDark, // Dark text on light card
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Price: ${_currencyFormatter.format(item.product!.price!.toDouble())}',
                    style: GoogleFonts.montserrat(
                      color: AppColors.subtleText, // Subtle dark text
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildQuantityButton(
                        Icons.remove,
                        () => _updateQuantity(item.product!.id!, -1),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          item.quantity.toString(),
                          style: GoogleFonts.montserrat(
                            color: AppColors.textDark, // Dark text
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      _buildQuantityButton(
                        Icons.add,
                        () => _updateQuantity(item.product!.id!, 1),
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

  Widget _buildCartSummary() {
    return Container(
      padding: const EdgeInsets.all(25.0),
      decoration: BoxDecoration(
        color: AppColors.cardBackground, // Changed to light card background
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // More subtle shadow
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, -5), // Adjusted offset
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
                  color: AppColors.textDark, // Changed to dark text
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _currencyFormatter.format(_calculateTotalPrice()),
                style: GoogleFonts.playfairDisplay(
                  color: AppColors.primaryGold, // Gold accent for total
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
                foregroundColor:
                    AppColors.textLight, // Adjusted for light theme contrast
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
