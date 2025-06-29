import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

// Adjust these paths to your actual project structure
import 'package:thave_luxe_app/constant/app_color.dart'; // Your AppColors
import 'package:thave_luxe_app/tugas_enam_belas/models/history_response.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/homescreen.dart';

class HistoryDetailScreen extends StatelessWidget {
  final HistoryItem historyItem; // The specific history item to display

  const HistoryDetailScreen({super.key, required this.historyItem});

  static const String id = '/detailhistory';

  static const String _baseUrl =
      'https://apptoko.mobileprojp.com/public/'; // Base URL for images

  @override
  Widget build(BuildContext context) {
    // Format date if available
    final String formattedDate =
        historyItem.createdAt != null
            ? DateFormat('MMMM dd, yyyy').format(historyItem.createdAt!)
            : 'N/A';

    // Initialize NumberFormat for Rupiah (IDR) with dot as thousands separator
    final NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id_ID', // Indonesian locale
      symbol: 'Rp', // Rupiah symbol
      decimalDigits: 0, // No decimal digits for whole rupiah
    );

    return Scaffold(
      backgroundColor:
          AppColors.backgroundLight, // Using your app's background color
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 15.0,
        ), // Consistent padding
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
                      // Luxury font for prominent text
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark, // Consistent dark text
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formattedDate,
                    style: GoogleFonts.montserrat(
                      // Standard font for details
                      fontSize: 15,
                      color: AppColors.subtleText, // Consistent grey text
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
                      () => print(
                        'PDF Receipt clicked for Order ID ${historyItem.id}',
                      ),
                ),
                const SizedBox(width: 20),
                _buildActionButton(
                  icon: Icons.share_outlined,
                  text: 'Share',
                  onTap:
                      () =>
                          print('Share clicked for Order ID ${historyItem.id}'),
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
                  isAmount: true, // Mark this row for special styling
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
                    final originalPrice = item.product?.price ?? 0;
                    final discount = item.product?.discount;

                    // Calculate price after discount
                    double priceAfterDiscount = originalPrice.toDouble();
                    if (discount != null && discount > 0) {
                      priceAfterDiscount =
                          originalPrice * (1 - (discount / 100));
                    }

                    final itemSubtotal = currencyFormatter.format(
                      priceAfterDiscount * quantity,
                    );

                    // Determine image URL
                    String? rawImageUrl = item.product?.imageUrl;
                    String imageUrlToDisplay;

                    if (rawImageUrl != null && rawImageUrl.isNotEmpty) {
                      if (rawImageUrl.startsWith('http://') ||
                          rawImageUrl.startsWith('https://')) {
                        imageUrlToDisplay = rawImageUrl;
                      } else {
                        imageUrlToDisplay = '$_baseUrl$rawImageUrl';
                      }
                    } else {
                      imageUrlToDisplay =
                          'https://via.placeholder.com/80x80/${AppColors.primaryGold.value.toRadixString(16).substring(2, 8).toUpperCase()}/FFFFFF?text=Product'; // Using primaryGold for placeholder
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
                              color:
                                  AppColors
                                      .imagePlaceholderLight, // Use dedicated placeholder color
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                imageUrlToDisplay,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => Container(
                                      color:
                                          AppColors
                                              .imagePlaceholderLight, // Fallback placeholder color
                                      child: Center(
                                        child: Icon(
                                          Icons.broken_image,
                                          color: AppColors.subtleGrey,
                                        ), // Subtle broken image icon
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
                                if (discount != null && discount > 0) ...[
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
                                if (discount != null && discount > 0)
                                  Text(
                                    '${discount.toInt()}% Off',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 11,
                                      color:
                                          AppColors
                                              .green, // Using AppColors.green for discounts
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
                                    color:
                                        AppColors
                                            .primaryGold, // Primary gold for subtotal
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
            const SizedBox(height: 40), // Space before bottom button
            // Back to Home Button
            SizedBox(
              width: double.infinity,
              height: 55, // Slightly reduced height for sleekness
              child: ElevatedButton(
                onPressed: () {
                  // Pop all routes until the MainNavigationScreen is reached
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const HomeScreen16(),
                    ),
                    (Route<dynamic> route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.primaryGold, // Gold button background
                  foregroundColor:
                      AppColors.darkBackground, // Dark text on gold button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      12,
                    ), // Consistent border radius
                  ),
                ),
                child: Text(
                  'Back to Home',
                  style: GoogleFonts.playfairDisplay(
                    // Luxury font for button text
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20), // Padding for bottom of screen
          ],
        ),
      ),
    );
  }

  // Custom AppBar for the History Detail Screen
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent, // Transparent background
      elevation: 0, // No shadow
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios,
          color: AppColors.textDark,
        ), // Consistent back button color
        onPressed: () {
          Navigator.pop(
            context,
          ); // Go back to the previous screen (HistoryScreen)
        },
      ),
      title: Text(
        'Order Details',
        style: GoogleFonts.playfairDisplay(
          // Luxury font for title
          color: AppColors.textDark,
          fontSize: 24, // Larger title font
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      // Removed notification icon to match the luxury app aesthetic (often minimal icons)
      actions: const <Widget>[],
    );
  }

  // Helper widget for PDF Receipt and Share buttons
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
          color: AppColors.cardBackgroundLight, // Card background color
          borderRadius: BorderRadius.circular(12), // Consistent border radius
          border: Border.all(
            color: AppColors.subtleGrey.withOpacity(0.5),
          ), // Subtle border
          boxShadow: [
            // Consistent shadow
            BoxShadow(
              color: AppColors.shadowColor, // Using your defined shadowColor
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Icon(icon, color: AppColors.primaryGold, size: 24), // Gold icon
            const SizedBox(width: 8),
            Text(
              text,
              style: GoogleFonts.montserrat(
                // Consistent font
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

  // Helper widget for section titles (e.g., Payment Details, Order Details)
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: GoogleFonts.playfairDisplay(
          // Luxury font for section titles
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
      ),
    );
  }

  // Helper widget for a card containing details (Payment Details, Order Details)
  Widget _buildDetailCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundLight, // Card background color
        borderRadius: BorderRadius.circular(15), // Consistent border radius
        boxShadow: [
          // Consistent shadow
          BoxShadow(
            color: AppColors.shadowColor, // Using your defined shadowColor
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  // Helper widget for a single row of detail (e.g., Amount: $960.00)
  Widget _buildDetailRow(
    String label,
    String value, {
    bool isMultiLine = false,
    bool isAmount = false, // New parameter to apply special style for amount
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
              ), // Consistent text
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style:
                  isAmount // Apply special style if it's the amount row
                      ? GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color:
                            AppColors.primaryGold, // Gold for the total amount
                      )
                      : GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark, // Dark text for other values
                      ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for address cards
  Widget _buildAddressCard(String address) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundLight, // Card background color
        borderRadius: BorderRadius.circular(15), // Consistent border radius
        boxShadow: [
          // Consistent shadow
          BoxShadow(
            color: AppColors.shadowColor, // Using your defined shadowColor
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
        ), // Consistent text
      ),
    );
  }
}
