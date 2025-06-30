// lib/tugas_enam_belas/screens/cart/checkout_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:thave_luxe_app/constant/app_color.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/app_models.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/homescreen.dart'; // Import model tunggal untuk CheckoutResponseData

class CheckoutScreen16 extends StatelessWidget {
  static const String id = '/checkout16';

  final CheckoutResponseData? checkoutData; // Menerima data checkout

  const CheckoutScreen16({super.key, this.checkoutData});

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: Text(
          'Checkout Details',
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
            // Kembali ke Home Screen setelah checkout
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen16()),
              (Route<dynamic> route) => false,
            );
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
        child:
            checkoutData == null
                ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      'No checkout data available. Please try checking out again.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        color: AppColors.subtleGrey,
                        fontSize: 18,
                      ),
                    ),
                  ),
                )
                : SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        color: AppColors.cardBackgroundLight,
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        margin: const EdgeInsets.only(bottom: 20),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Checkout Successful!',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.successGreen,
                                ),
                              ),
                              const SizedBox(height: 15),
                              _buildInfoRow(
                                'Transaction ID:',
                                checkoutData!.id?.toString() ?? 'N/A',
                              ),
                              _buildInfoRow(
                                'User ID:',
                                checkoutData!.userId?.toString() ?? 'N/A',
                              ),
                              _buildInfoRow(
                                'Date:',
                                checkoutData!.createdAt != null
                                    ? DateFormat('dd MMM yyyy, HH:mm').format(
                                      DateTime.parse(checkoutData!.createdAt!),
                                    )
                                    : 'N/A',
                              ),
                              const Divider(
                                height: 30,
                                color: AppColors.subtleGrey,
                              ),
                              Text(
                                'Items Purchased:',
                                style: GoogleFonts.montserrat(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 10),
                              if (checkoutData!.items != null &&
                                  checkoutData!.items!.isNotEmpty)
                                ...checkoutData!.items!.map((item) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 5.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${item.product?.name ?? 'Unknown Product'} (x${item.quantity ?? 0})',
                                            style: GoogleFonts.montserrat(
                                              color: AppColors.textDark,
                                              fontSize: 16,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          currencyFormatter.format(
                                            (item.product?.price ?? 0) *
                                                (item.quantity ?? 0),
                                          ),
                                          style: GoogleFonts.montserrat(
                                            color: AppColors.primaryGold,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                })
                              else
                                Text(
                                  'No items found for this transaction.',
                                  style: GoogleFonts.montserrat(
                                    color: AppColors.subtleGrey,
                                  ),
                                ),
                              const Divider(
                                height: 30,
                                color: AppColors.subtleGrey,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Amount:',
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  Text(
                                    currencyFormatter.format(
                                      checkoutData!.total ?? 0,
                                    ),
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryGold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigasi ke Home Screen setelah melihat detail
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomeScreen16(),
                              ),
                              (Route<dynamic> route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGold,
                            foregroundColor: AppColors.darkBackground,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 5,
                          ),
                          child: Text(
                            'Continue Shopping',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkBackground,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.montserrat(
              color: AppColors.subtleText,
              fontSize: 15,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.montserrat(
              color: AppColors.textDark,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
