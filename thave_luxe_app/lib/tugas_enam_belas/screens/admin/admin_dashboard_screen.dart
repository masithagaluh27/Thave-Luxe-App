import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thave_luxe_app/constant/app_color.dart';
import 'package:thave_luxe_app/helper/preference_handler.dart';
import 'package:thave_luxe_app/tugas_enam_belas/api/api_provider.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/admin/admin_brand_screen.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/admin/admin_category.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/admin/manage_product_screen.dart';
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
              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible:
                    false, // User must wait for logout to complete
                builder:
                    (context) => const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryGold,
                        ),
                      ),
                    ),
              );

              try {
                final response = await apiProvider.logout();

                // Ensure context is still mounted before interacting with Navigator or ScaffoldMessenger
                if (context.mounted) {
                  // Pop the loading indicator after the API call (success or fail)
                  Navigator.of(context).pop();
                }

                if (response.status == 'success') {
                  debugPrint('Logout successful via API.');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          response.message ?? 'Logged out successfully.',
                          style: GoogleFonts.montserrat(
                            color: AppColors.lightText,
                          ),
                        ),
                        backgroundColor:
                            AppColors.green, // Use green for success
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                } else {
                  debugPrint(
                    'API logout failed: ${response.message ?? response.error}',
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          response.message ??
                              response.error ??
                              'API logout failed with unknown error.',
                          style: GoogleFonts.montserrat(
                            color: AppColors.lightText,
                          ),
                        ),
                        backgroundColor: AppColors.redAccent,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                }
              } on Exception catch (e) {
                debugPrint('Error during API logout: $e');
                if (context.mounted) {
                  Navigator.of(
                    context,
                  ).pop(); // Pop loading indicator on general error
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Error during logout: ${e.toString().replaceFirst('Exception: ', '')}.',
                        style: GoogleFonts.montserrat(
                          color: AppColors.lightText,
                        ),
                      ),
                      backgroundColor: AppColors.redAccent,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              } finally {
                // Clear local token regardless of API success/failure or exceptions
                await PreferenceHandler.clearToken();
                if (context.mounted) {
                  // Navigate to login screen and remove all routes from the stack
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen16(),
                    ),
                    (route) =>
                        false, // This ensures all previous routes are removed
                  );
                  // The snackbar below might not be visible if the route change is very fast.
                  // The one above (inside if/else) is generally preferred for immediate feedback.
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
            colors: [
              AppColors.darkBackground,
              AppColors
                  .backgroundGradientLight, // Ensure this color is defined in AppColors
            ],
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
              title: 'Manage Products', // Removed trailing space here
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
      color: AppColors.cardBackground,
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
              const Icon(
                Icons.arrow_forward_ios,
                color: Color.fromARGB(
                  255,
                  255,
                  255,
                  255,
                ), // Explicit white color
              ),
            ],
          ),
        ),
      ),
    );
  }
}
