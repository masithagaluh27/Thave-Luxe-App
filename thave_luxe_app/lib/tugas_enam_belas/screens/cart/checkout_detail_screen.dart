import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:thave_luxe_app/constant/app_color.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/checkout_response.dart'; // Make sure this path is correct
import 'package:thave_luxe_app/tugas_enam_belas/screens/homescreen.dart'; // Adjusted for your project structure

class CheckoutScreen16 extends StatelessWidget {
  final CheckoutData?
  checkoutData; // Data from the successful checkout API call

  const CheckoutScreen16({
    super.key,
    this.checkoutData,
  }); // checkoutData can be null

  static const String id = '/checkout16';

  @override
  Widget build(BuildContext context) {
    // If checkoutData is null, show a message and direct to home
    if (checkoutData == null) {
      return Scaffold(
        backgroundColor: AppColors.darkBackground, // Using your AppColors
        appBar: _buildAppBar(context),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.darkBackground,
                AppColors.backgroundGradientEnd,
              ], // Using your AppColors
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.subtleGrey,
                    size: 60,
                  ), // Using your AppColors
                  const SizedBox(height: 20),
                  Text(
                    'No checkout details available. Please complete a checkout process to see details.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      color: AppColors.subtleText, // Using your AppColors
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen16(),
                        ),
                        (Route<dynamic> route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          AppColors.primaryGold, // Using your AppColors
                      foregroundColor:
                          AppColors.darkBackground, // Using your AppColors
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      'Back to Home',
                      style: GoogleFonts.playfairDisplay(
                        color: AppColors.darkBackground, // Using your AppColors
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

    // Format date if available
    // CORRECTED LINE: Removed DateTime.parse()
    final String formattedDate =
        checkoutData?.createdAt != null
            ? DateFormat('MMMM dd,yyyy').format(checkoutData!.createdAt!)
            : 'N/A';

    return Scaffold(
      backgroundColor: AppColors.darkBackground, // Using your AppColors
      appBar: _buildAppBar(context),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.darkBackground,
              AppColors.backgroundGradientEnd,
            ], // Using your AppColors
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 20),
              // Thank you message
              Center(
                child: Text(
                  'Thank you, Your order has\nbeen received.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: AppColors.lightText, // Using your AppColors
                  ),
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
                        () => {
                          // TODO: Implement PDF generation/download
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'PDF Receipt download (Coming Soon!)',
                                style: GoogleFonts.montserrat(
                                  color: AppColors.lightText,
                                ),
                              ),
                              backgroundColor: AppColors.blue,
                              duration: const Duration(seconds: 2),
                            ),
                          ),
                        },
                  ),
                  const SizedBox(width: 20),
                  _buildActionButton(
                    icon: Icons.share_outlined,
                    text: 'Share',
                    onTap:
                        () => {
                          // TODO: Implement share functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Share order details (Coming Soon!)',
                                style: GoogleFonts.montserrat(
                                  color: AppColors.lightText,
                                ),
                              ),
                              backgroundColor: AppColors.blue,
                              duration: const Duration(seconds: 2),
                            ),
                          ),
                        },
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
                    'Rp ${checkoutData!.total?.toStringAsFixed(0) ?? '0'}', // Adjusted for 'Rp' and 0 decimal
                  ),
                  _buildDetailRow(
                    'Order number',
                    checkoutData!.id?.toString() ?? 'N/A',
                  ),
                  _buildDetailRow('Date', formattedDate), // This is now correct
                  _buildDetailRow(
                    'Payment method',
                    'Cash payment on delivery',
                  ), // Static as per original design
                ],
              ),
              const SizedBox(height: 30),

              // Order Details Section
              _buildSectionTitle('Order Details'),
              const SizedBox(height: 10),
              _buildDetailCard(
                children:
                    checkoutData!.items?.map((item) {
                      final productName =
                          item.product?.name ?? 'Unknown Product';
                      final quantity = item.quantity ?? 0;
                      final price = item.product?.price ?? 0;
                      final totalItemPrice = (quantity * price).toStringAsFixed(
                        0,
                      ); // Adjusted for 0 decimal
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: _buildDetailRow(
                          '$productName x $quantity',
                          'Rp $totalItemPrice', // Adjusted for 'Rp'
                          isMultiLine: true,
                        ),
                      );
                    }).toList() ??
                    [
                      Text(
                        'No order items found.',
                        style: GoogleFonts.montserrat(
                          color: AppColors.subtleText,
                        ), // Using your AppColors
                      ),
                    ],
              ),
              const SizedBox(height: 30),

              // Addresses Section (static placeholder as API does not provide address details in CheckoutData)
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
                          'Asif Asif IQBAL\n12 Rue Mohamed V\nApartment 3B\nCasablanca\nMAAZI',
                        ), // Static address
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
                          'Asif Asif IQBAL\n12 Rue Mohamed V\nApartment 3B\nCasablanca\nMAAZI',
                        ), // Static address
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40), // Space before bottom button
              // Back to Home Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    // Pop all routes until the HomeScreen is reached
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen16(),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColors.primaryGold, // Using your AppColors
                    foregroundColor:
                        AppColors.darkBackground, // Using your AppColors
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        16,
                      ), // Adjusted to match your app's general button style
                    ),
                    elevation: 8,
                  ),
                  child: Text(
                    'Back to Home',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20, // Adjusted font size
                      color: AppColors.darkBackground, // Using your AppColors
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20), // Padding for bottom of screen
            ],
          ),
        ),
      ),
    );
  }

  // Custom AppBar for the Checkout Screen
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.darkBackground, // Using your AppColors
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios,
          color: AppColors.lightText,
        ), // Using your AppColors
        onPressed: () {
          Navigator.pop(context); // Go back to the previous screen (CartScreen)
        },
      ),
      title: Text(
        'Checkout Details', // Consistent title
        style: GoogleFonts.playfairDisplay(
          color: AppColors.lightText, // Using your AppColors
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: const <Widget>[
        // Removed notifications icon as it's not typically on checkout success screen
        // If you want it, you can add it back here, ensuring AppColors usage.
      ],
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
          color: AppColors.cardBackgroundDark, // Using your AppColors
          borderRadius: BorderRadius.circular(
            16,
          ), // Adjusted to match app's border style
          border: Border.all(
            color: AppColors.subtleGrey,
          ), // Using your AppColors
        ),
        child: Row(
          children: <Widget>[
            Icon(icon, color: AppColors.primaryGold), // Using your AppColors
            const SizedBox(width: 8),
            Text(
              text,
              style: GoogleFonts.montserrat(
                color: AppColors.lightText, // Using your AppColors
                fontWeight: FontWeight.w500,
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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.lightText, // Using your AppColors
        ),
      ),
    );
  }

  // Helper widget for a card containing details (Payment Details, Order Details)
  Widget _buildDetailCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundDark, // Using your AppColors
        borderRadius: BorderRadius.circular(
          16,
        ), // Adjusted to match app's border style
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              0.3,
            ), // Darker shadow for dark theme
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
              ), // Using your AppColors
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.lightText, // Using your AppColors
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
        color: AppColors.cardBackgroundDark, // Using your AppColors
        borderRadius: BorderRadius.circular(
          16,
        ), // Adjusted to match app's border style
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              0.3,
            ), // Darker shadow for dark theme
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Text(
        address,
        style: GoogleFonts.montserrat(
          fontSize: 15,
          color: AppColors.subtleText,
          height: 1.5,
        ), // Using your AppColors
      ),
    );
  }
}
