import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thave_luxe_app/constant/app_color.dart';
import 'package:thave_luxe_app/tugas_enam_belas/api/api_provider.dart'; // Changed from product_provider.dart
import 'package:thave_luxe_app/tugas_enam_belas/models/produk_response.dart'; // Ensure Product model is accessible

class ManageProductsScreen16 extends StatefulWidget {
  const ManageProductsScreen16({super.key});
  static const String id = '/manageProducts16';

  @override
  State<ManageProductsScreen16> createState() => _ManageProductsScreen16State();
}

class _ManageProductsScreen16State extends State<ManageProductsScreen16> {
  final ApiProvider _apiProvider =
      ApiProvider(); // Changed from ProductProvider
  List<Product> _products = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response =
          await _apiProvider.getProducts(); // Call from ApiProvider
      setState(() {
        _products = response.data ?? [];
      });
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

  // Function to show Add/Edit Product dialog
  Future<void> _showProductFormDialog({Product? productToEdit}) async {
    final TextEditingController nameController = TextEditingController(
      text: productToEdit?.name,
    );
    final TextEditingController priceController = TextEditingController(
      text: productToEdit?.price?.toString(),
    );
    final TextEditingController descriptionController = TextEditingController(
      text: productToEdit?.description,
    );
    final TextEditingController imageUrlController = TextEditingController(
      text: productToEdit?.imageUrl,
    );

    final bool isEditing = productToEdit != null;

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to close
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.darkBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            isEditing ? 'Edit Product' : 'Add New Product',
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
                  'Product Name',
                  Icons.drive_file_rename_outline,
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  priceController,
                  'Price',
                  Icons.attach_money,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  descriptionController,
                  'Description',
                  Icons.description,
                ),
                const SizedBox(height: 15),
                _buildTextField(imageUrlController, 'Image URL', Icons.image),
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
                // Basic validation
                if (nameController.text.isEmpty ||
                    priceController.text.isEmpty) {
                  _showSnackBar(
                    'Name and Price cannot be empty.',
                    AppColors.redAccent,
                  );
                  return;
                }
                if (int.tryParse(priceController.text) == null) {
                  _showSnackBar(
                    'Price must be a valid number.',
                    AppColors.redAccent,
                  );
                  return;
                }

                // Show loading indicator
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
                    await _apiProvider.updateProduct(
                      // Call from ApiProvider
                      id: productToEdit.id!,
                      name: nameController.text,
                      price: int.parse(priceController.text),
                      description:
                          descriptionController.text.isEmpty
                              ? null
                              : descriptionController.text,
                      imageUrl:
                          imageUrlController.text.isEmpty
                              ? null
                              : imageUrlController.text,
                    );
                    _showSnackBar(
                      'Product updated successfully!',
                      AppColors.green,
                    );
                  } else {
                    await _apiProvider.addProduct(
                      // Call from ApiProvider
                      name: nameController.text,
                      price: int.parse(priceController.text),
                      description:
                          descriptionController.text.isEmpty
                              ? null
                              : descriptionController.text,
                      imageUrl:
                          imageUrlController.text.isEmpty
                              ? null
                              : imageUrlController.text,
                    );
                    _showSnackBar(
                      'Product added successfully!',
                      AppColors.green,
                    );
                  }
                  if (mounted) Navigator.of(context).pop(); // Dismiss loading
                  if (mounted)
                    Navigator.of(dialogContext).pop(); // Dismiss form dialog
                  _fetchProducts(); // Refresh the list
                } on Exception catch (e) {
                  if (mounted) Navigator.of(context).pop(); // Dismiss loading
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
                isEditing ? 'Save Changes' : 'Add Product',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  // Helper to build consistent text fields
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
        fillColor: AppColors.searchBarBackground.withOpacity(
          0.2,
        ), // Darker input field background
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none, // No border for cleaner look
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

  // Function to confirm product deletion
  Future<void> _confirmDelete(Product product) async {
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
            'Delete Product',
            style: GoogleFonts.playfairDisplay(
              color: AppColors.redAccent,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${product.name}"?',
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
                Navigator.of(
                  dialogContext,
                ).pop(); // Dismiss confirmation dialog
                // Show loading indicator
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
                  if (product.id != null) {
                    await _apiProvider.deleteProduct(
                      id: product.id!,
                    ); // Call from ApiProvider
                    _showSnackBar(
                      'Product deleted successfully!',
                      AppColors.green,
                    );
                    _fetchProducts(); // Refresh the list
                  } else {
                    _showSnackBar(
                      'Cannot delete: Product ID is null.',
                      AppColors.redAccent,
                    );
                  }
                } on Exception catch (e) {
                  _showSnackBar(
                    'Deletion failed: ${e.toString().replaceFirst('Exception: ', '')}',
                    AppColors.redAccent,
                  );
                } finally {
                  if (mounted) Navigator.of(context).pop(); // Dismiss loading
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: Text(
          'Manage Products',
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
          onRefresh: _fetchProducts,
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
                          ElevatedButton(
                            onPressed: _fetchProducts,
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
                  : _products.isEmpty
                  ? Center(
                    child: Text(
                      'No products found. Add a new one!',
                      style: GoogleFonts.playfairDisplay(
                        color: AppColors.subtleGrey,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      return Card(
                        elevation: 4,
                        color: AppColors.cardBackgroundLight,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              // Product Image/Placeholder
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: AppColors.imagePlaceholderLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child:
                                    (product.imageUrl != null &&
                                            product.imageUrl!.isNotEmpty)
                                        ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.network(
                                            product.imageUrl!,
                                            fit: BoxFit.cover,
                                            width: 70,
                                            height: 70,
                                            errorBuilder:
                                                (
                                                  context,
                                                  error,
                                                  stackTrace,
                                                ) => const Icon(
                                                  Icons
                                                      .image_not_supported_outlined,
                                                  color: AppColors.subtleGrey,
                                                  size: 30,
                                                ),
                                          ),
                                        )
                                        : const Icon(
                                          Icons.shopping_bag_outlined,
                                          color: AppColors.subtleGrey,
                                          size: 30,
                                        ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name ?? 'Unknown Product',
                                      style: GoogleFonts.montserrat(
                                        color: AppColors.textDark,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Rp ${product.price?.toStringAsFixed(0) ?? 'N/A'}',
                                      style: GoogleFonts.montserrat(
                                        color: AppColors.primaryGold,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (product.description != null &&
                                        product.description!.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 4.0,
                                        ),
                                        child: Text(
                                          product.description!,
                                          style: GoogleFonts.montserrat(
                                            color: AppColors.subtleText,
                                            fontSize: 12,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: AppColors.blue,
                                ),
                                onPressed:
                                    () => _showProductFormDialog(
                                      productToEdit: product,
                                    ),
                                tooltip: 'Edit Product',
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: AppColors.redAccent,
                                ),
                                onPressed: () => _confirmDelete(product),
                                tooltip: 'Delete Product',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductFormDialog(),
        backgroundColor: AppColors.primaryGold,
        tooltip: 'Add New Product',
        child: const Icon(Icons.add, color: AppColors.darkBackground),
      ),
    );
  }
}
