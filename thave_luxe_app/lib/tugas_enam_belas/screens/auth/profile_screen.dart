import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thave_luxe_app/constant/app_color.dart';
import 'package:thave_luxe_app/tugas_enam_belas/api/auth_provider.dart'; // Corrected import path

import 'package:thave_luxe_app/tugas_enam_belas/models/profile_response.dart';

import 'package:thave_luxe_app/tugas_enam_belas/screens/admin/admin_product_screen.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/auth/login_screen_16.dart'; // Ensure this model is correctly defined

class ProfileScreen16 extends StatefulWidget {
  const ProfileScreen16({super.key});

  static const String id = '/profile16';

  @override
  State<ProfileScreen16> createState() => _ProfileScreen16State();
}

class _ProfileScreen16State extends State<ProfileScreen16> {
  final AuthProvider _authProvider = AuthProvider();

  AppUser? _userProfile; // Keep using User model for structure
  bool _isLoading = true; // Set to true initially as we are fetching from API
  String? _errorMessage;

  // Check if the current user is the admin
  bool get _isAdminUser => _userProfile?.email == 'admin@gmail.com';

  @override
  void initState() {
    super.initState();
    _fetchUserProfileFromAPI(); // Fetch profile from API on init
  }

  // Fetch user profile from the API
  Future<void> _fetchUserProfileFromAPI() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final profileResponse = await _authProvider.getProfile();
      if (profileResponse.data != null) {
        setState(() {
          _userProfile = profileResponse.data;
        });
      } else {
        _errorMessage = "Failed to load profile data. Please log in again.";
        _navigateToLogin(); // Force re-login if profile data is null
      }
    } on Exception catch (e) {
      setState(() {
        _errorMessage =
            'Failed to load profile: ${e.toString().replaceFirst('Exception: ', '')}';
      });
      // If unauthorized, navigate to login
      if (e.toString().contains('Unauthorized')) {
        _navigateToLogin();
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Handle user logout
  Future<void> _logout() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGold),
          ),
        );
      },
    );

    try {
      await _authProvider.logout(); // Call the logout method from AuthProvider
      if (mounted) {
        Navigator.of(context).pop(); // Dismiss loading dialog
        _navigateToLogin(); // Navigate to login screen
        _showSnackBar('Logged out successfully!', AppColors.green);
      }
    } on Exception catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Dismiss loading dialog
        _showSnackBar(
          'Logout failed: ${e.toString().replaceFirst('Exception: ', '')}',
          AppColors.redAccent,
        );
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.montserrat(color: Colors.white),
          ),
          backgroundColor: color,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(10),
        ),
      );
    }
  }

  void _navigateToLogin() {
    // Clear routes and push to login screen
    Navigator.pushNamedAndRemoveUntil(
      context,
      LoginScreen16.id,
      (Route<dynamic> route) => false,
    );
  }

  Widget _buildSectionCard({
    required Color cardColor,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildProfileListItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryGold, size: 28),
      title: Text(
        title,
        style: GoogleFonts.montserrat(
          color: AppColors.textDark,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: AppColors.textDark,
        size: 18,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
    );
  }

  Widget _buildDivider(Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Divider(
        color: AppColors.subtleGrey.withOpacity(0.4),
        thickness: 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'My Profile',
          style: GoogleFonts.playfairDisplay(
            color: AppColors.textDark,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: const [], // Changed to const []
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(color: AppColors.backgroundLight),
        child: RefreshIndicator(
          onRefresh: _fetchUserProfileFromAPI,
          color: AppColors.primaryGold,
          child:
              _isLoading
                  ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryGold,
                      ),
                    ),
                  )
                  : _errorMessage != null
                  ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Error: $_errorMessage',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.redAccent,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed:
                                _fetchUserProfileFromAPI, // Retry loading from API
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGold,
                              foregroundColor: AppColors.darkBackground,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Retry',
                              style: GoogleFonts.playfairDisplay(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  : ListView(
                    // Changed from SingleChildScrollView
                    physics:
                        const AlwaysScrollableScrollPhysics(), // Important for RefreshIndicator
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 15.0,
                    ).copyWith(
                      top:
                          MediaQuery.of(context).padding.top +
                          kToolbarHeight +
                          15, // Adjusted padding for AppBar and status bar
                    ),
                    children: [
                      // Directly provide children to ListView
                      Container(
                        padding: const EdgeInsets.all(15.0),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackgroundLight,
                          borderRadius: BorderRadius.circular(15.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 7,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          // This inner Column is fine
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: AppColors.primaryGold,
                              child: const Icon(
                                // Added const
                                Icons.person,
                                size: 60,
                                color: AppColors.darkBackground,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              _userProfile?.name ?? 'Guest User',
                              style: GoogleFonts.playfairDisplay(
                                color: AppColors.textDark,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _userProfile?.email ?? 'N/A',
                              style: GoogleFonts.montserrat(
                                color: AppColors.subtleText,
                                fontSize: 16,
                              ),
                            ),
                            if (_userProfile?.phone != null &&
                                _userProfile!.phone!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 5.0),
                                child: Text(
                                  _userProfile!.phone!,
                                  style: GoogleFonts.montserrat(
                                    color: AppColors.subtleText,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            if (_userProfile?.address != null &&
                                _userProfile!.address!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 5.0),
                                child: Text(
                                  _userProfile!.address!,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.montserrat(
                                    color: AppColors.subtleText,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Conditional rendering for Admin Panel
                      if (_isAdminUser) ...[
                        _buildSectionCard(
                          cardColor: AppColors.cardBackgroundLight,
                          children: [
                            _buildProfileListItem(
                              icon:
                                  Icons
                                      .admin_panel_settings, // Admin-specific icon
                              title: 'Admin Panel',
                              onTap: () {
                                _showSnackBar(
                                  'Entering Admin Panel!',
                                  AppColors.primaryGold, // Use a distinct color
                                );
                                Navigator.pushNamed(
                                  context,
                                  ManageProductsScreen16.id,
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 25), // Space after admin card
                      ],

                      _buildSectionCard(
                        cardColor: AppColors.cardBackgroundLight,
                        children: [
                          _buildProfileListItem(
                            icon: Icons.shopping_bag_outlined,
                            title: 'My Orders',
                            onTap: () {
                              _showSnackBar(
                                'My Orders Tapped!',
                                AppColors.blue,
                              );
                              // TODO: Navigate to Orders Screen
                            },
                          ),
                          _buildDivider(AppColors.subtleGrey),
                          _buildProfileListItem(
                            icon: Icons.receipt_long,
                            title: 'Returns & Refunds',
                            onTap: () {
                              _showSnackBar(
                                'Returns & Refunds Tapped!',
                                AppColors.blue,
                              );
                              // TODO: Navigate to Returns & Refunds Screen
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),

                      _buildSectionCard(
                        cardColor: AppColors.cardBackgroundLight,
                        children: [
                          _buildProfileListItem(
                            icon: Icons.lock_outline,
                            title: 'Change Password',
                            onTap: () {
                              _showSnackBar(
                                'Change Password Tapped!',
                                AppColors.blue,
                              );
                              // TODO: Navigate to Change Password Screen
                            },
                          ),
                          _buildDivider(AppColors.subtleGrey),
                          _buildProfileListItem(
                            icon: Icons.payment,
                            title: 'Payment Methods',
                            onTap: () {
                              _showSnackBar(
                                'Payment Methods Tapped!',
                                AppColors.blue,
                              );
                              // TODO: Navigate to Payment Methods Screen
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),

                      // Logout Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _logout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.redAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            elevation: 5,
                          ),
                          child: Text(
                            'Logout',
                            style: GoogleFonts.playfairDisplay(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
        ),
      ),
    );
  }
}
