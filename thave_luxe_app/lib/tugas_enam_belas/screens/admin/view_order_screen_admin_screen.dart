import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:thave_luxe_app/constant/app_color.dart';
import 'package:thave_luxe_app/tugas_enam_belas/api/order_provider.dart'; // Import the new OrderProvider
import 'package:thave_luxe_app/tugas_enam_belas/models/order_history_response.dart'; // Import OrderData model

class ViewOrdersScreen16 extends StatefulWidget {
  const ViewOrdersScreen16({super.key});
  static const String id = '/viewOrders16';

  @override
  State<ViewOrdersScreen16> createState() => _ViewOrdersScreen16State();
}

class _ViewOrdersScreen16State extends State<ViewOrdersScreen16> {
  final OrderProvider _orderProvider = OrderProvider();
  List<OrderData> _orders = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final fetchedOrders = await _orderProvider.getOrderHistory();
      setState(() {
        _orders = fetchedOrders;
      });
    } on Exception catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.montserrat(color: AppColors.lightText),
          ),
          backgroundColor: color,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(10),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: Text(
          'Order History',
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
            Navigator.pop(context);
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
        child: RefreshIndicator(
          onRefresh: _fetchOrders,
          color: AppColors.primaryGold,
          child:
              _isLoading
                  ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryGold,
                      ),
                    ),
                  )
                  : _errorMessage != null
                  ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Error: $_errorMessage',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.redAccent,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _fetchOrders,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGold,
                              foregroundColor: AppColors.darkBackground,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
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
                  )
                  : _orders.isEmpty
                  ? Center(
                    child: Text(
                      'No orders found.',
                      style: GoogleFonts.playfairDisplay(
                        color: AppColors.subtleGrey,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _orders.length,
                    itemBuilder: (context, index) {
                      final order = _orders[index];
                      return Card(
                        elevation: 4,
                        color: AppColors.cardBackgroundLight,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ExpansionTile(
                          // Use ExpansionTile for collapsible order details
                          title: Text(
                            'Order #${order.id ?? 'N/A'}',
                            style: GoogleFonts.montserrat(
                              color: AppColors.textDark,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Text(
                            'Total: Rp ${order.total?.toStringAsFixed(0) ?? 'N/A'}'
                            ' - ${order.createdAt != null ? DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(order.createdAt!)) : 'N/A'}',
                            style: GoogleFonts.montserrat(
                              color: AppColors.subtleText,
                              fontSize: 13,
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Items:',
                                    style: GoogleFonts.montserrat(
                                      color: AppColors.textDark,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  if (order.items != null &&
                                      order.items!.isNotEmpty)
                                    ...order.items!.map(
                                      (item) => Padding(
                                        padding: const EdgeInsets.only(
                                          left: 8.0,
                                          bottom: 4.0,
                                        ),
                                        child: Text(
                                          '${item.product?.name ?? 'Unknown Product'} x ${item.quantity ?? 1} '
                                          '(Rp ${(item.product?.price ?? 0) * (item.quantity ?? 1)})',
                                          style: GoogleFonts.montserrat(
                                            color: AppColors.subtleText,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (order.items == null ||
                                      order.items!.isEmpty)
                                    Text(
                                      'No items in this order.',
                                      style: GoogleFonts.montserrat(
                                        color: AppColors.subtleText,
                                        fontSize: 13,
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'User ID: ${order.userId ?? 'N/A'}',
                                    style: GoogleFonts.montserrat(
                                      color: AppColors.textDark,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
        ),
      ),
    );
  }
}
