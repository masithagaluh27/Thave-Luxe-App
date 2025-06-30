import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thave_luxe_app/constant/app_color.dart'; // Import your AppColors
import 'package:thave_luxe_app/tugas_enam_belas/api/api_provider.dart'; // Make sure this is your main ApiProvider
import 'package:thave_luxe_app/tugas_enam_belas/models/app_models.dart'; // Assuming Category model is here

class ManageCategoriesScreen16 extends StatefulWidget {
  final String? userEmail; // NEW: Added userEmail to constructor for admin check

  const ManageCategoriesScreen16({super.key, this.userEmail}); // NEW: Constructor updated
  static const String id = '/adminCategory16'; // Unique ID for routing

  @override
  State<ManageCategoriesScreen16> createState() =>
      _ManageCategoriesScreen16State();
}

class _ManageCategoriesScreen16State extends State<ManageCategoriesScreen16> {
  final ApiProvider _apiProvider = ApiProvider();
  List<Category> _categories = [];
  bool _isLoading = true;
  String? _errorMessage; // Changed _error to _errorMessage for consistency
  bool _isAdmin = false; // NEW: Added isAdmin flag

  @override
  void initState() {
    super.initState();
    // NEW: Initialize _isAdmin based on passed userEmail
    _isAdmin = widget.userEmail == 'admin@gmail.com';
    if (_isAdmin) {
      _fetchCategories(); // Fetch categories only if admin
    } else {
      _isLoading = false; // Set loading to false as no fetch will occur
      _errorMessage = 'Access Denied: Only admin users can manage categories.'; // Set access denied message
    }
  }

