import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/font_utility.dart';
import '../../bloc/cart/cart_bloc.dart';
import '../../bloc/cart/cart_state.dart';
import '../../bloc/cart/cart_event.dart';
import '../widgets/billing/billing_items_table.dart';
import '../widgets/billing/billing_summary_card.dart';
import '../widgets/billing/payment_method_card.dart';
import '../widgets/billing/calculation_input_section.dart';
import '../widgets/billing/payment_confirmation_dialog.dart';
import 'invoice_screen.dart';

enum RightPanelMode { payment, discount, tax }

class BillingSummaryScreen extends StatefulWidget {
  const BillingSummaryScreen({super.key});

  @override
  State<BillingSummaryScreen> createState() => _BillingSummaryScreenState();
}

class _BillingSummaryScreenState extends State<BillingSummaryScreen> {
  RightPanelMode _rightPanelMode = RightPanelMode.payment;

  void _showPaymentConfirmation(BuildContext context, CartState state, String paymentMethod) {
    context.read<CartBloc>().add(SelectPaymentMethod(paymentMethod));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return PaymentConfirmationDialog(
          paymentMethod: paymentMethod,
          amount: state.netTotal,
          onConfirm: () {
            // Confirm action
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Payment Successful!'),
                backgroundColor: Colors.green,
              ),
            );

            // Navigate to invoice screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (navContext) => BlocProvider.value(
                  value: context.read<CartBloc>(),
                  child: const InvoiceScreen(),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Billing & Payment',
          style: FontUtility.heading.copyWith(fontSize: 20),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey.withOpacity(0.2), height: 1.0),
        ),
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state.cartItems.isEmpty) {
            return Center(
              child: Text(
                'No items to bill.',
                style: FontUtility.heading.copyWith(color: Colors.grey),
              ),
            );
          }

          return SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // LEFT SIDE (60%)
                Expanded(
                  flex: 60,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Items Table
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                BillingItemsTable(items: state.cartItems),
                                const SizedBox(height: 24),
                                
                                // Discount & Tax Actions
                                Row(
                                  children: [
                                    if (state.discountPercentage == 0)
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () {
                                            setState(() => _rightPanelMode = RightPanelMode.discount);
                                          },
                                          icon: const Icon(Icons.percent_rounded),
                                          label: const Text('Add Discount'),
                                          style: _actionButtonStyle(),
                                        ),
                                      ),
                                    if (state.discountPercentage == 0 && state.serviceTaxPercentage == 0)
                                      const SizedBox(width: 16),
                                    if (state.serviceTaxPercentage == 0)
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () {
                                            setState(() => _rightPanelMode = RightPanelMode.tax);
                                          },
                                          icon: const Icon(Icons.receipt_long_rounded),
                                          label: const Text('Add Service Tax'),
                                          style: _actionButtonStyle(),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        // Summary Card
                        BillingSummaryCard(
                          subTotal: state.subTotal,
                          deliveryCharge: state.deliveryCharge,
                          discountValue: state.discountValue,
                          discountPercentage: state.discountPercentage,
                          serviceTaxValue: state.serviceTaxValue,
                          serviceTaxPercentage: state.serviceTaxPercentage,
                          netTotal: state.netTotal,
                        ),
                      ],
                    ),
                  ),
                ),

                Container(width: 1, color: Colors.grey.withOpacity(0.2)),

                // RIGHT SIDE (40%)
                Expanded(
                  flex: 40,
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(32),
                    child: _buildRightPanel(context, state),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  ButtonStyle _actionButtonStyle() {
    return OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 16),
      foregroundColor: const Color(0xFF4A00E0),
      side: const BorderSide(color: Color(0xFF4A00E0), width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: FontUtility.subheading.copyWith(fontSize: 16),
    );
  }

  Widget _buildRightPanel(BuildContext context, CartState state) {
    switch (_rightPanelMode) {
      case RightPanelMode.discount:
        return Column(
          children: [
            CalculationInputSection(
              title: 'Apply Discount',
              placeholder: 'Enter discount percentage (1-100)',
              onApply: (val) {
                context.read<CartBloc>().add(ApplyDiscount(val));
                setState(() => _rightPanelMode = RightPanelMode.payment);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Discount Applied')),
                );
              },
              onCancel: () {
                setState(() => _rightPanelMode = RightPanelMode.payment);
              },
            ),
            if (state.discountPercentage > 0) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {
                  context.read<CartBloc>().add(RemoveDiscount());
                  setState(() => _rightPanelMode = RightPanelMode.payment);
                },
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: Text(
                  'Remove Existing Discount',
                  style: FontUtility.subheading.copyWith(color: Colors.red),
                ),
              )
            ]
          ],
        );

      case RightPanelMode.tax:
        return Column(
          children: [
            CalculationInputSection(
              title: 'Apply Service Tax',
              placeholder: 'Enter tax percentage (1-100)',
              onApply: (val) {
                context.read<CartBloc>().add(ApplyServiceTax(val));
                setState(() => _rightPanelMode = RightPanelMode.payment);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Service Tax Applied')),
                );
              },
              onCancel: () {
                setState(() => _rightPanelMode = RightPanelMode.payment);
              },
            ),
            if (state.serviceTaxPercentage > 0) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {
                  context.read<CartBloc>().add(RemoveServiceTax());
                  setState(() => _rightPanelMode = RightPanelMode.payment);
                },
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: Text(
                  'Remove Existing Tax',
                  style: FontUtility.subheading.copyWith(color: Colors.red),
                ),
              )
            ]
          ],
        );

      case RightPanelMode.payment:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Payment Method',
              style: FontUtility.heading.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  PaymentMethodCard(
                    title: 'Cash',
                    icon: Icons.money_rounded,
                    isSelected: state.selectedPaymentMethod == 'Cash',
                    onTap: () => _showPaymentConfirmation(context, state, 'Cash'),
                  ),
                  PaymentMethodCard(
                    title: 'Card',
                    icon: Icons.credit_card_rounded,
                    isSelected: state.selectedPaymentMethod == 'Card',
                    onTap: () => _showPaymentConfirmation(context, state, 'Card'),
                  ),
                  PaymentMethodCard(
                    title: 'UPI / Online',
                    icon: Icons.qr_code_scanner_rounded,
                    isSelected: state.selectedPaymentMethod == 'UPI',
                    onTap: () => _showPaymentConfirmation(context, state, 'UPI'),
                  ),
                  PaymentMethodCard(
                    title: 'Credit',
                    icon: Icons.account_balance_wallet_rounded,
                    isSelected: state.selectedPaymentMethod == 'Credit',
                    onTap: () => _showPaymentConfirmation(context, state, 'Credit'),
                  ),
                ],
              ),
            ),
          ],
        );
    }
  }
}
