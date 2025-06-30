import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thave_luxe_app/constant/app_color.dart';
import 'package:thave_luxe_app/tugas_enam_belas/api/api_provider.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/app_models.dart';

class ManageCategoriesScreen16 extends StatefulWidget {
  final String? userEmail;

  const ManageCategoriesScreen16({super.key, this.userEmail});
  static const String id = '/adminCategory16';

  @override
  State<ManageCategoriesScreen16> createState() =>
      _ManageCategoriesScreen16State();
}

class _ManageCategoriesScreen16State extends State<ManageCategoriesScreen16> {
  final ApiProvider _apiProvider = ApiProvider();
  List<Category> _categories = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _isAdmin = widget.userEmail == 'admin@gmail.com';
    if (_isAdmin) {
      _fetchCategories();
    } else {
      _isLoading = false;
      _errorMessage = 'Access Denied: Only admin users can manage categories.';
    }
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await _apiProvider.getCategories();
      setState(() {
        _isLoading = false;
        if (response.status == 'success') {
          _categories = response.data ?? [];
          if (_categories.isEmpty && response.message != null) {
            _errorMessage = response.message;
          } else if (_categories.isEmpty) {
            _errorMessage = 'No categories found.';
          }
        } else {
          _errorMessage =
              response.message ??
              response.error ??
              'Failed to load categories.';
          _categories = [];
        }
      });
    } on Exception catch (e) {
      setState(() {
        _errorMessage =
            'Network Error: ${e.toString().replaceFirst('Exception: ', '')}';
        _isLoading = false;
        _categories = [];
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

  Future<void> _addCategory(String name) async {
    if (!_isAdmin) {
      _showSnackBar(
        'Permission Denied: You are not authorized to add categories.',
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
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGold),
            ),
          ),
    );
    try {
      final response = await _apiProvider.addCategory(name: name);
      if (mounted) Navigator.of(context).pop();

      if (response.status == 'success') {
        await _fetchCategories();
        _showSnackBar(
          response.message ?? 'Category added successfully!',
          AppColors.green,
        );
      } else {
        _showSnackBar(
          'Failed to add category: ${response.message ?? response.error ?? 'Unknown error'}',
          AppColors.redAccent,
        );
      }
    } on Exception catch (e) {
      if (mounted) Navigator.of(context).pop();
      _showSnackBar(
        'Network Error: ${e.toString().replaceFirst('Exception: ', '')}',
        AppColors.redAccent,
      );
    }
  }

  Future<void> _updateCategory(int id, String name) async {
    if (!_isAdmin) {
      _showSnackBar(
        'Permission Denied: You are not authorized to update categories.',
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
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGold),
            ),
          ),
    );
    try {
      // FIX HERE: Use categoryId: id
      final response = await _apiProvider.updateCategory(
        categoryId: id,
        name: name,
      );
      if (mounted) Navigator.of(context).pop();

      if (response.status == 'success') {
        await _fetchCategories();
        _showSnackBar(
          response.message ?? 'Category updated successfully!',
          AppColors.green,
        );
      } else {
        _showSnackBar(
          'Failed to update category: ${response.message ?? response.error ?? 'Unknown error'}',
          AppColors.redAccent,
        );
      }
    } on Exception catch (e) {
      if (mounted) Navigator.of(context).pop();
      _showSnackBar(
        'Network Error: ${e.toString().replaceFirst('Exception: ', '')}',
        AppColors.redAccent,
      );
    }
  }

  Future<void> _deleteCategory(int id) async {
    if (!_isAdmin) {
      _showSnackBar(
        'Permission Denied: You are not authorized to delete categories.',
        AppColors.redAccent,
      );
      return;
    }

    bool? confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.darkBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Confirm Deletion',
            style: GoogleFonts.playfairDisplay(
              color: AppColors.redAccent,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this category?',
            style: GoogleFonts.montserrat(color: AppColors.lightText),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: GoogleFonts.montserrat(color: AppColors.subtleGrey),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
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
                style: GoogleFonts.montserrat(
                  color: AppColors.lightText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
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
        // FIX HERE: Use categoryId: id
        final response = await _apiProvider.deleteCategory(categoryId: id);
        if (mounted) Navigator.of(context).pop();

        if (response.status == 'success') {
          await _fetchCategories();
          _showSnackBar(
            response.message ?? 'Category deleted successfully!',
            AppColors.green,
          );
        } else {
          _showSnackBar(
            'Failed to delete category: ${response.message ?? response.error ?? 'Unknown error'}',
            AppColors.redAccent,
          );
        }
      } on Exception catch (e) {
        if (mounted) Navigator.of(context).pop();
        _showSnackBar(
          'Network Error: ${e.toString().replaceFirst('Exception: ', '')}',
          AppColors.redAccent,
        );
      }
    }
  }

  void _showAddEditDialog({Category? category}) {
    if (!_isAdmin) {
      _showSnackBar(
        'Permission Denied: You are not authorized to perform this action.',
        AppColors.redAccent,
      );
      return;
    }

    final TextEditingController nameController = TextEditingController(
      text: category?.name ?? '',
    );
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.darkBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            category == null ? 'Add Category' : 'Edit Category',
            style: GoogleFonts.playfairDisplay(
              color: AppColors.primaryGold,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          content: TextField(
            controller: nameController,
            style: GoogleFonts.montserrat(color: AppColors.lightText),
            decoration: InputDecoration(
              labelText: 'Category Name',
              labelStyle: GoogleFonts.montserrat(color: AppColors.subtleText),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primaryGold,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: AppColors.searchBarBackground.withOpacity(0.2),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14.0,
                horizontal: 10,
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.montserrat(color: AppColors.subtleGrey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  Navigator.of(dialogContext).pop();
                  if (category == null) {
                    _addCategory(name);
                  } else {
                    _updateCategory(category.id!, name);
                  }
                } else {
                  _showSnackBar(
                    'Category name cannot be empty!',
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
                category == null ? 'Add' : 'Update',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: Text(
          'Manage Categories',
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
          },
        ),
        actions: [
          if (_isAdmin)
            IconButton(
              icon: const Icon(Icons.add, color: AppColors.primaryGold),
              onPressed: () => _showAddEditDialog(),
              tooltip: 'Add New Category',
            ),
        ],
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
          onRefresh: _isAdmin ? _fetchCategories : () async {},
          color: AppColors.primaryGold,
          child:
              _isLoading
                  ? Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryGold,
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
                            style: GoogleFonts.montserrat(
                              color: AppColors.redAccent,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (_isAdmin &&
                              (_errorMessage!.contains('token is missing') ||
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
                          else if (_isAdmin &&
                              _errorMessage !=
                                  'Access Denied: Only admin users can manage categories.')
                            ElevatedButton(
                              onPressed: _fetchCategories,
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
                  : _categories.isEmpty
                  ? Center(
                    child: Text(
                      _isAdmin
                          ? 'No categories found. Add a new category!'
                          : 'No categories available.',
                      style: GoogleFonts.montserrat(
                        color: AppColors.subtleText,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      return Card(
                        elevation: 5,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        color: AppColors.cardBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(
                            category.name ?? 'No Name',
                            style: GoogleFonts.playfairDisplay(
                              color: AppColors.textDark,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            'ID: ${category.id ?? 'N/A'}',
                            style: GoogleFonts.montserrat(
                              color: AppColors.subtleText,
                              fontSize: 14,
                            ),
                          ),
                          trailing:
                              _isAdmin
                                  ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: AppColors.blue,
                                        ),
                                        onPressed:
                                            () => _showAddEditDialog(
                                              category: category,
                                            ),
                                        tooltip: 'Edit Category',
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: AppColors.redAccent,
                                        ),
                                        onPressed:
                                            () => _deleteCategory(category.id!),
                                        tooltip: 'Delete Category',
                                      ),
                                    ],
                                  )
                                  : null,
                        ),
                      );
                    },
                  ),
        ),
      ),
    );
  }
}