  // Fetches the list of categories from the API
  Future<void> _fetchCategories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await _apiProvider.getCategories();
      setState(() {
        _categories = response.data ?? []; // Update the list of categories
        _isLoading = false;
        if (response.data == null) { // If no data but no exception, show message
          _errorMessage = response.message ?? "No category data received from API.";
        }
      });
    } on Exception catch (e) { // Catch specific Exception
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', ''); // Set error message
        _isLoading = false;
      });
    }
  }

  // Helper for showing snackbar messages
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

  // Adds a new category via API
  Future<void> _addCategory(String name) async {
    // Only allow if admin
    if (!_isAdmin) {
      _showSnackBar('Permission Denied: You are not authorized to add categories.', AppColors.redAccent);
      return;
    }
    showDialog( // Show loading indicator
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGold),
        ),
      ),
    );
    try {
      await _apiProvider.addCategory(name: name);
      if (mounted) Navigator.of(context).pop(); // Dismiss loading
      await _fetchCategories(); // Refresh list after successful addition
      _showSnackBar(
        'Category added successfully!',
        AppColors.green, // Changed to green for success
      );
    } on Exception catch (e) {
      if (mounted) Navigator.of(context).pop(); // Dismiss loading
      _showSnackBar(
        'Failed to add category: ${e.toString().replaceFirst('Exception: ', '')}',
        AppColors.redAccent,
      );
    }
  }

  // Updates an existing category via API
  Future<void> _updateCategory(int id, String name) async {
    // Only allow if admin
    if (!_isAdmin) {
      _showSnackBar('Permission Denied: You are not authorized to update categories.', AppColors.redAccent);
      return;
    }
    showDialog( // Show loading indicator
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGold),
        ),
      ),
    );
    try {
      await _apiProvider.updateCategory(id: id, name: name);
      if (mounted) Navigator.of(context).pop(); // Dismiss loading
      await _fetchCategories(); // Refresh list after successful update
      _showSnackBar(
        'Category updated successfully!',
        AppColors.green, // Changed to green for success
      );
    } on Exception catch (e) {
      if (mounted) Navigator.of(context).pop(); // Dismiss loading
      _showSnackBar(
        'Failed to update category: ${e.toString().replaceFirst('Exception: ', '')}',
        AppColors.redAccent,
      );
    }
  }

  // Deletes a category after user confirmation
  Future<void> _deleteCategory(int id) async {
    // Only allow if admin
    if (!_isAdmin) {
      _showSnackBar('Permission Denied: You are not authorized to delete categories.', AppColors.redAccent);
      return;
    }

    bool? confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // User must tap button to dismiss
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.darkBackground, // Dialog background color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Confirm Deletion',
            style: GoogleFonts.playfairDisplay(
              color: AppColors.redAccent, // Title color for deletion
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this category?',
            style: GoogleFonts.montserrat(color: AppColors.lightText), // Content text color
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: GoogleFonts.montserrat(color: AppColors.subtleGrey),
              ),
            ),
            ElevatedButton( // Changed to ElevatedButton for delete for better styling
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.redAccent, // Red for delete button
                foregroundColor: AppColors.lightText,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
      showDialog( // Show loading indicator after confirmation
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGold),
          ),
        ),
      );
      try {
        await _apiProvider.deleteCategory(id: id);
        if (mounted) Navigator.of(context).pop(); // Dismiss loading
        await _fetchCategories(); // Refresh list after successful deletion
        _showSnackBar(
          'Category deleted successfully!',
          AppColors.green, // Changed to green for success
        );
      } on Exception catch (e) {
        if (mounted) Navigator.of(context).pop(); // Dismiss loading
        _showSnackBar(
          'Failed to delete category: ${e.toString().replaceFirst('Exception: ', '')}',
          AppColors.redAccent,
        );
      }
    }
  }

  // Shows a dialog for adding a new category or editing an existing one
  void _showAddEditDialog({Category? category}) {
    // Only allow dialog if admin
    if (!_isAdmin) {
      _showSnackBar('Permission Denied: You are not authorized to perform this action.', AppColors.redAccent);
      return;
    }

    final TextEditingController nameController = TextEditingController(
      text: category?.name ?? '',
    );
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext dialogContext) { // Use dialogContext for Navigator.pop within dialog
        return AlertDialog(
          backgroundColor: AppColors.darkBackground, // Dialog background color
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
                borderSide: const BorderSide(color: AppColors.primaryGold, width: 2),
              ),
              filled: true,
              fillColor: AppColors.searchBarBackground.withOpacity(0.2),
              contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 10),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(), // Use dialogContext
              child: Text(
                'Cancel',
                style: GoogleFonts.montserrat(color: AppColors.subtleGrey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  Navigator.of(dialogContext).pop(); // Close the dialog immediately
                  if (category == null) {
                    _addCategory(name); // Add new category
                  } else {
                    _updateCategory(
                      category.id!,
                      name,
                    ); // Update existing category
                  }
                } else {
                  _showSnackBar(
                    'Category name cannot be empty!',
                    AppColors.redAccent,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold, // Button background
                foregroundColor: AppColors.darkBackground, // Button text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
          // Only show add button if admin
          if (_isAdmin)
            IconButton(
              icon: const Icon(
                Icons.add,
                color: AppColors.primaryGold,
              ),
              onPressed: () => _showAddEditDialog(), // Open dialog to add new category
              tooltip: 'Add New Category',
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
        child: RefreshIndicator(
          onRefresh: _isAdmin ? _fetchCategories : () async {}, // Only refresh if admin
          color: AppColors.primaryGold,
          child: _isLoading
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
                            // Only show retry/login if admin and relevant error
                            if (_isAdmin && (_errorMessage!.contains('Authentication token is missing') || _errorMessage!.contains('Unauthorized')))
                              ElevatedButton(
                                onPressed: () {
                                  _showSnackBar('Please re-login as admin.', AppColors.orange);
                                  Navigator.pushReplacementNamed(context, '/login16');
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
                                  style: GoogleFonts.playfairDisplay(fontSize: 16),
                                ),
                              )
                            else if (_isAdmin) // General retry for admins
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
                                  style: GoogleFonts.playfairDisplay(fontSize: 16),
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
                                : 'No categories available.', // Different message for non-admin
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
                              color: AppColors.cardBackgroundLight, // Consistent with other screens
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                title: Text(
                                  category.name ?? 'No Name',
                                  style: GoogleFonts.playfairDisplay(
                                    color: AppColors.textDark, // Consistent with other screens
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
                                trailing: _isAdmin
                                    ? Row( // Only show action buttons if admin
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              color: AppColors.blue,
                                            ),
                                            onPressed: () => _showAddEditDialog(
                                              category: category,
                                            ),
                                            tooltip: 'Edit Category',
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: AppColors.redAccent,
                                            ),
                                            onPressed: () => _deleteCategory(
                                              category.id!,
                                            ),
                                            tooltip: 'Delete Category',
                                          ),
                                        ],
                                      )
                                    : null, // No actions if not admin
                              ),
                            );
                          },
                        ),
        ),
      ),
    );
  }
}
