// Make sure this path is correct for your project structure
// Assuming app_color.dart is in constant/app_color.dart as seen in ProfileScreen16
import 'package:thave_luxe_app/constant/app_color.dart';
import 'package:thave_luxe_app/helper/preference_handler.dart';
import 'package:thave_luxe_app/tugas_enam_belas/api/store_provider.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/history_response.dart';
import 'package:thave_luxe_app/tugas_enam_belas/screens/history/history_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  static const String id = '/history16'; // Define a route ID for consistency

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // Use AppColors from your constant file
  // static const Color primaryPink = Color(0xFFE91E63); // REMOVED
  static const String _baseUrl = 'https://apptoko.mobileprojp.com/public/';

  final ApiProvider _apiService = ApiProvider();
  final user = PreferenceHandler.getUserData();

  late Future<HistoryResponse> _historyFuture;

  final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _historyFuture = _fetchHistory();
  }

  Future<HistoryResponse> _fetchHistory() async {
    try {
      final user = await PreferenceHandler.getUserData();
      if (user == null || user.id == null) {
        throw Exception('Please log in to view your transaction history.');
      }
      return await _apiService.getTransactionHistory();
    } catch (e) {
      print('Error fetching history: $e');
      return Future.error(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.backgroundLight, // Use your app's background color
      appBar: _buildAppBar(context),
      body: FutureBuilder<HistoryResponse>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryGold,
              ), // Use your primary color
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0), // Consistent padding
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${snapshot.error.toString().replaceFirst('Exception: ', '')}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        color: AppColors.redAccent, // Consistent error color
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _historyFuture = _fetchHistory(); // Retry
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            AppColors.primaryGold, // Consistent button style
                        foregroundColor:
                            AppColors.darkBackground, // Text color for button
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            12,
                          ), // Consistent border radius
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        'Retry',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 16,
                        ), // Consistent font
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasData) {
            final List<HistoryItem> history = snapshot.data!.data ?? [];
            if (history.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 80,
                      color: AppColors.subtleGrey, // Consistent grey color
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'No order history found.',
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        color: AppColors.subtleText, // Consistent text color
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 15.0,
              ), // Consistent padding
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                return _buildHistoryCard(item);
              },
            );
          } else {
            return Center(
              child: Text(
                'No history data available.',
                style: GoogleFonts.montserrat(
                  color: AppColors.textDark, // Consistent text color
                ),
              ),
            );
          }
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent, // Transparent background
      elevation: 0, // No shadow
      title: Text(
        'Order History',
        style: GoogleFonts.playfairDisplay(
          // Use Playfair Display for title
          color: AppColors.textDark, // Consistent text color
          fontSize: 24, // Consistent font size
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        // Consistent back button
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      // Removed notification icon to match ProfileScreen16's actions (which were empty)
      actions: <Widget>[],
    );
  }

  Widget _buildHistoryCard(HistoryItem historyItem) {
    final String formattedDate =
        historyItem.createdAt != null
            ? DateFormat('MMMM dd, yyyy').format(historyItem.createdAt!)
            : 'N/A';

    final String totalAmount = _currencyFormatter.format(
      historyItem.total ?? 0,
    );

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HistoryDetailScreen(historyItem: historyItem),
          ),
        );
      },
      child: Container(
        // Changed from Card to Container to better control styling with Box Shadow
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: AppColors.cardBackgroundLight, // Consistent card background
          borderRadius: BorderRadius.circular(15.0), // Consistent border radius
          boxShadow: [
            // Consistent shadow from ProfileScreen16
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order ID: ${historyItem.id ?? 'N/A'}',
                    style: GoogleFonts.montserrat(
                      // Consistent font
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark, // Consistent text color
                    ),
                  ),
                  Text(
                    formattedDate,
                    style: GoogleFonts.montserrat(
                      // Consistent font
                      fontSize: 14,
                      color: AppColors.subtleText, // Consistent grey color
                    ),
                  ),
                ],
              ),
              Padding(
                // Using Padding and Divider widget for consistency
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Divider(
                  color: AppColors.subtleGrey.withOpacity(
                    0.4,
                  ), // Consistent divider
                  thickness: 1,
                ),
              ),
              if (historyItem.items != null && historyItem.items!.isNotEmpty)
                ...historyItem.items!.map((item) {
                  final productName = item.product?.name ?? 'Unknown Product';
                  final quantity = item.quantity ?? 0;
                  final price = item.product?.price ?? 0;
                  double itemPrice = price.toDouble();
                  if (item.product?.discount != null &&
                      item.product!.discount! > 0) {
                    itemPrice =
                        itemPrice * (1 - (item.product!.discount! / 100));
                  }
                  final itemSubtotal = _currencyFormatter.format(
                    itemPrice * quantity,
                  );

                  String imageUrlToDisplay =
                      item.product?.imageUrl != null &&
                              item.product!.imageUrl!.isNotEmpty
                          ? (item.product!.imageUrl!.startsWith('http')
                              ? item.product!.imageUrl!
                              : '$_baseUrl${item.product!.imageUrl!}')
                          : 'https://placehold.co/50x50/FFC0CB/000000?text=P'; // Placeholder needs to be updated manually

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Row(
                      children: [
                        // Item Image
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            // Using a placeholder background color that fits theme
                            color: AppColors.subtleGrey.withOpacity(0.3),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              imageUrlToDisplay,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) => Container(
                                    color: AppColors.subtleGrey.withOpacity(
                                      0.2,
                                    ), // Consistent grey
                                    child: Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        size: 20,
                                        color: AppColors.subtleText,
                                      ), // Consistent text color
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
                                  // Consistent font
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      AppColors
                                          .textDark, // Consistent text color
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Qty: $quantity',
                                style: GoogleFonts.montserrat(
                                  // Consistent font
                                  fontSize: 13,
                                  color:
                                      AppColors
                                          .subtleText, // Consistent grey color
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          itemSubtotal,
                          style: GoogleFonts.montserrat(
                            // Consistent font
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark, // Consistent text color
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList()
              else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'No items found for this order.',
                    style: GoogleFonts.montserrat(
                      // Consistent font
                      fontStyle: FontStyle.italic,
                      color: AppColors.subtleText, // Consistent grey color
                    ),
                  ),
                ),
              Padding(
                // Using Padding and Divider widget for consistency
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Divider(
                  color: AppColors.subtleGrey.withOpacity(
                    0.4,
                  ), // Consistent divider
                  thickness: 1,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount:',
                    style: GoogleFonts.montserrat(
                      // Consistent font
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark, // Consistent text color
                    ),
                  ),
                  Text(
                    totalAmount,
                    style: GoogleFonts.playfairDisplay(
                      // Use Playfair for total amount
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGold, // Your primary gold color
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
