// lib/tugas_enam_belas/screens/home/home_screen_16.dart

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:thave_luxe_app/constant/app_color.dart';
import 'package:thave_luxe_app/tugas_enam_belas/api/api_provider.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/app_models.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/auth/profile_screen.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/brands/brand_screen.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/cart/cart_screen.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/category/category_screen.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/product/product_detail_screen.dart';

class HomeScreen16 extends StatefulWidget {
  const HomeScreen16({super.key});
  static const String id = '/home16';

  @override
  State<HomeScreen16> createState() => _HomeScreen16State();
}

class _HomeScreen16State extends State<HomeScreen16> {
  final ApiProvider _api = ApiProvider();

  List<Product> _allProducts = [];
  List<Brand> _allBrands = [];
  bool _loading = true;
  String? _error;

  final _searchCtrl = TextEditingController();
  final _pageCtrl = PageController(initialPage: 0);
  final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  int _currentBanner = 0;
  int _navIndex = 0;
  late Timer _shuffleTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    _shuffleTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted && _allProducts.isNotEmpty) {
        setState(() => _allProducts.shuffle());
      }
    });
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final resProd = await _api.getProducts();
      final resBrand = await _api.getBrands();
      final prods = resProd.data ?? [];
      prods.shuffle();
      setState(() {
        _allProducts = prods;
        _allBrands = resBrand.data ?? [];
        _error = null;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _pageCtrl.dispose();
    _shuffleTimer.cancel();
    super.dispose();
  }

  List<Product> get _filteredProducts {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return _allProducts;
    return _allProducts
        .where((p) => p.name?.toLowerCase().contains(q) ?? false)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: _buildAppBar(),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? _buildError()
              : _buildContent(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  AppBar _buildAppBar() => AppBar(
    title: Text(
      'Thavé Luxe Store',
      style: GoogleFonts.playfairDisplay(
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      ),
    ),
    centerTitle: true,
    elevation: 0,
    backgroundColor: AppColors.backgroundLight,
    leading: IconButton(
      icon: const Icon(
        Icons.notifications_outlined,
        color: AppColors.primaryGold,
      ),
      onPressed: () => _showSnack('Notifications soon!'),
    ),
  );

  Widget _buildError() => Center(
    child: Text(
      _error!,
      style: GoogleFonts.montserrat(color: AppColors.errorRed, fontSize: 16),
    ),
  );

  Widget _buildContent() => RefreshIndicator(
    onRefresh: _loadData,
    color: AppColors.primaryGold,
    child: SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearch(),
          _buildBrandChips(),
          const SizedBox(height: 15),
          _buildBanner(),
          const SizedBox(height: 25),
          _buildSectionHeader('You Might Like These', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AllProductsScreen(products: _allProducts),
              ),
            );
          }),
          _buildProductScroller(),
          const SizedBox(height: 30),
        ],
      ),
    ),
  );

  Widget _buildSearch() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
    child: TextField(
      controller: _searchCtrl,
      decoration: InputDecoration(
        hintText: 'Search for products...',
        prefixIcon: const Icon(Icons.search, color: AppColors.subtleText),
        filled: true,
        fillColor: AppColors.searchBarBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.searchBarBorder),
        ),
      ),
      onChanged: (_) => setState(() {}),
    ),
  );

  Widget _buildBrandChips() => SizedBox(
    height: 50,
    child:
        _allBrands.isEmpty
            ? Center(
              child: Text(
                'No brands available',
                style: GoogleFonts.montserrat(color: AppColors.subtleText),
              ),
            )
            : ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _allBrands.length,
              itemBuilder: (_, i) {
                final brand = _allBrands[i];
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(25),
                    onTap: () async {
                      await Navigator.pushNamed(
                        context,
                        BrandScreen16.id,
                        arguments: brand,
                      );
                      _loadData();
                    },
                    child: Chip(
                      label: Text(
                        brand.name ?? 'Unknown',
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
                          width: .5,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
  );

  Widget _buildBanner() {
    const banners = [
      {'title': 'Up to 50% Off!', 'subtitle': '& other Stories'},
      {'title': 'New Arrivals', 'subtitle': 'Explore the latest trends'},
      {'title': 'Limited Edition', 'subtitle': "Don't miss out!"},
    ];
    final List<Color> bannerColors = [
      AppColors.primaryGold,
      const Color(0xFF94C3FF),
      const Color(0xFFFF6E5B),
    ];

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageCtrl,
            itemCount: banners.length,
            onPageChanged: (i) => setState(() => _currentBanner = i),
            itemBuilder: (_, i) {
              final b = banners[i];
              final color = bannerColors[i % bannerColors.length];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: color,
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        b['title']!,
                        style: GoogleFonts.playfairDisplay(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        b['subtitle']!,
                        style: GoogleFonts.montserrat(color: Colors.white70),
                      ),
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
            banners.length,
            (i) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color:
                    _currentBanner == i
                        ? AppColors.primaryGold
                        : AppColors.subtleGrey,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onViewAll) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: [
        Text(
          title,
          style: GoogleFonts.playfairDisplay(
            color: AppColors.textDark,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: onViewAll,
          style: TextButton.styleFrom(foregroundColor: AppColors.primaryGold),
          child: const Text(
            'View all',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );

  Widget _buildProductScroller() {
    final prods = _filteredProducts;
    return SizedBox(
      height: 280,
      child:
          prods.isEmpty
              ? Center(
                child: Text(
                  'No products',
                  style: GoogleFonts.montserrat(color: AppColors.subtleText),
                ),
              )
              : ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: min(prods.length, 5),
                itemBuilder:
                    (_, i) => Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: _productCard(prods[i]),
                    ),
              ),
    );
  }

  Widget _productCard(Product p) {
    final double originalPrice = p.price?.toDouble() ?? 0.0;
    final double? discount = p.discount;
    final double finalPrice =
        (discount != null && discount > 0)
            ? originalPrice * (1 - discount / 100)
            : originalPrice;

    return SizedBox(
      width: 160,
      child: Card(
        color: const Color(0xffF2F2F2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailScreen(product: p),
                ),
              ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child:
                            p.imageUrls?.isNotEmpty == true
                                ? Image.network(
                                  p.imageUrls!.first,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder:
                                      (context, error, stackTrace) => Container(
                                        color: AppColors.imagePlaceholderLight,
                                        child: const Center(
                                          child: Icon(
                                            Icons.image_not_supported_outlined,
                                            size: 40,
                                            color: AppColors.subtleText,
                                          ),
                                        ),
                                      ),
                                )
                                : Container(
                                  color: AppColors.imagePlaceholderLight,
                                  child: const Center(
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      size: 40,
                                      color: AppColors.subtleText,
                                    ),
                                  ),
                                ),
                      ),
                      if (discount != null && discount > 0)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.green,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              '${discount.toInt()}% OFF',
                              style: GoogleFonts.montserrat(
                                color: AppColors.lightText,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  p.name ?? 'Unknown',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                // Changed price display to a Column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (discount != null && discount > 0)
                      Text(
                        _currencyFormatter.format(originalPrice),
                        style: GoogleFonts.montserrat(
                          color: AppColors.subtleText,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          decoration: TextDecoration.lineThrough,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    Text(
                      _currencyFormatter.format(finalPrice),
                      style: GoogleFonts.montserrat(
                        color: AppColors.primaryGold,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBar _buildBottomNav() => BottomNavigationBar(
    currentIndex: _navIndex,
    onTap: (i) {
      setState(() => _navIndex = i);
      switch (i) {
        case 1:
          Navigator.pushNamed(context, CartScreen16.id);
          break;
        case 2:
          Navigator.pushNamed(context, CategoryScreen.id);
          break;
        case 3:
          Navigator.pushNamed(context, ProfileScreen16.id);
          break;
      }
    },
    selectedItemColor: AppColors.primaryGold,
    unselectedItemColor: AppColors.accentGrey,
    backgroundColor: AppColors.backgroundLight,
    type: BottomNavigationBarType.fixed,
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
      BottomNavigationBarItem(
        icon: Icon(Icons.shopping_bag_outlined),
        label: 'Cart',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.dashboard_outlined),
        label: 'Categories',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        label: 'Profile',
      ),
    ],
  );

  void _showSnack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
  );
}

class AllProductsScreen extends StatelessWidget {
  final List<Product> products;
  const AllProductsScreen({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'All Products',
          style: GoogleFonts.playfairDisplay(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.backgroundLight,
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: AppColors.backgroundLight,
      body:
          products.isEmpty
              ? const Center(child: Text('No products'))
              : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: .62,
                ),
                itemCount: products.length,
                itemBuilder: (_, i) => _ProductGridCard(product: products[i]),
              ),
    );
  }
}

class _ProductGridCard extends StatelessWidget {
  final Product product;
  const _ProductGridCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    final double originalPrice = product.price?.toDouble() ?? 0.0;
    final double? discount = product.discount;
    final double finalPrice =
        (discount != null && discount > 0)
            ? originalPrice * (1 - discount / 100)
            : originalPrice;

    return Card(
      color: const Color(0xffF2F2F2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailScreen(product: product),
              ),
            ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child:
                          product.imageUrls?.isNotEmpty == true
                              ? Image.network(
                                product.imageUrls!.first,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder:
                                    (context, error, stackTrace) => Container(
                                      color: AppColors.imagePlaceholderLight,
                                      child: const Center(
                                        child: Icon(
                                          Icons.image_not_supported_outlined,
                                          size: 40,
                                          color: AppColors.subtleText,
                                        ),
                                      ),
                                    ),
                              )
                              : Container(
                                color: AppColors.imagePlaceholderLight,
                                child: const Center(
                                  child: Icon(
                                    Icons.image_not_supported_outlined,
                                    size: 40,
                                    color: AppColors.subtleText,
                                  ),
                                ),
                              ),
                    ),
                    if (discount != null && discount > 0)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.green,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            '${discount.toInt()}% OFF',
                            style: GoogleFonts.montserrat(
                              color: AppColors.lightText,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                product.name ?? 'Unknown',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              // Changed price display to a Column
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (discount != null && discount > 0)
                    Text(
                      currencyFormatter.format(originalPrice),
                      style: GoogleFonts.montserrat(
                        color: AppColors.subtleText,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        decoration: TextDecoration.lineThrough,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  Text(
                    currencyFormatter.format(finalPrice),
                    style: GoogleFonts.montserrat(
                      color: AppColors.primaryGold,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
