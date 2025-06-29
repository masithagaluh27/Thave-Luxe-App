// lib/tugas_enam_belas/screens/product/product_detail_screen.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:intl/intl.dart';

import 'package:thave_luxe_app/constant/app_color.dart';
import 'package:thave_luxe_app/tugas_enam_belas/api/store_provider.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/add_to_cart_response.dart';

import 'package:thave_luxe_app/tugas_enam_belas/models/cart_list_response.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/error_response.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/produk_response.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/profile_response.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/cart/cart_screen.dart';
import 'package:thave_luxe_app/helper/preference_handler.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final String? brandName;
  final String? categoryName;

  const ProductDetailScreen({
    super.key,
    required this.product,
    this.brandName,
    this.categoryName,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with TickerProviderStateMixin {
  static const String _baseUrl = 'https://apptoko.mobileprojp.com/public/';

  final ApiProvider _apiService = ApiProvider();

  int _selectedQuantityToAdd = 1;
  int _currentProductInCartQuantity = 0;
  late int _availableStock;

  late PageController _pageController;
  int _currentPageIndex = 0;
  late TabController _tabController;

  Map<int, ProductCategory> _categoriesMap = {};

  AppUser? _currentUser;

  bool _isLoadingInitialData = true;
  String? _initialDataErrorMessage;

  late String _productName;
  late String _productBrand;
  late String _productDescription;
  late String _displayOriginalPrice;
  late String _displayCurrentPrice;
  late String _displayDiscount;
  late List<String> _imageUrls;

  final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();

    _availableStock = widget.product.stock ?? 0;

    _productName = widget.product.name ?? 'Unknown Product';
    _productBrand =
        widget.brandName ?? widget.product.brand?.name ?? 'Unknown Brand';
    _productDescription =
        widget.product.description ?? 'No description available.';

    final double? productPrice = widget.product.price?.toDouble();
    final double? productDiscount = 0.0;

    _displayOriginalPrice = _currencyFormatter.format(productPrice ?? 0);

    if (productPrice != null &&
        productDiscount != null &&
        productDiscount > 0) {
      double discountedPrice = productPrice * (1 - (productDiscount / 100));
      _displayCurrentPrice = _currencyFormatter.format(discountedPrice);
      _displayDiscount = '${productDiscount.toStringAsFixed(0)}%';
    } else {
      _displayCurrentPrice = _currencyFormatter.format(productPrice ?? 0);
      _displayDiscount = '';
    }

    _imageUrls = [];
    if (widget.product.imageUrl != null &&
        widget.product.imageUrl!.isNotEmpty) {
      final String fullImageUrl =
          widget.product.imageUrl!.startsWith('http')
              ? widget.product.imageUrl!
              : '$_baseUrl${widget.product.imageUrl}';
      _imageUrls.add(fullImageUrl);
    } else {
      _imageUrls.add('https://placehold.co/300x300?text=No+Image');
    }

    _pageController = PageController();
    _tabController = TabController(length: _imageUrls.length, vsync: this);

    _pageController.addListener(() {
      if (_pageController.hasClients) {
        setState(() {
          _currentPageIndex = _pageController.page?.round() ?? 0;
        });
        _tabController.animateTo(_currentPageIndex);
      }
    });

    _fetchInitialData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchInitialData() async {
    setState(() {
      _isLoadingInitialData = true;
      _initialDataErrorMessage = null;
      _currentUser = null;
    });

    try {
      await _fetchCategories();

      _currentUser = await PreferenceHandler.getUserData();

      await _loadCurrentProductCartQuantity();

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
        print('ProductDetail: Error fetching initial data: ${e.message}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _initialDataErrorMessage =
              'ProductDetail: Failed to load initial data: ${e.toString()}';
          _isLoadingInitialData = false;
        });
        print('ProductDetail: Unexpected error fetching initial data: $e');
      }
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final categoryResponse = await _apiService.getCategories();
      if (mounted) {
        setState(() {
          _categoriesMap = {
            for (var c in categoryResponse.data ?? []) c.id!: c,
          };
        });
      }
    } on ErrorResponse catch (e) {
      print('ProductDetail: Error fetching categories: ${e.message}');
      if (mounted) {
        setState(() {
          _initialDataErrorMessage =
              _initialDataErrorMessage != null
                  ? '${_initialDataErrorMessage}\nCategories: ${e.message}'
                  : 'Categories: ${e.message}';
        });
      }
    } catch (e) {
      print('ProductDetail: Unexpected error fetching categories: $e');
      if (mounted) {
        setState(() {
          _initialDataErrorMessage =
              _initialDataErrorMessage != null
                  ? '${_initialDataErrorMessage}\nCategories: ${e.toString()}'
                  : 'Categories: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _loadCurrentProductCartQuantity() async {
    final int? productId = widget.product.id;
    if (productId == null) {
      debugPrint('Product ID is null, cannot load cart quantity.');
      return;
    }

    try {
      if (_currentUser?.id != null) {
        final List<CartItem> cartItems = await _apiService.getCart();

        final CartItem? existingCartItem = cartItems.firstWhere(
          (item) => item.product?.id == productId,
          orElse: () => CartItem(),
        );

        if (!mounted) return;
        setState(() {
          _currentProductInCartQuantity = existingCartItem?.quantity ?? 0;
          _selectedQuantityToAdd =
              (_currentProductInCartQuantity >= _availableStock) ? 0 : 1;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _currentProductInCartQuantity = 0;
          _selectedQuantityToAdd = _availableStock > 0 ? 1 : 0;
        });
      }
    } on ErrorResponse catch (e) {
      _showError('Could not load current cart status: ${e.message}');
    } catch (e) {
      _showError('An unexpected error occurred: $e');
    }
  }

  void _showError(String message) {
    debugPrint(message);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.montserrat(color: AppColors.lightText),
        ),
        backgroundColor: AppColors.errorRed,
      ),
    );
  }

  Future<void> _handleAddToCart() async {
    final int? productId = widget.product.id;

    if (productId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: Product ID is invalid.',
            style: GoogleFonts.montserrat(color: AppColors.lightText),
          ),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    final int totalQuantityAfterAdd =
        _selectedQuantityToAdd + _currentProductInCartQuantity;

    if (_selectedQuantityToAdd == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select a quantity to add.',
            style: GoogleFonts.montserrat(color: AppColors.lightText),
          ),
          backgroundColor: AppColors.blue,
        ),
      );
      return;
    }

    if (totalQuantityAfterAdd > _availableStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Adding $_selectedQuantityToAdd would exceed total stock. Only $_availableStock in stock. Your cart currently has $_currentProductInCartQuantity of this item.',
            style: GoogleFonts.montserrat(color: AppColors.lightText),
          ),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    if (_currentUser?.id == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please log in to add items to cart.',
            style: GoogleFonts.montserrat(color: AppColors.lightText),
          ),
          backgroundColor: AppColors.blue,
        ),
      );
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Adding to cart...',
          style: GoogleFonts.montserrat(color: AppColors.lightText),
        ),
        backgroundColor: AppColors.primaryGold,
      ),
    );

    try {
      final AddToCartResponse response = await _apiService.addToCart(
        productId: productId,
        quantity: _selectedQuantityToAdd,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response.message ?? 'Success',
            style: GoogleFonts.montserrat(color: AppColors.lightText),
          ),
          backgroundColor: AppColors.successGreen,
        ),
      );

      await _loadCurrentProductCartQuantity();

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CartScreen16()),
      );
    } on ErrorResponse catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to add to cart: ${e.message}',
            style: GoogleFonts.montserrat(color: AppColors.lightText),
          ),
          backgroundColor: AppColors.errorRed,
        ),
      );
      print('Add to Cart Error: ${e.message}');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'An unexpected error occurred: ${e.toString()}',
            style: GoogleFonts.montserrat(color: AppColors.lightText),
          ),
          backgroundColor: AppColors.errorRed,
        ),
      );
      print('Unexpected Add to Cart Error: $e');
    }
  }

  Widget _buildQuantitySelector() {
    final int maxQuantityCanAdd =
        _availableStock - _currentProductInCartQuantity;

    return Row(
      children: <Widget>[
        _buildQuantityButton(
          Icons.remove,
          onPressed:
              _selectedQuantityToAdd > 1
                  ? () {
                    setState(() {
                      _selectedQuantityToAdd--;
                    });
                  }
                  : null,
        ),
        Container(
          width: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.cardBackgroundDark,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.subtleGrey.withOpacity(0.5)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            _selectedQuantityToAdd.toString(),
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.lightText,
            ),
          ),
        ),
        _buildQuantityButton(
          Icons.add,
          onPressed:
              _selectedQuantityToAdd < maxQuantityCanAdd
                  ? () {
                    setState(() {
                      _selectedQuantityToAdd++;
                    });
                  }
                  : null,
        ),
        const SizedBox(width: 10),
        Text(
          'Available: $_availableStock',
          style: GoogleFonts.montserrat(
            fontSize: 14,
            color: AppColors.subtleText,
          ),
        ),
        if (_currentProductInCartQuantity > 0)
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Text(
              'In Cart: $_currentProductInCartQuantity',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: AppColors.subtleText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildQuantityButton(IconData icon, {VoidCallback? onPressed}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              onPressed != null ? AppColors.primaryGold : AppColors.subtleGrey,
          foregroundColor: AppColors.darkBackground,
          minimumSize: const Size(40, 40),
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Icon(icon, color: AppColors.darkBackground, size: 20),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.lightText),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.shopping_cart_outlined,
            color: AppColors.lightText,
          ),
          onPressed: () async {
            final AppUser? user = await PreferenceHandler.getUserData();

            if (user == null) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Please log in to view your cart.',
                    style: GoogleFonts.montserrat(color: AppColors.lightText),
                  ),
                  backgroundColor: AppColors.blue,
                ),
              );
              return;
            }

            if (!mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartScreen16()),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingInitialData) {
      return Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryGold),
        ),
      );
    }

    if (_initialDataErrorMessage != null) {
      return Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: AppColors.errorRed, size: 60),
                const SizedBox(height: 20),
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
                  onPressed: _fetchInitialData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGold,
                    foregroundColor: AppColors.darkBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    'Retry',
                    style: GoogleFonts.playfairDisplay(
                      color: AppColors.darkBackground,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final String category =
        widget.categoryName ??
        widget.product.category?.name ??
        _categoriesMap[widget.product.categoryId]?.name ??
        'Unknown Category';

    final bool canAddToCart =
        _selectedQuantityToAdd > 0 &&
        (_selectedQuantityToAdd + _currentProductInCartQuantity) <=
            _availableStock &&
        _availableStock > 0;

    String addToCartButtonText;
    if (_availableStock == 0) {
      addToCartButtonText = 'Out of Stock';
    } else if (_currentProductInCartQuantity >= _availableStock) {
      addToCartButtonText = 'Already Max In Cart';
    } else if (_selectedQuantityToAdd == 0 &&
        _currentProductInCartQuantity < _availableStock) {
      addToCartButtonText = 'Select Quantity';
    } else {
      addToCartButtonText = 'Add to Cart';
    }

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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Stack(
                children: [
                  SizedBox(
                    height: 300,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _imageUrls.length,
                      itemBuilder: (context, index) {
                        String currentImageUrl = _imageUrls[index];
                        return ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                          child: Image.network(
                            currentImageUrl,
                            height: 300,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => Container(
                                  height: 300,
                                  color: AppColors.cardBackgroundDark
                                      .withOpacity(0.5),
                                  child: const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      size: 50,
                                      color: AppColors.subtleGrey,
                                    ),
                                  ),
                                ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (_imageUrls.length > 1)
                    Positioned(
                      bottom: 10,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: TabPageSelector(
                          controller: _tabController,
                          selectedColor: AppColors.primaryGold,
                          color: AppColors.subtleGrey,
                        ),
                      ),
                    ),
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackgroundDark.withOpacity(0.8),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite_border,
                        color: AppColors.subtleText,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '$_productBrand · $category',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        color: AppColors.subtleText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _productName,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightText,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        if (_displayOriginalPrice.isNotEmpty &&
                            _displayOriginalPrice != _displayCurrentPrice)
                          Text(
                            _displayOriginalPrice,
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              color: AppColors.subtleText,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        SizedBox(
                          width: _displayOriginalPrice.isNotEmpty ? 10 : 0,
                        ),
                        Text(
                          _displayCurrentPrice,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGold,
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (_displayDiscount.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accentBlue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$_displayDiscount Off',
                              style: GoogleFonts.montserrat(
                                color: AppColors.lightText,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _productDescription,
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        color: AppColors.lightText,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Quantity',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightText,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildQuantitySelector(),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: canAddToCart ? _handleAddToCart : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              canAddToCart
                                  ? AppColors.primaryGold
                                  : AppColors.subtleGrey,
                          foregroundColor: AppColors.darkBackground,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 5,
                        ),
                        child: Text(
                          addToCartButtonText,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkBackground,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
