import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thave_luxe_app/constant/app_color.dart';
import 'package:thave_luxe_app/helper/preference_handler.dart';
import 'package:thave_luxe_app/tugas_enam_belas/api/auth_provider.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/profile_response.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/profile/login_screen_16.dart'; // Ensure this is imported

class ProfileScreen16 extends StatefulWidget {
  const ProfileScreen16({super.key});

  static const String id = '/profile16';

  @override
  State<ProfileScreen16> createState() => _ProfileScreen16State();
}

class _ProfileScreen16State extends State<ProfileScreen16> {
  final AuthProvider _authProvider = AuthProvider();

  User? _userProfile; // Keep using User model for structure
  bool _isLoading = false; // Changed to false initially as we load from prefs
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserProfileFromPrefs(); // Load from preferences first
  }

  // Load user profile from SharedPreferences
  Future<void> _loadUserProfileFromPrefs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final name = await PreferenceHandler.getUserName();
      final email = await PreferenceHandler.getUserEmail();

      final token = await PreferenceHandler.getToken();

      if (token == null) {
        // If essential data is missing, redirect to login
        _errorMessage =
            "Session expired or user data incomplete. Please log in again.";
        _navigateToLogin();
        return; // Exit early
      }

      setState(() {
        _userProfile = User(
          id: 0, // ID is not stored in prefs, use a placeholder or remove if not strictly needed for display
          name: name,
          email: email,
          // Removed emailVerifiedAt, createdAt, updatedAt as they are not needed for local User reconstruction
          // and might not be defined in the User model's constructor.
        );
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load local profile: ${e.toString()}';
      });
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
        _showSnackBar('Logged out successfully!', Colors.green);
      }
    } on Exception catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Dismiss loading dialog
        _showSnackBar(
          'Logout failed: ${e.toString().replaceFirst('Exception: ', '')}',
          Colors.red,
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
    Navigator.pushNamedAndRemoveUntil(
      context,
      LoginScreen16.id,
      (Route<dynamic> route) => false,
    );
  }

  void _showEditProfileDialog() {
    final TextEditingController nameController = TextEditingController(
      text: _userProfile?.name ?? '',
    );
    final TextEditingController phoneController = TextEditingController(
      text: _userProfile?.phone ?? '',
    );
    final TextEditingController addressController = TextEditingController(
      text: _userProfile?.address ?? '',
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          title: Text(
            'Edit Profile',
            style: GoogleFonts.playfairDisplay(color: AppColors.lightText),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(
                  controller: nameController,
                  labelText: 'Name',
                  icon: Icons.person,
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  controller: phoneController,
                  labelText: 'Phone',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  controller: addressController,
                  labelText: 'Address',
                  icon: Icons.location_on,
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.montserrat(color: AppColors.subtleGrey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Pop the edit dialog

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryGold,
                        ),
                      ),
                    );
                  },
                );

                try {
                  final ProfileResponse updatedResponse = await _authProvider
                      .updateProfile(
                        name: nameController.text,
                        phone:
                            phoneController.text.isNotEmpty
                                ? phoneController.text
                                : null,
                        address:
                            addressController.text.isNotEmpty
                                ? addressController.text
                                : null,
                      );

                  if (mounted) {
                    Navigator.of(context).pop(); // Dismiss loading dialog
                    if (updatedResponse.user != null) {
                      setState(() {
                        _userProfile =
                            updatedResponse
                                .user; // Update local state with the returned user
                      });
                      _showSnackBar(
                        updatedResponse.message ??
                            'Profile updated successfully!',
                        Colors.green,
                      );
                    } else {
                      _showSnackBar(
                        updatedResponse.message ??
                            'Failed to update profile: No user data in response.',
                        Colors.redAccent,
                      );
                    }
                  }
                } on Exception catch (e) {
                  if (mounted) {
                    Navigator.of(context).pop(); // Dismiss loading dialog
                    _showSnackBar(
                      'Update failed: ${e.toString().replaceFirst('Exception: ', '')}',
                      Colors.redAccent,
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Save',
                style: GoogleFonts.montserrat(color: AppColors.darkBackground),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: GoogleFonts.montserrat(color: AppColors.lightText),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: GoogleFonts.montserrat(color: AppColors.subtleGrey),
        prefixIcon: Icon(icon, color: AppColors.primaryGold),
        filled: true,
        fillColor: AppColors.darkBackground,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.primaryGold.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primaryGold, width: 2),
        ),
      ),
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
    required Color textColor,
    required Color iconColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor, size: 28),
      title: Text(
        title,
        style: GoogleFonts.montserrat(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: textColor.withOpacity(0.7),
        size: 18,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
    );
  }

  Widget _buildDivider(Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Divider(color: color.withOpacity(0.3), thickness: 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        title: Text(
          'My Profile',
          style: GoogleFonts.playfairDisplay(
            color: AppColors.lightText,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.lightText),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.lightText),
            onPressed: () {
              _showSnackBar('Settings Tapped!', Colors.blue);
            },
          ),
        ],
      ),
      body:
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
                            _loadUserProfileFromPrefs, // Retry loading from prefs
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
              : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 15.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15.0),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
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
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppColors.primaryGold,
                            child: Icon(
                              Icons.person,
                              size: 60,
                              color: AppColors.darkBackground,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            _userProfile?.name ?? 'Guest User',
                            style: GoogleFonts.playfairDisplay(
                              color: AppColors.lightText,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _userProfile?.email ?? 'N/A',
                            style: GoogleFonts.montserrat(
                              color: AppColors.subtleGrey,
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
                                  color: AppColors.subtleGrey,
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
                                  color: AppColors.subtleGrey,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: _showEditProfileDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGold,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 25,
                                vertical: 10,
                              ),
                            ),
                            child: Text(
                              'Edit Profile',
                              style: GoogleFonts.montserrat(
                                color: AppColors.darkBackground,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),

                    _buildSectionCard(
                      cardColor: AppColors.cardBackground,
                      children: [
                        _buildProfileListItem(
                          icon: Icons.shopping_bag_outlined,
                          title: 'My Orders',
                          onTap: () {
                            _showSnackBar('My Orders Tapped!', Colors.blue);
                          },
                          textColor: AppColors.lightText,
                          iconColor: AppColors.primaryGold,
                        ),
                        _buildDivider(AppColors.primaryGold),
                        _buildProfileListItem(
                          icon: Icons.favorite_border,
                          title: 'Wishlist',
                          onTap: () {
                            _showSnackBar('Wishlist Tapped!', Colors.blue);
                          },
                          textColor: AppColors.lightText,
                          iconColor: AppColors.primaryGold,
                        ),
                        _buildDivider(AppColors.primaryGold),
                        _buildProfileListItem(
                          icon: Icons.receipt_long,
                          title: 'Returns & Refunds',
                          onTap: () {
                            _showSnackBar(
                              'Returns & Refunds Tapped!',
                              Colors.blue,
                            );
                          },
                          textColor: AppColors.lightText,
                          iconColor: AppColors.primaryGold,
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),

                    _buildSectionCard(
                      cardColor: AppColors.cardBackground,
                      children: [
                        _buildProfileListItem(
                          icon: Icons.lock_outline,
                          title: 'Change Password',
                          onTap: () {
                            _showSnackBar(
                              'Change Password Tapped!',
                              Colors.blue,
                            );
                          },
                          textColor: AppColors.lightText,
                          iconColor: AppColors.primaryGold,
                        ),
                        _buildDivider(AppColors.primaryGold),
                        _buildProfileListItem(
                          icon: Icons.location_on_outlined,
                          title: 'Addresses',
                          onTap: () {
                            _showSnackBar('Addresses Tapped!', Colors.blue);
                          },
                          textColor: AppColors.lightText,
                          iconColor: AppColors.primaryGold,
                        ),
                        _buildDivider(AppColors.primaryGold),
                        _buildProfileListItem(
                          icon: Icons.payment,
                          title: 'Payment Methods',
                          onTap: () {
                            _showSnackBar(
                              'Payment Methods Tapped!',
                              Colors.blue,
                            );
                          },
                          textColor: AppColors.lightText,
                          iconColor: AppColors.primaryGold,
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),

                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _logout, // Calls the new _logout method
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
    );
  }
}
