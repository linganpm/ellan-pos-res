import 'package:flutter/material.dart';
import '../../core/utils/font_utility.dart';

class OrderSummaryWidget extends StatelessWidget {
  final double subTotal;
  final double deliveryCharge;
  final double netTotal;

  const OrderSummaryWidget({
    super.key,
    required this.subTotal,
    required this.deliveryCharge,
    required this.netTotal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Sub Total', '\$${subTotal.toStringAsFixed(2)}'),
          const SizedBox(height: 12),
          _buildSummaryRow('Delivery Charge', '\$${deliveryCharge.toStringAsFixed(2)}'),
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Net Total',
                style: FontUtility.heading.copyWith(fontSize: 18),
              ),
              Text(
                '\$${netTotal.toStringAsFixed(2)}',
                style: FontUtility.heading.copyWith(
                  fontSize: 24,
                  color: const Color(0xFF4A00E0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: FontUtility.body.copyWith(
            color: Colors.grey.shade700,
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: FontUtility.subheading.copyWith(fontSize: 16),
        ),
      ],
    );
  }
}
