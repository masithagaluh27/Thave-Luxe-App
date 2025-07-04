// lib/tugas_enam_belas/screens/product/product_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // For currency formatting
import 'package:thave_luxe_app/constant/app_color.dart';
import 'package:thave_luxe_app/helper/preference_handler.dart';
import 'package:thave_luxe_app/tugas_enam_belas/api/api_provider.dart'; // Menggunakan ApiProvider baru
import 'package:thave_luxe_app/tugas_enam_belas/models/app_models.dart'; // Menggunakan model tunggal untuk semua model
import 'package:thave_luxe_app/tugas_enam_belas/screens/cart/cart_screen.dart';

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
  final ApiProvider _apiService = ApiProvider();

  int _selectedQuantityToAdd = 1;
  int _currentProductInCartQuantity = 0;
  late int _availableStock;

  late PageController _pageController;
  int _currentPageIndex = 0;
  late TabController _tabController;

  User? _currentUser;

  bool _isLoadingInitialData = true;
  String? _initialDataErrorMessage;

  late String _productName;
  late String _productBrandDisplay;
  late String _productCategoryDisplay;
  late String _productDescription;
  late List<String> _imageUrls;

  // New variables for discount calculation and display
  late double _originalPrice;
  late double? _discountPercentage;
  late double _finalPrice;

  final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();

    _availableStock = widget.product.stock ?? 0;

    _productName = widget.product.name ?? 'Produk Tidak Dikenal';
    _productBrandDisplay =
        widget.brandName ?? widget.product.brandName ?? 'Merek Tidak Dikenal';
    _productCategoryDisplay =
        widget.categoryName ??
        widget.product.categoryName ??
        'Kategori Tidak Dikenal';

    _productDescription =
        widget.product.description ?? 'Tidak ada deskripsi tersedia.';

    _originalPrice = widget.product.price?.toDouble() ?? 0.0;
    _discountPercentage = widget.product.discount;
    _finalPrice =
        (_discountPercentage != null && _discountPercentage! > 0)
            ? _originalPrice * (1 - _discountPercentage! / 100)
            : _originalPrice;

    _imageUrls = [];
    if (widget.product.imageUrls != null &&
        widget.product.imageUrls!.isNotEmpty) {
      _imageUrls = List<String>.from(widget.product.imageUrls!);
    } else {
      _imageUrls.add('https://placehold.co/300x300?text=No+Image');
    }

    if (_imageUrls.isEmpty) {
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
      // No need to fetch categories here if they are already passed or part of the product model
      // await _fetchCategories(); // This function is empty and not needed here.

      _currentUser = await PreferenceHandler.getUserData();
      print('Pengguna Saat Ini: ${_currentUser?.email}');

      await _loadCurrentProductCartQuantity();

      if (mounted) {
        setState(() {
          _isLoadingInitialData = false;
        });
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _initialDataErrorMessage =
              'Detail Produk: Gagal memuat data awal: ${e.toString().replaceFirst('Exception: ', '')}';
          _isLoadingInitialData = false;
        });
        print('Detail Produk: Error mengambil data awal: $e');
      }
    }
  }

  // This function is empty and not used, can be removed or kept for future use.
  // For now, I'm commenting out its call in _fetchInitialData.
  // Future<void> _fetchCategories() async {
  //   try {
  //     if (mounted) {
  //       setState(() {});
  //     }
  //   } on Exception catch (e) {
  //     print('ProductDetail: Error fetching categories: ${e.toString()}');
  //     if (mounted) {
  //       setState(() {
  //         _initialDataErrorMessage =
  //             _initialDataErrorMessage != null
  //                 ? '$_initialDataErrorMessage\nCategories: ${e.toString().replaceFirst('Exception: ', '')}'
  //                 : 'Categories: ${e.toString().replaceFirst('Exception: ', '')}';
  //       });
  //     }
  //   }
  // }

  Future<void> _loadCurrentProductCartQuantity() async {
    final int? productId = widget.product.id;
    if (productId == null) {
      debugPrint('ID Produk kosong, tidak dapat memuat jumlah keranjang.');
      return;
    }

    try {
      if (_currentUser?.id != null) {
        final ApiResponse<List<CartItem>> cartResponse =
            await _apiService.getCart();
        final List<CartItem> cartItems = cartResponse.data ?? [];

        final CartItem existingCartItem = cartItems.firstWhere(
          (item) => item.productId == productId,
          orElse: () => CartItem(quantity: 0),
        );

        if (!mounted) return;
        setState(() {
          _currentProductInCartQuantity = existingCartItem.quantity ?? 0;
          _selectedQuantityToAdd =
              (_currentProductInCartQuantity >= _availableStock) ? 0 : 1;
          if (_availableStock == 0) {
            _selectedQuantityToAdd = 0;
          }
        });
        print(
          'Jumlah produk saat ini di keranjang: $_currentProductInCartQuantity',
        );
      } else {
        if (!mounted) return;
        setState(() {
          _currentProductInCartQuantity = 0;
          _selectedQuantityToAdd = _availableStock > 0 ? 1 : 0;
        });
      }
    } on Exception catch (e) {
      _showError(
        'Tidak dapat memuat status keranjang saat ini: ${e.toString().replaceFirst('Exception: ', '')}',
      );
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
      _showError('Error: ID Produk tidak valid.');
      return;
    }

    final int totalQuantityAfterAdd =
        _selectedQuantityToAdd + _currentProductInCartQuantity;

    if (_selectedQuantityToAdd == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Harap pilih jumlah untuk ditambahkan.',
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
            'Menambahkan $_selectedQuantityToAdd akan melebihi total stok. Hanya $_availableStock yang tersedia. Keranjang Anda saat ini memiliki $_currentProductInCartQuantity dari item ini.',
            style: GoogleFonts.montserrat(
              color: const Color.fromARGB(255, 185, 185, 185),
            ),
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
            'Silakan masuk untuk menambahkan item ke keranjang.',
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
          'Menambahkan ke keranjang...',
          style: GoogleFonts.montserrat(color: AppColors.lightText),
        ),
        backgroundColor: AppColors.primaryGold,
      ),
    );

    try {
      final ApiResponse<CartItem> response = await _apiService.addToCart(
        productId: productId,
        quantity: _selectedQuantityToAdd,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response.message ?? 'Produk berhasil ditambahkan ke keranjang!',
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
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menambahkan ke keranjang: ${e.toString().replaceFirst('Exception: ', '')}',
            style: GoogleFonts.montserrat(color: AppColors.lightText),
          ),
          backgroundColor: AppColors.errorRed,
        ),
      );
      print('Error Menambahkan ke Keranjang: $e');
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
              _selectedQuantityToAdd < maxQuantityCanAdd && _availableStock > 0
                  ? () {
                    setState(() {
                      _selectedQuantityToAdd++;
                    });
                  }
                  : null,
        ),
        const SizedBox(width: 10),
        Text(
          'Tersedia: $_availableStock',
          style: GoogleFonts.montserrat(
            fontSize: 14,
            color: AppColors.subtleText,
          ),
        ),
        if (_currentProductInCartQuantity > 0)
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Text(
              'Di Keranjang: $_currentProductInCartQuantity',
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
              onPressed != null
                  ? const Color(0xffCFAF6B)
                  : const Color(0xffD4AF37).withOpacity(0.5), // Disabled color
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
        icon: const Icon(
          Icons.arrow_back_ios,
          color: Color.fromARGB(255, 14, 13, 13),
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.shopping_cart_outlined,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
          onPressed: () async {
            final User? user = await PreferenceHandler.getUserData();
            if (user == null) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Silakan masuk untuk melihat keranjang Anda.',
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
                const Icon(
                  Icons.error_outline,
                  color: AppColors.errorRed,
                  size: 60,
                ),
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
                    'Coba Lagi',
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

    final String category = _productCategoryDisplay;

    bool canAddToCart = false;
    String addToCartButtonText;

    if (_availableStock == 0) {
      addToCartButtonText = 'Stok Habis';
      canAddToCart = false;
    } else if (_currentProductInCartQuantity >= _availableStock) {
      addToCartButtonText = 'Sudah Maksimal di Keranjang';
      canAddToCart = false;
    } else if (_selectedQuantityToAdd == 0) {
      addToCartButtonText = 'Pilih Kuantitas';
      canAddToCart = false;
    } else {
      addToCartButtonText = 'Tambahkan ke Keranjang';
      canAddToCart = true;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0EAD6),
      appBar: _buildAppBar(context),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFFF0EAD6)],
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
                                  color: const Color.fromARGB(
                                    255,
                                    201,
                                    196,
                                    196,
                                  ).withOpacity(0.5),
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
                        child: SizedBox(
                          height: 20,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(
                              _imageUrls.length > 3
                                  ? 3
                                  : _imageUrls.length, // Maksimal 3 titik
                              (index) => Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      _tabController.index == index
                                          ? AppColors.primaryGold
                                          : const Color.fromARGB(
                                            255,
                                            209,
                                            209,
                                            209,
                                          ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Discount Badge
                  if (_discountPercentage != null && _discountPercentage! > 0)
                    Positioned(
                      top: 60, // Adjust position as needed
                      left: 20, // Adjust position as needed
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color:
                              AppColors.green, // Use green for discount badge
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${_discountPercentage!.toInt()}% OFF',
                          style: GoogleFonts.montserrat(
                            color: AppColors.lightText,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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
                      '$_productBrandDisplay · $category',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        color: const Color(0xff2C2C2C),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _productName,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff2C2C2C),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        if (_discountPercentage != null &&
                            _discountPercentage! > 0)
                          Text(
                            _currencyFormatter.format(_originalPrice),
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: AppColors.subtleText,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        if (_discountPercentage != null &&
                            _discountPercentage! > 0)
                          const SizedBox(width: 10),
                        Text(
                          _currencyFormatter.format(_finalPrice),
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _productDescription,
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        color: const Color(0xff666666),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Kuantitas',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF3A3A3A),
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
                                  ? const Color(0xffCFAF6B)
                                  : const Color(0xffD4AF37).withOpacity(0.5),
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
