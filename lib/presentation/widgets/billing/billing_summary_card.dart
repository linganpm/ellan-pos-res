import 'package:flutter/material.dart';
import '../../../core/utils/font_utility.dart';

class BillingSummaryCard extends StatelessWidget {
  final double subTotal;
  final double deliveryCharge;
  final double discountValue;
  final double discountPercentage;
  final double serviceTaxValue;
  final double serviceTaxPercentage;
  final double netTotal;

  const BillingSummaryCard({
    super.key,
    required this.subTotal,
    required this.deliveryCharge,
    required this.discountValue,
    required this.discountPercentage,
    required this.serviceTaxValue,
    required this.serviceTaxPercentage,
    required this.netTotal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildRow('Subtotal', '\$${subTotal.toStringAsFixed(2)}'),
          const SizedBox(height: 12),
          _buildRow('Delivery Charge', '\$${deliveryCharge.toStringAsFixed(2)}'),
          
          if (discountPercentage > 0) ...[
            const SizedBox(height: 12),
            _buildRow('Discount (${discountPercentage.toStringAsFixed(1)}%)', '-\$${discountValue.toStringAsFixed(2)}', color: Colors.green.shade700),
          ],
          
          if (serviceTaxPercentage > 0) ...[
            const SizedBox(height: 12),
            _buildRow('Service Tax (${serviceTaxPercentage.toStringAsFixed(1)}%)', '+\$${serviceTaxValue.toStringAsFixed(2)}', color: Colors.orange.shade700),
          ],
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(thickness: 1.5),
          ),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Net Total',
                style: FontUtility.heading.copyWith(fontSize: 24, color: Colors.black87),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A00E0).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '\$${netTotal.toStringAsFixed(2)}',
                  style: FontUtility.heading.copyWith(
                    fontSize: 28,
                    color: const Color(0xFF4A00E0),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String title, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: FontUtility.body.copyWith(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: FontUtility.subheading.copyWith(
            fontSize: 16,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}
