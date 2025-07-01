import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thave_luxe_app/constant/app_color.dart';
import 'package:thave_luxe_app/tugas_enam_belas/api/api_provider.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/app_models.dart';

class ManageBrandsScreen16 extends StatefulWidget {
  final String? userEmail; // To receive user email for admin check

  const ManageBrandsScreen16({super.key, this.userEmail});
  static const String id = '/manageBrands16';

  @override
  State<ManageBrandsScreen16> createState() => _ManageBrandsScreen16State();
}

class _ManageBrandsScreen16State extends State<ManageBrandsScreen16> {
  final ApiProvider _apiProvider = ApiProvider();
  List<Brand> _brands = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _isAdmin = widget.userEmail == 'admin@gmail.com';
    if (_isAdmin) {
      _fetchBrands();
    } else {
      _isLoading = false;
      _errorMessage = 'Access Denied: Only admin users can manage brands.';
    }
  }

  Future<void> _fetchBrands() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await _apiProvider.getBrands();
      if (response.data != null) {
        _brands = response.data!;
      } else {
        _errorMessage = response.message ?? "No brand data received from API.";
        _brands = [];
      }
    } on Exception catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
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

  Future<void> _showBrandFormDialog({Brand? brandToEdit}) async {
    final TextEditingController nameController = TextEditingController(
      text: brandToEdit?.name ?? '',
    );
    final bool isEditing = brandToEdit != null;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.darkBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            isEditing ? 'Edit Brand' : 'Add New Brand',
            style: GoogleFonts.playfairDisplay(
              color: AppColors.primaryGold,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                _buildTextField(
                  nameController,
                  'Brand Name',
                  Icons.branding_watermark,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: GoogleFonts.montserrat(color: AppColors.subtleGrey),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty) {
                  _showSnackBar(
                    'Brand Name cannot be empty.',
                    AppColors.redAccent,
                  );
                  return;
                }

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder:
                      (context) => Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryGold,
                          ),
                        ),
                      ),
                );

                try {
                  if (isEditing) {
                    await _apiProvider.updateBrand(
                      brandId: brandToEdit.id!,
                      name: nameController.text,
                    );
                    _showSnackBar(
                      'Brand updated successfully!',
                      AppColors.green,
                    );
                  } else {
                    await _apiProvider.addBrand(name: nameController.text);
                    _showSnackBar('Brand added successfully!', AppColors.green);
                  }
                  if (mounted)
                    Navigator.of(context).pop(); // Dismiss loading indicator
                  if (mounted)
                    Navigator.of(dialogContext).pop(); // Close dialog
                  _fetchBrands(); // Refresh brand list
                } on Exception catch (e) {
                  if (mounted)
                    Navigator.of(context).pop(); // Dismiss loading indicator
                  _showSnackBar(
                    'Operation failed: ${e.toString().replaceFirst('Exception: ', '')}',
                    AppColors.redAccent,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                foregroundColor: AppColors.darkBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: Text(
                isEditing ? 'Save Changes' : 'Add Brand',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hintText,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.montserrat(color: AppColors.lightText),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.montserrat(color: AppColors.subtleGrey),
        prefixIcon: Icon(icon, color: AppColors.subtleGrey),
        filled: true,
        fillColor: AppColors.searchBarBackground.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryGold, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14.0,
          horizontal: 10,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(Brand brand) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.darkBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Delete Brand',
            style: GoogleFonts.playfairDisplay(
              color: AppColors.redAccent,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${brand.name}"?',
            style: GoogleFonts.montserrat(color: AppColors.lightText),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: GoogleFonts.montserrat(color: AppColors.subtleGrey),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder:
                      (context) => Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryGold,
                          ),
                        ),
                      ),
                );

                try {
                  if (brand.id != null) {
                    await _apiProvider.deleteBrand(brandId: brand.id!);
                    _showSnackBar(
                      'Brand deleted successfully!',
                      AppColors.green,
                    );
                    _fetchBrands();
                  } else {
                    _showSnackBar(
                      'Cannot delete: Brand ID is null.',
                      AppColors.redAccent,
                    );
                  }
                } on Exception catch (e) {
                  _showSnackBar(
                    'Deletion failed: ${e.toString().replaceFirst('Exception: ', '')}',
                    AppColors.redAccent,
                  );
                } finally {
                  if (mounted) Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.redAccent,
                foregroundColor: AppColors.lightText,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: Text(
                'Delete',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBrandCard(Brand brand) {
    return Card(
      elevation: 4,
      color: AppColors.cardBackground,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            const Icon(
              Icons.branding_watermark,
              size: 40,
              color: AppColors.primaryGold,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    brand.name ?? 'Unknown Brand',
                    style: GoogleFonts.montserrat(
                      color: AppColors.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (brand.id != null)
                    Text(
                      'ID: ${brand.id}',
                      style: GoogleFonts.montserrat(
                        color: AppColors.subtleText,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.blue),
              onPressed: () => _showBrandFormDialog(brandToEdit: brand),
              tooltip: 'Edit Brand',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.redAccent),
              onPressed: () => _confirmDelete(brand),
              tooltip: 'Delete Brand',
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: Text(
          'Manage Brands',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: AppColors.lightText,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.lightText),
          onPressed: () {
            Navigator.pop(context);
            //inicomment
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.darkBackground,
              AppColors.backgroundGradientLight,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _isAdmin ? _fetchBrands : () async {},
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
                      padding: const EdgeInsets.all(24.0),
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
                          if (_isAdmin &&
                              (_errorMessage!.contains(
                                    'Authentication token is missing',
                                  ) ||
                                  _errorMessage!.contains('Unauthorized')))
                            ElevatedButton(
                              onPressed: () {
                                _showSnackBar(
                                  'Please re-login as admin.',
                                  AppColors.orange,
                                );
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/login16',
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGold,
                                foregroundColor: AppColors.darkBackground,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Login as Admin',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 16,
                                ),
                              ),
                            )
                          else if (_isAdmin)
                            ElevatedButton(
                              onPressed: _fetchBrands,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGold,
                                foregroundColor: AppColors.darkBackground,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Retry',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  )
                  : _brands.isEmpty
                  ? Center(
                    child: Text(
                      'No brands found. Add a new one!',
                      style: GoogleFonts.playfairDisplay(
                        color: AppColors.subtleGrey,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _brands.length,
                    itemBuilder: (context, index) {
                      final brand = _brands[index];
                      return _buildBrandCard(brand);
                    },
                  ),
        ),
      ),
      floatingActionButton:
          _isAdmin
              ? FloatingActionButton(
                onPressed: () => _showBrandFormDialog(),
                backgroundColor: AppColors.primaryGold,
                child: const Icon(Icons.add, color: AppColors.darkBackground),
                tooltip: 'Add New Brand',
              )
              : null,
    );
  }
}
