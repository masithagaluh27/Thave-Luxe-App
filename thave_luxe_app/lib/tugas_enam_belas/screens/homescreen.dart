import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  // state
  List<Product> _allProducts = [];
  List<Product> _products = [];
  List<Brand> _allBrands = [];
  bool _loading = true;
  String? _error;

  final _searchCtrl = TextEditingController();
  final _pageCtrl = PageController(initialPage: 0);
  int _currentBanner = 0, _navIndex = 0;

  // --------------------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final resProd = await _api.getProducts();
      final resBrand = await _api.getBrands();
      setState(() {
        _allProducts = resProd.data ?? [];
        _products = _allProducts;
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
    super.dispose();
  }

  // --------------------------------------------------------------------------
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

  // ======================  WIDGETS  =========================================

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
          _buildBrandChips(), //  <-- Chip brand
          const SizedBox(height: 15),
          _buildBanner(), // This will be modified
          const SizedBox(height: 25),
          _buildSectionTitle('You Might Like These'),
          _buildProductScroller(),
          const SizedBox(height: 30),
        ],
      ),
    ),
  );

  // --------------------------------------------------------------------------
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
      onChanged:
          (q) => setState(
            () =>
                _products =
                    q.isEmpty
                        ? _allProducts
                        : _allProducts
                            .where(
                              (p) =>
                                  p.name?.toLowerCase().contains(
                                    q.toLowerCase(),
                                  ) ??
                                  false,
                            )
                            .toList(),
          ),
    ),
  );

  // --------------------------------------------------------------------------
  /// *** BRAND CHIPS *** – tap chip → push BrandScreen16 dengan **nama** brand
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
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        BrandScreen16.id,
                        arguments: brand.name, // ← hanya kirim nama
                      );
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
                          width: 0.5,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
  );

  // --------------------------------------------------------------------------
  Widget _buildBanner() {
    const banners = [
      {
        'title': 'Up to 50% Off!',
        'subtitle': '& other Stories',
        'image': 'assets/images/banner1.jpg',
      },
      {
        'title': 'New Arrivals',
        'subtitle': 'Explore the latest trends',
        'image': 'assets/images/banner2.jpg',
      },
      {
        'title': 'Limited Edition',
        'subtitle': "Don't miss out!",
        'image': 'assets/images/banner3.jpg',
      },
    ];

    // Define a list of colors for your banners
    final List<Color> bannerColors = [
      AppColors.primaryGold, // Color for the first banner
      const Color.fromARGB(
        255,
        148,
        195,
        255,
      ), // Color for the second banner (example)
      const Color.fromARGB(
        255,
        255,
        110,
        91,
      ), // Color for the third banner (example)
      // Add more colors if you have more banners
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
              // Safely get the color, default to a fallback if index is out of bounds
              final Color currentColor =
                  bannerColors.length > i
                      ? bannerColors[i]
                      : AppColors.primaryGold;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    // Removed image property to use color for background
                    color: currentColor, // Use the dynamically selected color
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

  // --------------------------------------------------------------------------
  Widget _buildSectionTitle(String t) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Text(
      t,
      style: GoogleFonts.playfairDisplay(
        color: AppColors.textDark,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  Widget _buildProductScroller() => SizedBox(
    height: 280,
    child:
        _products.isEmpty
            ? Center(
              child: Text(
                'No products',
                style: GoogleFonts.montserrat(color: AppColors.subtleText),
              ),
            )
            : ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _products.length,
              itemBuilder:
                  (_, i) => Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: _productCard(_products[i]),
                  ),
            ),
  );

  Widget _productCard(Product p) => SizedBox(
    width: 160,
    child: Card(
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
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child:
                      p.imageUrls?.isNotEmpty == true
                          ? Image.network(
                            p.imageUrls!.first,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          )
                          : const Icon(
                            Icons.image_not_supported_outlined,
                            size: 40,
                            color: AppColors.subtleText,
                          ),
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
              const SizedBox(height: 4),
              Text(
                'Rp ${p.price?.toStringAsFixed(0) ?? '-'}',
                style: GoogleFonts.montserrat(
                  color: AppColors.primaryGold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  // --------------------------------------------------------------------------
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

  // --------------------------------------------------------------------------
  void _showSnack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
  );
}
