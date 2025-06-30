import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:thave_luxe_app/constant/app_color.dart';
import 'package:thave_luxe_app/helper/preference_handler.dart';
import 'package:thave_luxe_app/tugas_enam_belas/api/api_provider.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/app_models.dart'; // Menggunakan model tunggal app_models.dart
import 'package:thave_luxe_app/tugas_enam_belas/screens/history/history_detail_screen.dart'; // Pastikan ini mengarah ke file HistoryDetailScreen Anda

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  static const String id = '/history16';

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ApiProvider _apiService = ApiProvider();

  // Menggunakan model History dari app_models.dart
  late Future<List<History>> _historyFuture;

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

  Future<List<History>> _fetchHistory() async {
    try {
      final user = await PreferenceHandler.getUserData();
      if (user == null || user.id == null) {
        throw Exception('Please log in to view your transaction history.');
      }
      final apiResponse = await _apiService.getPurchaseHistory();
      if (apiResponse.data != null) {
        return apiResponse.data!;
      } else {
        throw Exception(apiResponse.message ?? 'No history data found.');
      }
    } catch (e) {
      debugPrint('Error fetching history: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: _buildAppBar(context),
      body: FutureBuilder<List<History>>(
        // FutureBuilder untuk List<History>
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primaryGold),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${snapshot.error.toString().replaceFirst('Exception: ', '')}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        color: AppColors.redAccent,
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
                        backgroundColor: AppColors.primaryGold,
                        foregroundColor: AppColors.darkBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        'Retry',
                        style: GoogleFonts.playfairDisplay(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasData) {
            final List<History> history = snapshot.data ?? [];
            if (history.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 80,
                      color: AppColors.subtleGrey,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'No order history found.',
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        color: AppColors.subtleText,
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
              ),
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
                style: GoogleFonts.montserrat(color: AppColors.textDark),
              ),
            );
          }
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        'Order History',
        style: GoogleFonts.playfairDisplay(
          color: AppColors.textDark,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios,
          color: Color.fromARGB(255, 228, 228, 228),
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      actions: const [],
    );
  }

  // Menggunakan model History dari app_models.dart
  Widget _buildHistoryCard(History historyItem) {
    final String formattedDate =
        historyItem.createdAt != null
            ? DateFormat(
              'MMMM dd, yyyy',
            ).format(DateTime.parse(historyItem.createdAt!))
            : 'N/A';

    final String totalAmount = _currencyFormatter.format(
      historyItem.total ?? 0,
    );

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => HistoryDetailScreen(
                  historyItem: historyItem,
                ), // Mengirim objek History
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    formattedDate,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: AppColors.subtleText,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Divider(
                  color: AppColors.subtleGrey.withOpacity(0.4),
                  thickness: 1,
                ),
              ),
              if (historyItem.items != null && historyItem.items!.isNotEmpty)
                ...historyItem.items!.map((item) {
                  // Menggunakan HistoryProduct dari HistoryItem
                  final productName = item.product?.name ?? 'Unknown Product';
                  final quantity = item.quantity ?? 0;
                  final price =
                      item.product?.price ?? 0; // Price from HistoryProduct

                  double itemPrice = price.toDouble();
                  // Apply discount if available from HistoryProduct
                  if (item.product?.discount != null &&
                      (item.product!.discount as num) > 0) {
                    itemPrice =
                        itemPrice *
                        (1 -
                            ((item.product!.discount as num).toDouble() / 100));
                  }
                  final itemSubtotal = _currencyFormatter.format(
                    itemPrice * quantity,
                  );

                  // String imageUrlToDisplay = '';
                  // // Check if imageUrls is not null and not empty from HistoryProduct
                  // if (item.product?.imageUrls != null &&
                  //     item.product!.imageUrls!.isNotEmpty) {
                  //   final firstImageUrl = item.product!.imageUrls!.first;
                  //   // Prepend base URL only if it's not already a full URL
                  //   imageUrlToDisplay =
                  //       firstImageUrl.startsWith('http')
                  //           ? firstImageUrl
                  //           : '${ApiProvider._baseUrl}/images/$firstImageUrl'; // Sesuaikan '/images/' jika perlu
                  // } else {
                  //   imageUrlToDisplay =
                  //       'https://placehold.co/50x50/FFC0CB/000000?text=P'; // Default placeholder
                  // }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Row(
                      children: [
                        // Item Image
                        // Container(
                        //   width: 50,
                        //   height: 50,
                        //   decoration: BoxDecoration(
                        //     borderRadius: BorderRadius.circular(10),
                        //     color: AppColors.subtleGrey.withOpacity(0.3),
                        //   ),
                        //   child: ClipRRect(
                        //     borderRadius: BorderRadius.circular(10),
                        //     child: Image.network(
                        //       imageUrlToDisplay,
                        //       fit: BoxFit.cover,
                        //       errorBuilder:
                        //           (context, error, stackTrace) => Container(
                        //             color: AppColors.subtleGrey.withOpacity(
                        //               0.2,
                        //             ),
                        //             child: Center(
                        //               child: Icon(
                        //                 Icons.broken_image,
                        //                 size: 20,
                        //                 color: AppColors.subtleText,
                        //               ),
                        //             ),
                        //           ),
                        //     ),
                        //   ),
                        // ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                productName,
                                style: GoogleFonts.montserrat(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textDark,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Qty: $quantity',
                                style: GoogleFonts.montserrat(
                                  fontSize: 13,
                                  color: AppColors.subtleText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          itemSubtotal,
                          style: GoogleFonts.montserrat(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  );
                })
              else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'No items found for this order.',
                    style: GoogleFonts.montserrat(
                      fontStyle: FontStyle.italic,
                      color: AppColors.subtleText,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Divider(
                  color: AppColors.subtleGrey.withOpacity(0.4),
                  thickness: 1,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount:',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    totalAmount,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
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
    );
  }
}
