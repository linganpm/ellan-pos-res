import 'cart_item_model.dart';

class OrderHistoryModel {
  final String id;
  final List<CartItem> items;
  final double totalAmount;
  final DateTime timestamp;

  const OrderHistoryModel({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.timestamp,
  });
}
