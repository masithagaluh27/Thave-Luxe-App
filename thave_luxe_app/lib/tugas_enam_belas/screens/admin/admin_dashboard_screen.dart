import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thave_luxe_app/constant/app_color.dart';
import 'package:thave_luxe_app/helper/preference_handler.dart';
import 'package:thave_luxe_app/tugas_enam_belas/api/api_provider.dart' as api;
import 'package:thave_luxe_app/tugas_enam_belas/screens/admin/admin_brand_screen.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/admin/admin_category.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/admin/manage_product_screen.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/auth/login_screen_16.dart';

class AdminDashboardScreen16 extends StatelessWidget {
  const AdminDashboardScreen16({super.key, this.userEmail});
  static const String id = '/adminDashboard16';

  final String? userEmail;

  @override
  Widget build(BuildContext context) {
    final apiProvider = api.ApiProvider();

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        title: Text(
          'Admin Dashboard',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: AppColors.lightText,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.redAccent),
            tooltip: 'Logout',
            onPressed: () async {
              // tampilkan loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder:
                    (_) => const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(
                          AppColors.primaryGold,
                        ),
                      ),
                    ),
              );

              try {
                final res = await apiProvider.logout();
                if (context.mounted) Navigator.pop(context); // tutup loading

                final msg = res.message ?? 'Logged out';
                final bg =
                    res.status == 'success'
                        ? AppColors.green
                        : AppColors.redAccent;

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        msg,
                        style: GoogleFonts.montserrat(
                          color: AppColors.lightText,
                        ),
                      ),
                      backgroundColor: bg,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Error during logout: ${e.toString().replaceFirst("Exception: ", "")}',
                      style: GoogleFonts.montserrat(color: AppColors.lightText),
                    ),
                    backgroundColor: AppColors.redAccent,
                  ),
                );
              } finally {
                await PreferenceHandler.clearToken();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen16()),
                    (_) => false,
                  );
                }
              }
            },
          ),
        ],
      ),
      body: _DashboardBody(userEmail: userEmail),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.userEmail});

  final String? userEmail;
  final String brand = 'brandId'; // Replace with actual brand ID if needed

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.darkBackground, AppColors.backgroundGradientLight],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _AdminCard(
            icon: Icons.inventory_2_outlined,
            title: 'Manage Products',
            subtitle: 'Add, edit, or delete store products.',
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ManageProductScreen(userEmail: userEmail),
                  ),
                ),
          ),
          const SizedBox(height: 16),
          _AdminCard(
            icon: Icons.category_outlined,
            title: 'Manage Categories',
            subtitle: 'Organize and update product categories.',
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => ManageCategoriesScreen16(userEmail: userEmail),
                  ),
                ),
          ),
          const SizedBox(height: 16),
          _AdminCard(
            icon: Icons.branding_watermark_outlined,
            title: 'Manage Brands',
            subtitle: 'Add, edit, or delete product brands.',
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ManageBrandsScreen16(userEmail: userEmail),
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  const _AdminCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
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
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: AppColors.subtleText,
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
