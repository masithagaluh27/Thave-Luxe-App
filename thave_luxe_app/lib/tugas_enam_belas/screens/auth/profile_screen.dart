import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thave_luxe_app/constant/app_color.dart';
import 'package:thave_luxe_app/helper/preference_handler.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/app_models.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/admin/admin_dashboard_screen.dart';
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
      debugPrint('PROFILE_SCREEN: Fetched user data: ${user?.toJson()}');
      return user;
    } catch (e) {
      debugPrint('PROFILE_SCREEN: Error fetching local user data: $e');
      return null;
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.montserrat(color: AppColors.textLight),
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
    // 1. Show loader dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppColors.primaryGold),
            ),
          ),
    );

    try {
      await PreferenceHandler.clearUserDetails(); // 2. Clear user data

      // 3. Close the dialog BEFORE navigation
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      // 4. Show success snackbar (optional)
      _showSnackBar('Logged out successfully!', AppColors.successGreen);

      // 5. Navigate to Login screen
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen16()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      // 6. Close loader if error happens
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      _showSnackBar(
        'Logout failed: ${e.toString().replaceFirst('Exception: ', '')}',
        AppColors.redAccent,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: _buildAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.backgroundLight,
              AppColors.backgroundGradientLight,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<User?>(
          future: _userProfileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
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
                  style: GoogleFonts.montserrat(color: AppColors.errorRed),
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
                        _showSnackBar('coming soon!!', AppColors.subtleGrey);
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
                      title: 'Wishlist Products',
                      onTap: () {
                        _showSnackBar('coming soon!!', AppColors.subtleGrey);
                      },
                    ),
                    if (user.email == 'admin@gmail.com')
                      _buildProfileOption(
                        icon: Icons.admin_panel_settings_outlined,
                        title: 'Admin Dashboard',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => AdminDashboardScreen16(
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
                    const SizedBox(height: 10),
                    _buildAppVersion(),
                    const SizedBox(height: 10),
                  ],
                ),
              );
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.person_off_outlined,
                      size: 80,
                      color: AppColors.iconDark,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'No user logged in.\nPlease login to view your profile.',
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        color: AppColors.textDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen16(),
                          ),
                          (_) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGold,
                        foregroundColor: AppColors.textLight,
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
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.iconDark),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Text(
        'My Profile',
        style: GoogleFonts.playfairDisplay(
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
          fontSize: 24,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildProfileHeader(User user) {
    return Column(
      children: <Widget>[
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryGold,
            border: Border.all(color: AppColors.borderGold, width: 3),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor.withOpacity(0.5),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.person, size: 80, color: AppColors.textLight),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          user.name ?? 'Guest User',
          style: GoogleFonts.playfairDisplay(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          user.email ?? 'No Email',
          style: GoogleFonts.montserrat(
            fontSize: 16,
            color: AppColors.subtleText,
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
      color: AppColors.cardBackground,
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color:
              AppColors.subtleBorder ?? AppColors.subtleText.withOpacity(0.3),
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
                color: isLogout ? AppColors.errorRed : AppColors.primaryGold,
                size: 28,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isLogout ? AppColors.errorRed : AppColors.textDark,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: isLogout ? AppColors.errorRed : AppColors.iconDark,
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
      'App Version 1.0.0',
      style: GoogleFonts.montserrat(fontSize: 12, color: AppColors.subtleText),
    );
  }
}
