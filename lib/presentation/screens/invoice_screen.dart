import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/font_utility.dart';
import '../../bloc/cart/cart_bloc.dart';
import '../../bloc/cart/cart_state.dart';
import '../../bloc/cart/cart_event.dart';
import 'home_screen.dart';

class InvoiceScreen extends StatelessWidget {
  const InvoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Prevent going back without action
        title: Text(
          'Invoice / Receipt',
          style: FontUtility.heading.copyWith(fontSize: 20),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.black87),
            onPressed: () => _finishOrder(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey.withOpacity(0.2), height: 1.0),
        ),
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          return SafeArea(
            child: Center(
              child: Container(
                width: 600, // Fixed width for tablet optimized invoice view
                margin: const EdgeInsets.symmetric(vertical: 40),
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Center(
                      child: Column(
                        children: [
                          Icon(Icons.check_circle_rounded, size: 64, color: Colors.green.shade400),
                          const SizedBox(height: 16),
                          Text(
                            'Payment Successful',
                            style: FontUtility.heading.copyWith(fontSize: 24, color: Colors.green.shade700),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Invoice #INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
                            style: FontUtility.body.copyWith(color: Colors.grey.shade600),
                          ),
                          Text(
                            'Method: ${state.selectedPaymentMethod ?? 'Unknown'}',
                            style: FontUtility.body.copyWith(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Itemized list
                    Text('Order Summary', style: FontUtility.heading.copyWith(fontSize: 18)),
                    const SizedBox(height: 16),
                    const Divider(thickness: 1.5),
                    Expanded(
                      child: ListView.builder(
                        itemCount: state.cartItems.length,
                        itemBuilder: (context, index) {
                          final item = state.cartItems[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${item.quantity}x',
                                  style: FontUtility.subheading.copyWith(fontSize: 16),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    item.product.name,
                                    style: FontUtility.body.copyWith(fontSize: 16),
                                  ),
                                ),
                                Text(
                                  '\$${item.totalPrice.toStringAsFixed(2)}',
                                  style: FontUtility.subheading.copyWith(fontSize: 16),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    
                    const Divider(thickness: 1.5),
                    const SizedBox(height: 16),
                    
                    // Totals
                    _buildSummaryRow('Sub Total', '\$${state.subTotal.toStringAsFixed(2)}'),
                    const SizedBox(height: 12),
                    _buildSummaryRow('Delivery Charge', '\$${state.deliveryCharge.toStringAsFixed(2)}'),
                    if (state.discountPercentage > 0) ...[
                      const SizedBox(height: 12),
                      _buildSummaryRow('Discount (${state.discountPercentage}%)', '-\$${state.discountValue.toStringAsFixed(2)}', color: Colors.green.shade700),
                    ],
                    if (state.serviceTaxPercentage > 0) ...[
                      const SizedBox(height: 12),
                      _buildSummaryRow('Service Tax (${state.serviceTaxPercentage}%)', '+\$${state.serviceTaxValue.toStringAsFixed(2)}', color: Colors.orange.shade700),
                    ],
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A00E0).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Grand Total',
                            style: FontUtility.heading.copyWith(fontSize: 20),
                          ),
                          Text(
                            '\$${state.netTotal.toStringAsFixed(2)}',
                            style: FontUtility.heading.copyWith(
                              fontSize: 24,
                              color: const Color(0xFF4A00E0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: OutlinedButton.icon(
                            onPressed: () => _finishOrder(context),
                            icon: const Icon(Icons.home_rounded),
                            label: const Text('NEW ORDER'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: Color(0xFF4A00E0)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Printing to Thermal Printer...')),
                              );
                            },
                            icon: const Icon(Icons.print_rounded, color: Colors.white),
                            label: Text(
                              'PRINT INVOICE',
                              style: FontUtility.heading.copyWith(color: Colors.white, fontSize: 16),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4A00E0),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _finishOrder(BuildContext context) {
    // Dispatch clear cart event 
    context.read<CartBloc>().add(ClearCart());
    // Navigate to home and clear stack
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
    );
  }

  Widget _buildSummaryRow(String title, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: FontUtility.body.copyWith(color: Colors.grey.shade600, fontSize: 16),
        ),
        Text(
          value,
          style: FontUtility.subheading.copyWith(fontSize: 16, color: color ?? Colors.black87),
        ),
      ],
    );
  }
}
