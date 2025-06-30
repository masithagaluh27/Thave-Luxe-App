import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:thave_luxe_app/constant/app_color.dart';
import 'package:thave_luxe_app/tugas_enam_belas/api/api_provider.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/app_models.dart';

class ManageProductsScreen16 extends StatefulWidget {
  final String? userEmail;

  const ManageProductsScreen16({super.key, this.userEmail});
  static const String id = '/manageProducts16';

  @override
  State<ManageProductsScreen16> createState() => _ManageProductsScreen16State();
}

class _ManageProductsScreen16State extends State<ManageProductsScreen16> {
  final ApiProvider _apiProvider = ApiProvider();
  List<Product> _products = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isAdmin = false;

  final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _isAdmin = widget.userEmail == 'admin@gmail.com';
    if (_isAdmin) {
      _fetchProducts();
    } else {
      _isLoading = false;
      _errorMessage = 'Access Denied: Only admin users can manage products.';
    }
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await _apiProvider.getProducts();
      if (response.data != null) {
        _products = response.data!;
      } else {
        _errorMessage =
            response.message ?? "No product data received from API.";
        _products = [];
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

  // Function to show Add/Edit Product dialog
  Future<void> _showProductFormDialog({Product? productToEdit}) async {
    final TextEditingController nameController = TextEditingController(
      text: productToEdit?.name ?? '',
    );
    final TextEditingController priceController = TextEditingController(
      text: productToEdit?.price?.toString() ?? '',
    );
    final TextEditingController descriptionController = TextEditingController(
      text: productToEdit?.description ?? '',
    );
    final TextEditingController imageUrlController = TextEditingController(
      text:
          productToEdit?.imageUrls != null &&
                  productToEdit!.imageUrls!.isNotEmpty
              ? productToEdit.imageUrls!.first
              : '',
    );
    final TextEditingController stockController = TextEditingController(
      text: productToEdit?.stock?.toString() ?? '',
    );
    final TextEditingController brandIdController = TextEditingController(
      text: productToEdit?.brandId?.toString() ?? '',
    );
    final TextEditingController discountController = TextEditingController(
      text: productToEdit?.discount?.toString() ?? '',
    );

    final bool isEditing = productToEdit != null;

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
                  stockController,
                  'Stock Quantity',
                  Icons.inventory,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  brandIdController,
                  'Brand ID',
                  Icons.branding_watermark,
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
                const SizedBox(height: 15),
                _buildTextField(
                  discountController,
                  'Discount (optional)',
                  Icons.discount,
                  keyboardType: TextInputType.number,
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
                if (nameController.text.isEmpty ||
                    priceController.text.isEmpty ||
                    stockController.text.isEmpty ||
                    brandIdController.text.isEmpty) {
                  _showSnackBar(
                    'Name, Price, Stock, and Brand ID cannot be empty.',
                    AppColors.redAccent,
                  );
                  return;
                }
                if (int.tryParse(priceController.text) == null ||
                    int.tryParse(stockController.text) == null ||
                    int.tryParse(brandIdController.text) == null) {
                  _showSnackBar(
                    'Price, Stock, and Brand ID must be valid numbers.',
                    AppColors.redAccent,
                  );
                  return;
                }

                double? discountValue;
                if (discountController.text.isNotEmpty) {
                  discountValue = double.tryParse(discountController.text);
                  if (discountValue == null) {
                    _showSnackBar(
                      'Discount must be a valid number.',
                      AppColors.redAccent,
                    );
                    return;
                  }
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
                  List<String>? imageUrlsToSend;
                  if (imageUrlController.text.isNotEmpty) {
                    imageUrlsToSend = [imageUrlController.text];
                  }

                  if (isEditing) {
                    await _apiProvider.updateProduct(
                      productId: productToEdit.id!,
                      name: nameController.text,
                      price: int.parse(priceController.text),
                      stock: int.parse(stockController.text),
                      brandId: int.parse(brandIdController.text),
                      // Fixed: Always send a non-nullable string for description
                      // If your API's update endpoint truly accepts 'null' for
                      // description, you'll need to change the APIProvider's
                      // updateProduct signature for 'description' to 'String?'
                      // If it expects String, sending empty string is the safe fallback.
                      description: descriptionController.text,
                      images: imageUrlsToSend,
                      discount: discountValue,
                    );
                    _showSnackBar(
                      'Product updated successfully!',
                      AppColors.green,
                    );
                  } else {
                    await _apiProvider.addProduct(
                      name: nameController.text,
                      price: int.parse(priceController.text),
                      stock: int.parse(stockController.text),
                      brandId: int.parse(brandIdController.text),
                      description: descriptionController.text,
                      images: imageUrlsToSend,
                      discount: discountValue,
                    );
                    _showSnackBar(
                      'Product added successfully!',
                      AppColors.green,
                    );
                  }
                  if (mounted) Navigator.of(context).pop();
                  if (mounted) Navigator.of(dialogContext).pop();
                  _fetchProducts();
                } on Exception catch (e) {
                  if (mounted) Navigator.of(context).pop();
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
                  if (product.id != null) {
                    await _apiProvider.deleteProduct(productId: product.id!);
                    _showSnackBar(
                      'Product deleted successfully!',
                      AppColors.green,
                    );
                    _fetchProducts();
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

  // Widget to build individual product cards
  Widget _buildProductCard(Product product) {
    final String imageUrlToDisplay =
        product.imageUrls != null && product.imageUrls!.isNotEmpty
            ? product.imageUrls!.first
            : '';

    return Card(
      elevation: 4,
      color: AppColors.cardBackgroundLight,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.imagePlaceholderLight,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child:
                  imageUrlToDisplay.isNotEmpty
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrlToDisplay,
                          fit: BoxFit.cover,
                          width: 70,
                          height: 70,
                          errorBuilder: (context, error, stackTrace) {
                            debugPrint(
                              'Image loading error for URL: $imageUrlToDisplay',
                            );
                            debugPrint('Error: $error');
                            debugPrint('Stack Trace: $stackTrace');
                            return const Icon(
                              Icons.image_not_supported_outlined,
                              color: AppColors.subtleGrey,
                              size: 30,
                            );
                          },
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
                    _currencyFormatter.format(product.price ?? 0),
                    style: GoogleFonts.montserrat(
                      color: AppColors.primaryGold,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (product.stock != null)
                    Text(
                      'Stock: ${product.stock}',
                      style: GoogleFonts.montserrat(
                        color: AppColors.subtleText,
                        fontSize: 12,
                      ),
                    ),
                  if (product.brandId != null)
                    Text(
                      'Brand ID: ${product.brandId}',
                      style: GoogleFonts.montserrat(
                        color: AppColors.subtleText,
                        fontSize: 12,
                      ),
                    ),
                  if (product.description != null &&
                      product.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
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
                  if (product.discount != null)
                    Text(
                      'Discount: ${product.discount}%',
                      style: GoogleFonts.montserrat(
                        color: AppColors.redAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.blue),
              onPressed: () => _showProductFormDialog(productToEdit: product),
              tooltip: 'Edit Product',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.redAccent),
              onPressed: () => _confirmDelete(product),
              tooltip: 'Delete Product',
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
          onRefresh: _isAdmin ? _fetchProducts : () async {},
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
                              _errorMessage!.contains('Unauthorized'))
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
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 16,
                                ),
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
                      return _buildProductCard(product);
                    },
                  ),
        ),
      ),
      floatingActionButton:
          _isAdmin
              ? FloatingActionButton(
                onPressed: () => _showProductFormDialog(),
                backgroundColor: AppColors.primaryGold,
                tooltip: 'Add New Product',
                child: const Icon(Icons.add, color: AppColors.darkBackground),
              )
              : null,
    );
  }
}
