import 'package:flutter/material.dart';
import '../../../core/utils/font_utility.dart';
import '../../../data/models/cart_item_model.dart';

class BillingItemsTable extends StatelessWidget {
  final List<CartItem> items;

  const BillingItemsTable({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Expanded(flex: 1, child: Text('Qty', style: FontUtility.subheading.copyWith(color: Colors.grey.shade700))),
                Expanded(flex: 4, child: Text('Item', style: FontUtility.subheading.copyWith(color: Colors.grey.shade700))),
                Expanded(flex: 2, child: Text('Price', textAlign: TextAlign.right, style: FontUtility.subheading.copyWith(color: Colors.grey.shade700))),
              ],
            ),
          ),
          // Items
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade100),
            itemBuilder: (context, index) {
              final item = items[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        '${item.quantity}x',
                        style: FontUtility.subheading.copyWith(fontSize: 16),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          item.product.name,
                          style: FontUtility.body.copyWith(fontSize: 16),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '\$${item.totalPrice.toStringAsFixed(2)}',
                        textAlign: TextAlign.right,
                        style: FontUtility.subheading.copyWith(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
