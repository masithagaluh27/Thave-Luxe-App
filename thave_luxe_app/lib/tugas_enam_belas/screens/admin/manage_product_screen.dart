// Assuming these are in app_models.dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:thave_luxe_app/constant/app_color.dart';

class Product {
  final int? id;
  final String? name;
  final int? price;
  final String? description;
  final int? stock;
  final double? discount;
  final List<String>? imageUrls;
  final int? brandId; // New field for brand relationship
  final String? brandName; // New field for brand name display
  final int? categoryId; // Assuming product has a category
  final String? categoryName; // Assuming product has a category name

  Product({
    this.id,
    this.name,
    this.price,
    this.description,
    this.stock,
    this.discount,
    this.imageUrls,
    this.brandId,
    this.brandName,
    this.categoryId,
    this.categoryName,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int?,
      name: json['name'] as String?,
      price: json['price'] as int?,
      description: json['description'] as String?,
      stock: json['stock'] as int?,
      discount: (json['discount'] as num?)?.toDouble(),
      imageUrls:
          (json['image_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      brandId: json['brand_id'] as int?,
      brandName: json['brand_name'] as String?,
      categoryId: json['category_id'] as int?,
      categoryName: json['category_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'stock': stock,
      'discount': discount,
      'image_urls': imageUrls,
      'brand_id': brandId,
      'category_id': categoryId,
    };
  }
}

// Ensure your Brand model is correctly defined and matches what your API returns
class Brand {
  final int id;
  final String name;

  Brand({required this.id, required this.name});

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['id'] as int,
      name: json['name'] as String, // Ensure this is String, not String?
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

// Placeholder for your ApiProvider (replace with your actual api/api_provider.dart)
class ApiResponse<T> {
  final T? data;
  final String? message;
  final bool isSuccess;

  ApiResponse({this.data, this.message, this.isSuccess = true});

  factory ApiResponse.success(T data) {
    return ApiResponse(data: data, isSuccess: true);
  }

  factory ApiResponse.error(String message) {
    return ApiResponse(message: message, isSuccess: false);
  }
}

class ApiProvider {
  final String _baseUrl =
      'https://api.example.com'; // Replace with your actual base URL

  // Simulate authentication headers
  Future<Map<String, String>> _getHeaders() async {
    // In a real app, you'd fetch a token from shared preferences or a secure storage
    // For this example, we'll just return a dummy header
    return {
      'Content-Type': 'application/json',
      'Authorization':
          'Bearer YOUR_AUTH_TOKEN_HERE', // Replace with a real token
    };
  }

  // Generic response handler
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic json) parser,
  ) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final dynamic jsonResponse = json.decode(response.body);
        if (jsonResponse['data'] != null) {
          return ApiResponse.success(parser(jsonResponse['data']));
        } else {
          return ApiResponse.error(
            jsonResponse['message'] ?? 'No data received',
          );
        }
      } catch (e) {
        debugPrint('JSON parsing error: $e');
        return ApiResponse.error('Failed to parse response: $e');
      }
    } else {
      String errorMessage =
          'Request failed with status: ${response.statusCode}';
      try {
        final dynamic errorJson = json.decode(response.body);
        errorMessage = errorJson['message'] ?? errorMessage;
      } catch (e) {
        // Fallback if error body isn't JSON
      }
      return ApiResponse.error(errorMessage);
    }
  }

  Future<ApiResponse<List<Product>>> getProducts() async {
    final url = Uri.parse('$_baseUrl/products');
    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);
      return _handleResponse<List<Product>>(
        response,
        (json) =>
            (json as List)
                .map((i) => Product.fromJson(i as Map<String, dynamic>))
                .toList(),
      );
    } catch (e) {
      debugPrint('Error in getProducts: $e');
      return ApiResponse.error('Failed to fetch products: ${e.toString()}');
    }
  }

  Future<ApiResponse<Product>> addProduct({
    required String name,
    required int price,
    required int stock,
    required int brandId,
    String? description,
    List<String>? images, // Base64 encoded images
    double? discount,
  }) async {
    final url = Uri.parse('$_baseUrl/products');
    try {
      final headers = await _getHeaders();
      final body = json.encode({
        'name': name,
        'price': price,
        'stock': stock,
        'brand_id': brandId, // Ensure this matches your API expected field
        'description': description,
        'images': images, // Send as list of base64 strings
        'discount': discount,
      });
      final response = await http.post(url, headers: headers, body: body);
      return _handleResponse<Product>(
        response,
        (json) => Product.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      debugPrint('Error in addProduct: $e');
      return ApiResponse.error('Failed to add product: ${e.toString()}');
    }
  }

  Future<ApiResponse<Product>> updateProduct({
    required int productId,
    required String name,
    required int price,
    required int stock,
    required int brandId,
    String? description,
    List<String>? images, // Base64 encoded images or existing URLs
    double? discount,
  }) async {
    final url = Uri.parse('$_baseUrl/products/$productId');
    try {
      final headers = await _getHeaders();
      final body = json.encode({
        'name': name,
        'price': price,
        'stock': stock,
        'brand_id': brandId,
        'description': description,
        'images': images,
        'discount': discount,
      });
      final response = await http.put(url, headers: headers, body: body);
      return _handleResponse<Product>(
        response,
        (json) => Product.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      debugPrint('Error in updateProduct: $e');
      return ApiResponse.error('Failed to update product: ${e.toString()}');
    }
  }

  Future<ApiResponse<void>> deleteProduct({required int productId}) async {
    final url = Uri.parse('$_baseUrl/products/$productId');
    try {
      final headers = await _getHeaders();
      final response = await http.delete(url, headers: headers);
      // For delete, usually no data is returned, just success status
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.success(null);
      } else {
        String errorMessage =
            'Deletion failed with status: ${response.statusCode}';
        try {
          final dynamic errorJson = json.decode(response.body);
          errorMessage = errorJson['message'] ?? errorMessage;
        } catch (e) {
          // Fallback if error body isn't JSON
        }
        return ApiResponse.error(errorMessage);
      }
    } catch (e) {
      debugPrint('Error in deleteProduct: $e');
      return ApiResponse.error('Failed to delete product: ${e.toString()}');
    }
  }

  Future<ApiResponse<List<Brand>>> getBrands() async {
    final url = Uri.parse('$_baseUrl/brands'); // Correct URL
    try {
      final headers = await _getHeaders(); // Get headers for authentication
      final response = await http.get(url, headers: headers); // Use http.get
      return _handleResponse<List<Brand>>(
        response,
        (json) =>
            (json as List)
                .map((i) => Brand.fromJson(i as Map<String, dynamic>))
                .toList(),
      );
    } catch (e) {
      // Catch and rethrow, or wrap in ApiResponse.error
      // Based on your existing _handleResponse, throwing an Exception is consistent
      debugPrint('Error in getBrands: $e');
      // Changed to return ApiResponse.error to be consistent with other methods
      return ApiResponse.error('Failed to fetch brands: ${e.toString()}');
    }
  }
}

