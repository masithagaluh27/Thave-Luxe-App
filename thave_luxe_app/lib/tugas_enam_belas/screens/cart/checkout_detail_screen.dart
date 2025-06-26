import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thave_luxe_app/constant/app_color.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/homescreen.dart'; // If you want to fetch history

class CheckoutScreen16 extends StatefulWidget {
  const CheckoutScreen16({super.key});
  static const String id = '/checkout16';

  @override
  State<CheckoutScreen16> createState() => _CheckoutScreen16State();
}

class _CheckoutScreen16State extends State<CheckoutScreen16> {
  // You might want to fetch transaction details here if your checkout API
  // returns an ID that can be used to retrieve details for display.
  // For now, it will show a generic success message.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: Text(
          'Checkout Confirmation',
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
            // Navigate back to the home screen after checkout
            Navigator.pushNamedAndRemoveUntil(
              context,
              HomeScreen16.id,
              (route) => false,
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: AppColors.primaryGold,
                  size: 100,
                ),
                const SizedBox(height: 20),
                Text(
                  'Order Placed Successfully!',
                  style: GoogleFonts.playfairDisplay(
                    color: AppColors.lightText,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Thank you for your purchase. Your order has been confirmed and will be processed shortly.',
                  style: GoogleFonts.montserrat(
                    color: AppColors.subtleText,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        HomeScreen16.id,
                        (Route<dynamic> route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGold,
                      foregroundColor: AppColors.darkBackground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      elevation: 8,
                    ),
                    child: Text(
                      'Continue Shopping',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to Transaction History Screen
                    // Navigator.pushNamed(context, TransactionHistoryScreen.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'View Transaction History (Coming Soon!)',
                          style: GoogleFonts.montserrat(color: Colors.white),
                        ),
                        backgroundColor: AppColors.blue,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Text(
                    'View My Orders',
                    style: GoogleFonts.montserrat(
                      color: AppColors.subtleText,
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
