import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thave_luxe_app/constant/app_color.dart';
import 'package:thave_luxe_app/helper/preference_handler.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/app_models.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/admin/manage_product_screen.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/auth/login_screen_16.dart';

class ProfileScreen16 extends StatefulWidget {
  const ProfileScreen16({super.key});

  static const String id = '/profile16';

  @override
  State<ProfileScreen16> createState() => _ProfileScreen16State();
}

class _ProfileScreen16State extends State<ProfileScreen16> {
  late Future<User?> _userProfileFuture;

  @override
  void initState() {
    super.initState();
    _userProfileFuture = _fetchUserProfile();
  }

  Future<User?> _fetchUserProfile() async {
    try {
      final user = await PreferenceHandler.getUserData();
      return user;
    } catch (e) {
      debugPrint('Error fetching local user data: $e');
      return null;
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.montserrat(color: AppColors.lightText),
          ),
          backgroundColor: color,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(10),
        ),
      );
    }
  }

  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGold),
            ),
          ),
    );

    try {
      await PreferenceHandler.clearUserDetails(); // Clear local user data
      _showSnackBar('Logged out successfully!', AppColors.green);
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen16()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      debugPrint('Logout error (local preference clear): $e');
      _showSnackBar(
        'Logout failed: ${e.toString().replaceFirst('Exception: ', '')}',
        AppColors.redAccent,
      );
    } finally {
      if (mounted) Navigator.of(context).pop(); // Dismiss loading indicator
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: _buildAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            // Updated gradient for background
            colors: [
              AppColors.backgroundGradientStartDark,
              AppColors.darkBackground,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<User?>(
          future: _userProfileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryGold,
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading profile: ${snapshot.error}',
                  style: GoogleFonts.montserrat(color: AppColors.redAccent),
                ),
              );
            } else if (snapshot.hasData && snapshot.data != null) {
              final User user = snapshot.data!;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    _buildProfileHeader(user),
                    const SizedBox(height: 30),
                    _buildProfileOption(
                      icon: Icons.edit_outlined,
                      title: 'Edit Profile',
                      onTap: () {
                        _showSnackBar(
                          'Edit Profile functionality not yet implemented.',
                          AppColors.subtleGrey,
                        );
                      },
                    ),
                    _buildProfileOption(
                      icon: Icons.shopping_bag_outlined,
                      title: 'My Orders',
                      onTap: () {
                        Navigator.pushNamed(context, '/history16');
                      },
                    ),
                    _buildProfileOption(
                      icon: Icons.star_border,
                      title: 'Favorite Products',
                      onTap: () {
                        _showSnackBar(
                          'Favorite Products functionality not yet implemented.',
                          AppColors.subtleGrey,
                        );
                      },
                    ),
                    if (user.email == 'admin@gmail.com')
                      _buildProfileOption(
                        icon: Icons.admin_panel_settings_outlined,
                        title: 'Manage Products',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ManageProductsScreen16(
                                    userEmail: user.email,
                                  ),
                            ),
                          );
                        },
                      ),
                    _buildProfileOption(
                      icon: Icons.logout,
                      title: 'Logout',
                      onTap: _handleLogout,
                      isLogout: true,
                    ),
                    // Reduced bottom padding
                    const SizedBox(height: 10),
                    _buildAppVersion(),
                    const SizedBox(
                      height: 10,
                    ), // A little extra space at the very bottom
                  ],
                ),
              );
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_off_outlined,
                      size: 80,
                      color: AppColors.subtleGrey,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'No user logged in.\nPlease login to view your profile.',
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        color: AppColors.subtleText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen16(),
                          ),
                          (Route<dynamic> route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGold,
                        foregroundColor: AppColors.darkBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        'Login Now',
                        style: GoogleFonts.playfairDisplay(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.lightText),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Text(
        'My Profile',
        style: GoogleFonts.playfairDisplay(
          fontWeight: FontWeight.bold,
          color: AppColors.lightText,
          fontSize: 24,
        ),
      ),
      centerTitle: true,
      actions: const <Widget>[],
    );
  }

  Widget _buildProfileHeader(User user) {
    return Column(
      children: <Widget>[
        // Updated profile photo design
        Container(
          width: 120, // Increased size slightly
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryGold, // Solid gold background
            border: Border.all(
              color: AppColors.borderGold, // Richer gold border
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor.withOpacity(
                  0.5,
                ), // Stronger shadow
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.person,
              size: 80, // Larger icon
              color:
                  AppColors
                      .darkBackground, // Dark background color for the icon
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          user.name ?? 'Guest User',
          style: GoogleFonts.playfairDisplay(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.lightText,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          user.email ?? 'No Email',
          style: GoogleFonts.montserrat(
            fontSize: 16,
            color: AppColors.subtleGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Card(
      color: AppColors.cardBackgroundDark,
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        // Added a subtle border to the cards
        side: BorderSide(
          color: AppColors.borderGold.withOpacity(0.3), // Light gold border
          width: 1.0,
        ),
      ),
      elevation: 5,
      shadowColor: AppColors.shadowColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 20.0),
          child: Row(
            children: <Widget>[
              Icon(
                icon,
                color: isLogout ? AppColors.redAccent : AppColors.primaryGold,
                size: 28,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isLogout ? AppColors.redAccent : AppColors.lightText,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: isLogout ? AppColors.redAccent : AppColors.subtleGrey,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppVersion() {
    return Text(
      'App Version 1.0.0', // Replace with actual version from pubspec.yaml if desired
      style: GoogleFonts.montserrat(fontSize: 12, color: AppColors.subtleGrey),
    );
  }
}
