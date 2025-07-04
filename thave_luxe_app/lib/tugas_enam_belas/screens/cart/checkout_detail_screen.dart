// lib/tugas_enam_belas/screens/cart/checkout_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:thave_luxe_app/constant/app_color.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/app_models.dart'; // Import your app_models.dart

class CheckoutScreen16 extends StatelessWidget {
  static const String id = '/checkout16';
  final CheckoutResponseData? checkoutData;

  const CheckoutScreen16({super.key, required this.checkoutData});

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    if (checkoutData == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: Text(
            'Checkout Details',
            style: GoogleFonts.playfairDisplay(
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: AppColors.primaryGold,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'No checkout data available. Please try again.',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                color: AppColors.redAccent,
                fontSize: 16,
              ),
            ),
          ),
        ),
      );
    }

    // --- Start: Internal calculation for totals and discounts ---
    double calculatedSubtotalBeforeDiscount = 0.0;
    double calculatedGrandTotal = 0.0;

    checkoutData!.items?.forEach((item) {
      final double originalPrice = item.product?.price?.toDouble() ?? 0.0;
      final double? discount = item.product?.discount;
      final int quantity = item.quantity ?? 0;

      // Add to subtotal before any discounts
      calculatedSubtotalBeforeDiscount += originalPrice * quantity;

      if (discount != null && discount > 0) {
        final double discountedPrice = originalPrice * (1 - discount / 100);
        calculatedGrandTotal += (discountedPrice * quantity);
      } else {
        calculatedGrandTotal += (originalPrice * quantity);
      }
    });

    // Calculate total discount amount based on the difference
    final double totalDiscountAmount =
        calculatedSubtotalBeforeDiscount - calculatedGrandTotal;
    // --- End: Internal calculation ---

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Checkout Details',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryGold),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.backgroundLight,
              AppColors.backgroundGradientLight,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildSectionHeader('Order Summary'),
                  const SizedBox(height: 10),
                  if (checkoutData!.items == null ||
                      checkoutData!.items!.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Text(
                        'No items in this order.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          color: AppColors.subtleText,
                          fontSize: 16,
                        ),
                      ),
                    )
                  else
                    ...checkoutData!.items!.map((item) {
                      final double originalItemPrice =
                          item.product?.price?.toDouble() ?? 0.0;
                      final double? discount = item.product?.discount;
                      final double finalItemPrice =
                          (discount != null && discount > 0)
                              ? originalItemPrice * (1 - discount / 100)
                              : originalItemPrice;
                      final double itemSubtotal =
                          finalItemPrice * (item.quantity ?? 0);

                      // Debug print to check discount value
                      debugPrint(
                        'Product: ${item.product?.name}, Original Price: $originalItemPrice, Discount: $discount, Final Price: $finalItemPrice',
                      );

                      return Card(
                        elevation: 3,
                        color: AppColors.cardBackground,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
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
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child:
                                      item.product?.imageUrls?.isNotEmpty ==
                                              true
                                          ? Image.network(
                                            item.product!.imageUrls!.first,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Icon(
                                                      Icons.broken_image,
                                                      color:
                                                          AppColors.subtleGrey,
                                                    ),
                                          )
                                          : const Icon(
                                            Icons.shopping_bag_outlined,
                                            color: AppColors.subtleGrey,
                                          ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product?.name ?? 'Unknown Product',
                                      style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textDark,
                                        fontSize: 16,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'Qty: ${item.quantity}',
                                      style: GoogleFonts.montserrat(
                                        color: AppColors.subtleText,
                                        fontSize: 13,
                                      ),
                                    ),
                                    if (discount != null &&
                                        discount >
                                            0) // Show original price if there's a discount
                                      Text(
                                        currencyFormatter.format(
                                          originalItemPrice,
                                        ),
                                        style: GoogleFonts.montserrat(
                                          color: AppColors.subtleText,
                                          fontSize: 12,
                                          decoration:
                                              TextDecoration.lineThrough,
                                        ),
                                      ),
                                    Text(
                                      currencyFormatter.format(finalItemPrice),
                                      style: GoogleFonts.montserrat(
                                        color: AppColors.primaryGold,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (discount != null &&
                                        discount >
                                            0) // Show discount percentage
                                      Text(
                                        'Discount: ${discount.toInt()}%',
                                        style: GoogleFonts.montserrat(
                                          color: AppColors.green,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                currencyFormatter.format(itemSubtotal),
                                style: GoogleFonts.playfairDisplay(
                                  color: AppColors.textDark,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  const SizedBox(height: 20),
                  _buildSectionHeader('Payment Summary'),
                  const SizedBox(height: 10),
                  _buildSummaryRow(
                    'Subtotal (Before Discount)',
                    currencyFormatter.format(calculatedSubtotalBeforeDiscount),
                    AppColors.textDark,
                  ),
                  if (totalDiscountAmount >
                      0) // Only show if there's an actual discount
                    _buildSummaryRow(
                      'Total Discount',
                      '- ${currencyFormatter.format(totalDiscountAmount)}',
                      AppColors.redAccent, // Red for discount amount
                    ),
                  _buildSummaryRow(
                    'Shipping Fee',
                    currencyFormatter.format(0), // Assuming 0 for now
                    AppColors.textDark,
                  ),
                  const Divider(color: AppColors.subtleGrey, height: 30),
                  _buildSummaryRow(
                    'Grand Total',
                    currencyFormatter.format(
                      calculatedGrandTotal,
                    ), // Use calculated grand total
                    AppColors.primaryGold,
                    isGrandTotal: true,
                  ),
                ],
              ),
            ),
            _buildContinueShoppingButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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

  Widget _buildSummaryRow(
    String label,
    String value,
    Color valueColor, {
    bool isGrandTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            // Use Expanded for the label
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.montserrat(
                color: AppColors.textDark,
                fontSize:
                    isGrandTotal
                        ? 16
                        : 15, // Slightly reduced font size for grand total label
                fontWeight: isGrandTotal ? FontWeight.bold : FontWeight.normal,
              ),
              maxLines: 1, // Ensure no overflow
              overflow: TextOverflow.ellipsis, // Add ellipsis for overflow
            ),
          ),
          const SizedBox(width: 8), // Small space between label and value
          Expanded(
            // Use Expanded for the value
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end, // Align value to the end
              style: GoogleFonts.montserrat(
                color: valueColor,
                fontSize:
                    isGrandTotal
                        ? 18
                        : 15, // Slightly reduced font size for grand total value
                fontWeight: isGrandTotal ? FontWeight.bold : FontWeight.w600,
              ),
              maxLines: 1, // Ensure no overflow
              overflow: TextOverflow.ellipsis, // Add ellipsis for overflow
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueShoppingButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Navigator.popUntil(
              context,
              (route) => route.isFirst,
            ); // Go back to home
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGold,
            foregroundColor: AppColors.textLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 18),
            elevation: 8,
          ),
          child: Text(
            'Continue Shopping',
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
