import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
// Adjust these paths to your actual project structure
import 'package:thave_luxe_app/constant/app_color.dart'; // Your AppColors
import 'package:thave_luxe_app/tugas_enam_belas/models/app_models.dart'; // Import model tunggal app_models.dart
import 'package:thave_luxe_app/tugas_enam_belas/screens/homescreen.dart';

class HistoryDetailScreen extends StatelessWidget {
  // Mengubah tipe historyItem dari HistoryItem menjadi History
  final History historyItem; // The specific history item to display

  const HistoryDetailScreen({super.key, required this.historyItem});

  static const String id = '/detailhistory';

  // Base URL for images (this should point to your public asset directory)
  // Keep this consistent with where your images are actually served from.
  static const String _publicBaseUrl =
      'https://apptoko.mobileprojp.com/public/';

  @override
  Widget build(BuildContext context) {
    // Format date if available
    final String formattedDate =
        historyItem.createdAt != null
            ? DateFormat(
              'MMMM dd, yyyy',
            ).format(DateTime.parse(historyItem.createdAt!))
            : 'N/A';

    // Initialize NumberFormat for Rupiah (IDR) with dot as thousands separator
    final NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id_ID', // Indonesian locale
      symbol: 'Rp', // Rupiah symbol
      decimalDigits: 0, // No decimal digits for whole rupiah
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Order ID and Date
            Center(
              child: Column(
                children: [
                  Text(
                    'Order ID: ${historyItem.id ?? 'N/A'}',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formattedDate,
                    style: GoogleFonts.montserrat(
                      fontSize: 15,
                      color: AppColors.subtleText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // PDF Receipt and Share Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildActionButton(
                  icon: Icons.picture_as_pdf_outlined,
                  text: 'PDF Receipt',
                  onTap:
                      () => debugPrint(
                        'PDF Receipt clicked for Order ID ${historyItem.id}',
                      ),
                ),
                const SizedBox(width: 20),
                _buildActionButton(
                  icon: Icons.share_outlined,
                  text: 'Share',
                  onTap:
                      () => debugPrint(
                        'Share clicked for Order ID ${historyItem.id}',
                      ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Payment Details Section
            _buildSectionTitle('Payment Details'),
            const SizedBox(height: 10),
            _buildDetailCard(
              children: [
                _buildDetailRow(
                  'Amount',
                  currencyFormatter.format(historyItem.total ?? 0),
                  isAmount: true,
                ),
                _buildDetailRow(
                  'Order number',
                  historyItem.id?.toString() ?? 'N/A',
                ),
                _buildDetailRow('Date', formattedDate),
                _buildDetailRow(
                  'Payment method',
                  'Cash payment on delivery', // Static as per original design
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Order Details Section (iterating through historyItem.items)
            _buildSectionTitle('Order Details'),
            const SizedBox(height: 10),
            _buildDetailCard(
              children:
                  historyItem.items?.map((item) {
                    final productName = item.product?.name ?? 'Unknown Product';
                    final quantity = item.quantity ?? 0;
                    // Menggunakan price dari HistoryItem (harga saat checkout)
                    final originalPrice = item.price ?? 0;
                    // Menggunakan discount dari HistoryProduct
                    final dynamic discountRaw = item.product?.discount;
                    double discount =
                        (discountRaw is num) ? discountRaw.toDouble() : 0.0;

                    // Calculate price after discount
                    double priceAfterDiscount = originalPrice.toDouble();
                    if (discount > 0) {
                      priceAfterDiscount =
                          originalPrice * (1 - (discount / 100));
                    }

                    final itemSubtotal = currencyFormatter.format(
                      priceAfterDiscount * quantity,
                    );

                    // Determine image URL from HistoryProduct.imageUrls
                    String imageUrlToDisplay;
                    if (item.product?.imageUrls != null &&
                        item.product!.imageUrls!.isNotEmpty) {
                      final firstImageUrl = item.product!.imageUrls!.first;
                      if (firstImageUrl.startsWith('http://') ||
                          firstImageUrl.startsWith('https://')) {
                        imageUrlToDisplay = firstImageUrl;
                      } else {
                        // Assuming images are in the public/ directory, potentially /public/images/
                        imageUrlToDisplay =
                            '$_publicBaseUrl${firstImageUrl.startsWith('images/') ? firstImageUrl : 'images/$firstImageUrl'}';
                      }
                    } else {
                      imageUrlToDisplay =
                          'https://via.placeholder.com/80x80/${AppColors.primaryGold.value.toRadixString(16).substring(2, 8).toUpperCase()}/FFFFFF?text=Product';
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: AppColors.imagePlaceholderLight,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                imageUrlToDisplay,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => Container(
                                      color: AppColors.imagePlaceholderLight,
                                      child: Center(
                                        child: Icon(
                                          Icons.broken_image,
                                          color: AppColors.subtleGrey,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  productName,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDark,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                if (discount > 0) ...[
                                  Text(
                                    currencyFormatter.format(originalPrice),
                                    style: GoogleFonts.montserrat(
                                      fontSize: 13,
                                      color: AppColors.subtleText,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                ],
                                Text(
                                  currencyFormatter.format(priceAfterDiscount),
                                  style: GoogleFonts.montserrat(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                if (discount > 0)
                                  Text(
                                    '${discount.toInt()}% Off',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 11,
                                      color: AppColors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                const SizedBox(height: 4),
                                Text(
                                  'Quantity: $quantity',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 13,
                                    color: AppColors.subtleText,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Subtotal: $itemSubtotal',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryGold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList() ??
                  [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'No order items found.',
                        style: GoogleFonts.montserrat(
                          color: AppColors.subtleText,
                        ),
                      ),
                    ),
                  ],
            ),
            const SizedBox(height: 30),

            // Addresses Section (static placeholder as API does not provide address details in HistoryItem)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Billing address'),
                      const SizedBox(height: 10),
                      _buildAddressCard(
                        'Jl. Merdeka No. 45, RT. 03/ RW. 02,\nGambir Subdistrict, Gambir District,\nCentral Jakarta, 10110, Indonesia',
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Delivery address'),
                      const SizedBox(height: 10),
                      _buildAddressCard(
                        'Jl. Merdeka No. 45, RT. 03/ RW. 02,\nGambir Subdistrict, Gambir District,\nCentral Jakarta, 10110, Indonesia',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            // Back to Home Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const HomeScreen16(),
                    ),
                    (Route<dynamic> route) => false,
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
                  'Back to Home',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Text(
        'Order Details',
        style: GoogleFonts.playfairDisplay(
          color: AppColors.textDark,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: const <Widget>[],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.cardBackgroundLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.subtleGrey.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Icon(icon, color: AppColors.primaryGold, size: 24),
            const SizedBox(width: 8),
            Text(
              text,
              style: GoogleFonts.montserrat(
                color: AppColors.textDark,
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: GoogleFonts.playfairDisplay(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
      ),
    );
  }

  Widget _buildDetailCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundLight,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isMultiLine = false,
    bool isAmount = false,
  }) {
    return Padding(
      padding:
          isMultiLine
              ? const EdgeInsets.symmetric(vertical: 5.0)
              : const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment:
            isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                color: AppColors.subtleText,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style:
                  isAmount
                      ? GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGold,
                      )
                      : GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(String address) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundLight,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Text(
        address,
        style: GoogleFonts.montserrat(
          fontSize: 14,
          color: AppColors.subtleText,
          height: 1.5,
        ),
      ),
    );
  }
}
