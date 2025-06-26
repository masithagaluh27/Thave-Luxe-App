import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thave_luxe_app/constant/app_color.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/admin/admi_product_screen.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/admin/view_order_screen_admin_screen.dart';

class AdminDashboardScreen16 extends StatelessWidget {
  const AdminDashboardScreen16({super.key});
  static const String id = '/adminDashboard16';

  @override
  Widget build(BuildContext context) {
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
            onPressed: () {
              // TODO: Implement actual logout functionality
              Navigator.popUntil(
                context,
                (route) => route.isFirst,
              ); // Go back to root
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Admin logged out.',
                    style: GoogleFonts.montserrat(color: AppColors.lightText),
                  ),
                  backgroundColor: AppColors.blue,
                  duration: const Duration(seconds: 2),
                ),
              );
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
            _buildAdminCard(
              context,
              icon: Icons.inventory_2_outlined,
              title: 'Manage Products',
              subtitle: 'Add, edit, or delete store products.',
              onTap: () {
                Navigator.pushNamed(context, ManageProductsScreen16.id);
              },
            ),
            const SizedBox(height: 16),
            _buildAdminCard(
              context,
              icon: Icons.shopping_cart_checkout_outlined,
              title: 'View Orders',
              subtitle: 'Track and manage customer orders.',
              onTap: () {
                Navigator.pushNamed(
                  context,
                  ViewOrdersScreen16.id,
                ); // Navigate to ViewOrdersScreen
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build consistent admin action cards
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
