import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thave_luxe_app/constant/app_color.dart';
import 'package:thave_luxe_app/helper/preference_handler.dart'; // Import PreferenceHandler for logout
import 'package:thave_luxe_app/tugas_enam_belas/api/api_provider.dart'; // Import ApiProvider for actual logout API call
import 'package:thave_luxe_app/tugas_enam_belas/screens/admin/admin_brand_screen.dart'; // Import admin_brand_screen.dart
import 'package:thave_luxe_app/tugas_enam_belas/screens/admin/admin_category.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/admin/manage_product_screen.dart'; // Using the user's provided import path for manage_product_screen.dart
import 'package:thave_luxe_app/tugas_enam_belas/screens/auth/login_screen_16.dart';

class AdminDashboardScreen16 extends StatelessWidget {
  final String? userEmail; // To receive user email for admin check

  const AdminDashboardScreen16({super.key, this.userEmail});
  static const String id = '/adminDashboard16';

  @override
  Widget build(BuildContext context) {
    final ApiProvider apiProvider = ApiProvider();

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: Text(
          'Admin Dashboard',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: AppColors.lightText,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.redAccent),
            onPressed: () async {
              try {
                // Attempt to call API logout
                final response = await apiProvider.logout();
                if (response.status == 'success') {
                  debugPrint('Logout successful via API.');
                } else {
                  debugPrint('API logout failed: ${response.message}');
                  // Still proceed with local logout even if API fails
                }
              } on Exception catch (e) {
                debugPrint('Error during API logout: $e');
                // Continue with local logout despite API error
              } finally {
                // Clear local token
                await PreferenceHandler.clearToken();
                if (context.mounted) {
                  // Navigate to login screen and remove all routes from the stack
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen16(),
                    ),
                    (route) => false,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Admin logged out.',
                        style: GoogleFonts.montserrat(
                          color: AppColors.lightText,
                        ),
                      ),
                      backgroundColor: AppColors.blue,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.darkBackground, AppColors.backgroundGradientEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card for managing Products
            _buildAdminCard(
              context,
              icon: Icons.inventory_2_outlined,
              title: 'Manage Products',
              subtitle: 'Add, edit, or delete store products.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            ManageProductsScreen16(userEmail: userEmail),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            // Card for managing Categories
            _buildAdminCard(
              context,
              icon: Icons.category_outlined,
              title: 'Manage Categories',
              subtitle: 'Organize and update product categories.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ManageCategoriesScreen16(
                          userEmail: userEmail,
                        ), // Pass userEmail
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            // Card for managing Brands
            _buildAdminCard(
              context,
              icon: Icons.branding_watermark_outlined,
              title: 'Manage Brands',
              subtitle: 'Add, edit, or delete product brands.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ManageBrandsScreen16(
                          userEmail: userEmail,
                        ), // Pass userEmail
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build consistent admin action cards with your styling
  Widget _buildAdminCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 8,
      color: AppColors.cardBackgroundLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: AppColors.primaryGold),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.playfairDisplay(
                        color: AppColors.textDark,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.montserrat(
                        color: AppColors.subtleText,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: AppColors.subtleGrey),
            ],
          ),
        ),
      ),
    );
  }
}
