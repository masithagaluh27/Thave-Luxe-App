import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:thave_luxe_app/constant/app_color.dart';
import 'package:thave_luxe_app/tugas_enam_belas/api/api_provider.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/app_models.dart';

// ... (import tetap sama)

class ManageProductScreen extends StatefulWidget {
  final String? userEmail;
  const ManageProductScreen({super.key, this.userEmail});

  static const String id = '/manage_product_screen';

  @override
  State<ManageProductScreen> createState() => _ManageProductScreenState();
}

class _ManageProductScreenState extends State<ManageProductScreen> {
  final ApiProvider _api = ApiProvider();
  final _currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  List<Product> _products = [];
  List<Brand> _brands = [];
  bool _loading = true;
  String? _error;

  final _name = TextEditingController();
  final _price = TextEditingController();
  final _stock = TextEditingController();
  final _desc = TextEditingController();
  final _disc = TextEditingController();

  Brand? _pickedBrand;
  List<File> _pickedImages = [];
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initialLoad();
  }

  Future<void> _initialLoad() async {
    await Future.wait([_loadBrands(), _loadProducts()]);
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _loadProducts() async {
    try {
      final res = await _api.getProducts();
      _products = res.data ?? [];
    } catch (e) {
      _error = 'Failed to load products: $e';
    }
  }

  Future<void> _loadBrands() async {
    try {
      final res = await _api.getBrands();
      _brands = res.data ?? [];
      if (_brands.isNotEmpty) _pickedBrand ??= _brands.first;
    } catch (e) {
      _snack('Gagal memuat brand: $e', AppColors.redAccent);
    }
  }

  void _snack(String msg, Color color) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));

  Future<String?> _fileToB64(File f) async =>
      base64Encode(await f.readAsBytes());

  Future<void> _pickImages(StateSetter setSt) async {
    final imgs = await _picker.pickMultiImage();
    if (imgs.isNotEmpty)
      setSt(() => _pickedImages = imgs.map((e) => File(e.path)).toList());
  }

  Future<void> _openDialog({Product? edit}) async {
    if (_brands.isEmpty) {
      _snack('Brand belum tersedia', AppColors.subtleGrey);
      return;
    }

    final isEdit = edit != null;
    _name.text = edit?.name ?? '';
    _price.text = edit?.price?.toString() ?? '';
    _stock.text = edit?.stock?.toString() ?? '';
    _desc.text = edit?.description ?? '';
    _disc.text = edit?.discount?.toString() ?? '';
    _pickedBrand =
        _brands.firstWhereOrNull((b) => b.id == edit?.brandId) ?? _brands.first;
    _pickedImages = [];

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (ctx) => Material(
            color: Colors.transparent,
            child: StatefulBuilder(
              builder:
                  (ctx, setSt) => AlertDialog(
                    backgroundColor: AppColors.cardBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: Text(
                      isEdit ? 'Edit Product' : 'Add Product',
                      style: GoogleFonts.playfairDisplay(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _field(_name, 'Name'),
                          _field(_price, 'Price', type: TextInputType.number),
                          _field(_stock, 'Stock', type: TextInputType.number),
                          _field(_disc, 'Discount', type: TextInputType.number),
                          _field(_desc, 'Description', maxLines: 3),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<Brand>(
                            value: _pickedBrand,
                            dropdownColor: AppColors.cardBackground,
                            decoration: const InputDecoration(
                              labelText: 'Brand',
                            ),
                            style: GoogleFonts.montserrat(
                              color: AppColors.textDark,
                            ),
                            items:
                                _brands
                                    .map(
                                      (b) => DropdownMenuItem(
                                        value: b,
                                        child: Text(
                                          b.name ?? '-',
                                          style: GoogleFonts.montserrat(
                                            color: AppColors.textDark,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (b) => setSt(() => _pickedBrand = b),
                          ),
                          const SizedBox(height: 12),
                          if (_pickedImages.isNotEmpty)
                            SizedBox(
                              height: 90,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _pickedImages.length,
                                itemBuilder:
                                    (_, i) => Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Image.file(
                                              _pickedImages[i],
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Positioned(
                                            right: 0,
                                            child: GestureDetector(
                                              onTap:
                                                  () => setSt(
                                                    () => _pickedImages
                                                        .removeAt(i),
                                                  ),
                                              child: const CircleAvatar(
                                                radius: 12,
                                                backgroundColor:
                                                    AppColors.redAccent,
                                                child: Icon(
                                                  Icons.close,
                                                  size: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                              ),
                            ),
                          TextButton.icon(
                            onPressed: () => _pickImages(setSt),
                            icon: const Icon(Icons.image),
                            label: const Text('Pick Images'),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton.icon(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        label: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGold,
                          foregroundColor: AppColors.darkBackground,
                        ),
                        onPressed: () => _save(ctx, isEdit: isEdit, edit: edit),
                        child: Text(isEdit ? 'Save' : 'Add'),
                      ),
                    ],
                  ),
            ),
          ),
    );
  }

  Widget _field(
    TextEditingController c,
    String h, {
    TextInputType type = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: c,
      maxLines: maxLines,
      keyboardType: type,
      style: GoogleFonts.montserrat(color: AppColors.textDark),
      decoration: InputDecoration(
        labelText: h,
        labelStyle: GoogleFonts.montserrat(color: AppColors.subtleText),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.subtleGrey),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primaryGold, width: 2),
        ),
      ),
    );
  }

  Future<void> _save(
    BuildContext ctx, {
    required bool isEdit,
    Product? edit,
  }) async {
    if (_name.text.isEmpty || _price.text.isEmpty || _stock.text.isEmpty) {
      _snack('Name, Price, Stock wajib', AppColors.redAccent);
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final imgsB64 = <String>[];
    for (final f in _pickedImages) {
      final b64 = await _fileToB64(f);
      if (b64 != null) imgsB64.add(b64);
    }

    try {
      if (isEdit) {
        await _api.updateProduct(
          productId: edit!.id!,
          name: _name.text,
          price: int.parse(_price.text),
          stock: int.parse(_stock.text),
          brandId: _pickedBrand!.id!,
          description: _desc.text,
          discount: _disc.text.isEmpty ? null : double.parse(_disc.text),
          images: imgsB64.isEmpty ? edit.imageUrls : imgsB64,
        );
      } else {
        await _api.addProduct(
          name: _name.text,
          price: int.parse(_price.text),
          stock: int.parse(_stock.text),
          brandId: _pickedBrand!.id!,
          description: _desc.text,
          discount: _disc.text.isEmpty ? null : double.parse(_disc.text),
          images: imgsB64,
        );
      }
      if (mounted) Navigator.pop(context);
      if (mounted) Navigator.pop(ctx);
      _snack('Success', AppColors.green);
      await _loadProducts();
      setState(() {});
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _snack('Error: $e', AppColors.redAccent);
    }
  }

  Future<void> _delete(Product p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: AppColors.cardBackground,
            title: Text(
              'Hapus "${p.name}"?',
              style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
    if (ok != true) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      await _api.deleteProduct(productId: p.id!);
      _snack('Deleted', AppColors.green);
      await _loadProducts();
      setState(() {});
    } catch (e) {
      _snack('Error: $e', AppColors.redAccent);
    } finally {
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.darkBackground,
        centerTitle: true,
        title: Text(
          'Manage Products',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: AppColors.lightText,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primaryGold),
        ),
        actions: [
          IconButton(
            onPressed: () => _openDialog(),
            icon: Icon(Icons.add, color: AppColors.primaryGold),
          ),
        ],
      ),

      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              )
              : RefreshIndicator(
                onRefresh: () async => _initialLoad(),
                child:
                    _products.isEmpty
                        ? const Center(
                          child: Text(
                            'No products',
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                        : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _products.length,
                          itemBuilder: (_, i) {
                            final p = _products[i];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: AppColors.cardBackground,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ListTile(
                                leading:
                                    p.imageUrls != null &&
                                            p.imageUrls!.isNotEmpty
                                        ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.network(
                                            p.imageUrls!.first,
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                        : const Icon(
                                          Icons.image_not_supported,
                                          color: AppColors.subtleGrey,
                                        ),
                                title: Text(
                                  p.name ?? '-',
                                  style: GoogleFonts.poppins(
                                    color: AppColors.textDark,
                                    fontSize:
                                        15.5, // <-- diubah ke textDark agar selalu kontras
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                subtitle: Text(
                                  _currency.format(
                                    int.tryParse(p.price?.toString() ?? '0') ??
                                        0,
                                  ),
                                  style: GoogleFonts.montserrat(
                                    color: AppColors.primaryGold,
                                  ),
                                ),
                                trailing: Wrap(
                                  spacing: 4,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: AppColors.primaryGold,
                                      ),
                                      onPressed: () => _openDialog(edit: p),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: AppColors.redAccent,
                                      ),
                                      onPressed: () => _delete(p),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
              ),
    );
  }
}
