// lib/tugas_enam_belas/screens/cart/checkout_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:thave_luxe_app/constant/app_color.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/app_models.dart';

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
      appBar: AppBar(title: Text('Checkout Details')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'Checkout Successful!',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text("Transaction ID: 17"),
                      Text("User ID: 8"),
                      Text("Date: 02 Jul 2025, 07:12"),
                      Divider(height: 30),
                      Text(
                        "Items Purchased:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text("de Barrier Repair Moisture Gel (x3)  Rp417.000"),
                      Divider(height: 30),
                      Text(
                        "Total Amount: Rp417.000",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.amber[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Back to Home / Shopping
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[800],
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Continue Shopping',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              SizedBox(height: 20),
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
              color: AppColors.subtleText, // Subtle dark text
              fontSize: 15,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.montserrat(
              color: AppColors.textDark, // Dark text
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