void debugPrint(String s) {}

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

  List<Brand> _brands = [];
  Brand? _selectedBrand; // Moved here to be accessible by StatefulBuilder

  final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  List<File> _selectedFiles = [];

  @override
  void initState() {
    super.initState();
    _isAdmin = widget.userEmail == 'admin@gmail.com';
    if (_isAdmin) {
      _fetchProducts();
      _fetchBrands();
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
      if (response.isSuccess && response.data != null) {
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

  Future<void> _fetchBrands() async {
    try {
      final response = await _apiProvider.getBrands();
      if (response.isSuccess && response.data != null) {
        setState(() {
          _brands = response.data!;
        });
      } else {
        _showSnackBar(
          'Failed to load brands: ${response.message}',
          AppColors.redAccent,
        );
      }
    } on Exception catch (e) {
      _showSnackBar(
        'Error fetching brands: ${e.toString().replaceFirst('Exception: ', '')}',
        AppColors.redAccent,
      );
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
  } //comment

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? pickedFiles = await picker.pickMultiImage();

    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        _selectedFiles = pickedFiles.map((xfile) => File(xfile.path)).toList();
      });
    }
  }

  Future<String?> _fileToBase64(File file) async {
    try {
      Uint8List imageBytes = await file.readAsBytes();
      String? mimeType = lookupMimeType(file.path);
      String prefix = '';

      if (mimeType != null) {
        prefix = 'data:$mimeType;base64,';
      } else {
        if (file.path.endsWith('.png')) {
          prefix = 'data:image/png;base64,';
        } else if (file.path.endsWith('.jpg') || file.path.endsWith('.jpeg')) {
          prefix = 'data:image/jpeg;base64,';
        } else if (file.path.endsWith('.webp')) {
          prefix = 'data:image/webp;base64,';
        } else {
          prefix = 'data:application/octet-stream;base64,';
        }
      }
      return prefix + base64Encode(imageBytes);
    } catch (e) {
      debugPrint('Error converting file to base64: $e');
      return null;
    }
  }

  Future<void> _showProductFormDialog({Product? productToEdit}) async {
    if (!_isAdmin) {
      _showSnackBar(
        'Permission Denied: You are not authorized to perform this action.',
        AppColors.redAccent,
      );
      return;
    }

    final TextEditingController nameController = TextEditingController(
      text: productToEdit?.name ?? '',
    );
    final TextEditingController priceController = TextEditingController(
      text: productToEdit?.price?.toString() ?? '',
    );
    final TextEditingController descriptionController = TextEditingController(
      text: productToEdit?.description ?? '',
    );
    final TextEditingController stockController = TextEditingController(
      text: productToEdit?.stock?.toString() ?? '',
    );
    final TextEditingController discountController = TextEditingController(
      text: productToEdit?.discount?.toString() ?? '',
    );

    final bool isEditing = productToEdit != null;

    setState(() {
      _selectedFiles = []; // Reset selected files for the dialog
      if (isEditing && productToEdit!.brandId != null) {
        _selectedBrand = _brands.firstWhere(
          (brand) => brand.id == productToEdit.brandId,
          orElse: () => _brands.first,
        );
      } else {
        _selectedBrand = null;
      }
    });

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
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
                    _brands.isEmpty
                        ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            'Loading brands...',
                            style: GoogleFonts.montserrat(
                              color: AppColors.subtleGrey,
                            ),
                          ),
                        )
                        : DropdownButtonFormField<Brand>(
                          value: _selectedBrand,
                          decoration: InputDecoration(
                            hintText: 'Select Brand',
                            hintStyle: GoogleFonts.montserrat(
                              color: AppColors.subtleGrey,
                            ),
                            prefixIcon: Icon(
                              Icons.branding_watermark,
                              color: AppColors.subtleGrey,
                            ),
                            filled: true,
                            fillColor: AppColors.searchBarBackground
                                .withOpacity(0.2),
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
                              borderSide: const BorderSide(
                                color: AppColors.primaryGold,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14.0,
                              horizontal: 10,
                            ),
                          ),
                          dropdownColor: AppColors.darkBackground,
                          style: GoogleFonts.montserrat(
                            color: AppColors.lightText,
                          ),
                          items:
                              _brands.map((Brand brand) {
                                return DropdownMenuItem<Brand>(
                                  value: brand,
                                  child: Text(
                                    brand.name ??
                                        '', // Fixed: Handle potential null name
                                    style: GoogleFonts.montserrat(
                                      color: AppColors.lightText,
                                    ),
                                  ),
                                );
                              }).toList(),
                          onChanged: (Brand? newValue) {
                            setDialogState(() {
                              _selectedBrand = newValue;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a brand.';
                            }
                            return null;
                          },
                        ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      descriptionController,
                      'Description',
                      Icons.description,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await _pickImages();
                        setDialogState(() {});
                      },
                      icon: const Icon(
                        Icons.add_photo_alternate,
                        color: AppColors.darkBackground,
                      ),
                      label: Text(
                        _selectedFiles.isEmpty
                            ? (isEditing ? 'Change Images' : 'Select Images')
                            : '${_selectedFiles.length} Image(s) Selected',
                        style: GoogleFonts.montserrat(
                          color: AppColors.darkBackground,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGold,
                        foregroundColor: AppColors.darkBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_selectedFiles.isNotEmpty) ...[
                      Container(
                        height: 100,
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedFiles.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      _selectedFiles[index],
                                      width: 90,
                                      height: 90,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: -5,
                                    right: -5,
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.cancel,
                                        color: AppColors.redAccent,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        setDialogState(() {
                                          _selectedFiles.removeAt(index);
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ] else if (isEditing &&
                        productToEdit!.imageUrls != null &&
                        productToEdit.imageUrls!.isNotEmpty) ...[
                      Container(
                        height: 100,
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: productToEdit.imageUrls!.length,
                          itemBuilder: (context, index) {
                            String imageUrl = productToEdit.imageUrls![index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  imageUrl,
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) => Container(
                                        width: 90,
                                        height: 90,
                                        color: AppColors.imagePlaceholderLight,
                                        child: const Center(
                                          child: Icon(
                                            Icons.broken_image,
                                            color: AppColors.subtleGrey,
                                            size: 30,
                                          ),
                                        ),
                                      ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
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
                    setDialogState(() {
                      _selectedFiles = [];
                    });
                    Navigator.of(dialogContext).pop();
                  },
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty ||
                        priceController.text.isEmpty ||
                        stockController.text.isEmpty ||
                        _selectedBrand == null) {
                      _showSnackBar(
                        'Name, Price, Stock, and Brand cannot be empty.',
                        AppColors.redAccent,
                      );
                      return;
                    }
                    if (int.tryParse(priceController.text) == null ||
                        int.tryParse(stockController.text) == null) {
                      _showSnackBar(
                        'Price and Stock must be valid numbers.',
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
                          (context) => const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primaryGold,
                              ),
                            ),
                          ),
                    );

                    List<String>? imagesToSend;
                    if (_selectedFiles.isNotEmpty) {
                      List<Future<String?>> base64Futures =
                          _selectedFiles
                              .map((file) => _fileToBase64(file))
                              .toList();
                      List<String?> convertedImages = await Future.wait(
                        base64Futures,
                      );
                      imagesToSend =
                          convertedImages.whereType<String>().toList();

                      if (imagesToSend.length != _selectedFiles.length) {
                        if (mounted) Navigator.of(context).pop();
                        _showSnackBar(
                          'Failed to convert one or more images to Base64. Please try again.',
                          AppColors.redAccent,
                        );
                        return;
                      }
                    } else if (isEditing &&
                        productToEdit!.imageUrls != null &&
                        productToEdit.imageUrls!.isNotEmpty) {
                      imagesToSend = productToEdit.imageUrls;
                    }

                    try {
                      if (isEditing) {
                        await _apiProvider.updateProduct(
                          productId: productToEdit!.id!,
                          name: nameController.text,
                          price: int.parse(priceController.text),
                          stock: int.parse(stockController.text),
                          brandId: _selectedBrand!.id,
                          description: descriptionController.text,
                          images: imagesToSend,
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
                          brandId: _selectedBrand!.id,
                          description: descriptionController.text,
                          images: imagesToSend,
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
                    } finally {
                      setDialogState(() {
                        _selectedFiles = [];
                      });
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
      },
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hintText,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
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

  Future<void> _confirmDelete(Product product) async {
    if (!_isAdmin) {
      _showSnackBar(
        'Permission Denied: You are not authorized to delete products.',
        AppColors.redAccent,
      );
      return;
    }

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
                    final response = await _apiProvider.deleteProduct(
                      productId: product.id!,
                    );
                    if (response.isSuccess) {
                      _showSnackBar(
                        'Product deleted successfully!',
                        AppColors.green,
                      );
                      _fetchProducts();
                    } else {
                      _showSnackBar(
                        'Deletion failed: ${response.message}',
                        AppColors.redAccent,
                      );
                    }
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

  Widget _buildProductCard(Product product) {
    final String imageUrlToDisplay =
        product.imageUrls != null && product.imageUrls!.isNotEmpty
            ? product.imageUrls!.first
            : '';

    return Card(
      elevation: 4,
      color: AppColors.cardBackground,
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
                  if (product.brandName != null &&
                      product.brandName!.isNotEmpty)
                    Text(
                      'Brand: ${product.brandName}',
                      style: GoogleFonts.montserrat(
                        color: AppColors.subtleText,
                        fontSize: 12,
                      ),
                    ),
                  if (product.categoryName != null &&
                      product.categoryName!.isNotEmpty)
                    Text(
                      'Category: ${product.categoryName}',
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
                  if (product.discount != null && product.discount! > 0)
                    Text(
                      'Discount: ${product.discount!.toInt()}%',
                      style: GoogleFonts.montserrat(
                        color: AppColors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
            if (_isAdmin)
              IconButton(
                icon: Icon(Icons.edit, color: AppColors.blue),
                onPressed: () => _showProductFormDialog(productToEdit: product),
                tooltip: 'Edit Product',
              ),
            if (_isAdmin)
              IconButton(
                icon: Icon(Icons.delete, color: AppColors.redAccent),
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
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color.fromARGB(255, 255, 246, 246),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          if (_isAdmin)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: FloatingActionButton(
                onPressed: () => _showProductFormDialog(),
                backgroundColor: AppColors.primaryGold,
                tooltip: 'Add New Product',
                mini: true,
                child: Icon(Icons.add, color: AppColors.darkBackground),
              ),
            ),
        ],
      ),
      body:
          _isAdmin
              ? (_isLoading
                  ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryGold,
                      ),
                    ),
                  )
                  : _errorMessage != null
                  ? Center(
                    child: Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        color: AppColors.redAccent,
                        fontSize: 16,
                      ),
                    ),
                  )
                  : _products.isEmpty
                  ? Center(
                    child: Text(
                      'No products found. Add a new one!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        color: AppColors.subtleGrey,
                        fontSize: 16,
                      ),
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      return _buildProductCard(product);
                    },
                  ))
              : Center(
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    color: AppColors.redAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
    );
  }
}
