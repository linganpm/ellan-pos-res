import 'package:flutter/material.dart';
import '../../../core/utils/font_utility.dart';

class OrderStatusBadge extends StatelessWidget {
  final String status;
  final bool isPaymentStatus;

  const OrderStatusBadge({
    super.key,
    required this.status,
    this.isPaymentStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    final lowerStatus = status.toLowerCase();

    if (lowerStatus.contains('completed') || 
        lowerStatus.contains('paid') || 
        lowerStatus.contains('ready to serve') ||
        lowerStatus.contains('served')) {
      backgroundColor = Colors.green.withOpacity(0.15);
      textColor = Colors.green.shade700;
    } else if (lowerStatus.contains('pending') || 
               lowerStatus.contains('preparing') ||
               lowerStatus.contains('cooking') ||
               lowerStatus.contains('initiated')) {
      backgroundColor = Colors.orange.withOpacity(0.15);
      textColor = Colors.orange.shade800;
    } else if (lowerStatus.contains('cancelled') || 
               lowerStatus.contains('returned') ||
               lowerStatus.contains('failed') ||
               lowerStatus.contains('wrong') ||
               lowerStatus.contains('unpaid')) {
      backgroundColor = Colors.red.withOpacity(0.15);
      textColor = Colors.red.shade700;
    } else if (lowerStatus.contains('delivery') || 
               lowerStatus.contains('shipped') ||
               lowerStatus.contains('shipping') ||
               lowerStatus.contains('way') ||
               lowerStatus.contains('driver')) {
      backgroundColor = Colors.blue.withOpacity(0.15);
      textColor = Colors.blue.shade700;
    } else {
      backgroundColor = Colors.grey.withOpacity(0.15);
      textColor = Colors.grey.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textColor.withOpacity(0.3), width: 1),
      ),
      child: Text(
        status,
        style: FontUtility.body.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
