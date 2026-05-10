class OrderListModel {
  final String id;
  final String orderId;
  final String orderType; // Dine In, Pickup, Delivery
  final String? floorName;
  final String? tableNumber;
  final String customerName;
  final String? phoneNumber;
  final DateTime timestamp;
  final String orderStatus;
  final String paymentStatus; // Paid, Unpaid
  final int itemCount;
  final double totalAmount;

  const OrderListModel({
    required this.id,
    required this.orderId,
    required this.orderType,
    this.floorName,
    this.tableNumber,
    required this.customerName,
    this.phoneNumber,
    required this.timestamp,
    required this.orderStatus,
    required this.paymentStatus,
    required this.itemCount,
    required this.totalAmount,
  });

  // Helper method for Dine In
  bool get isDineIn => orderType == 'Dine In';

  // Helper method to get formatted table name
  String get formattedTableInfo {
    if (isDineIn && floorName != null && tableNumber != null) {
      return '$floorName - Table $tableNumber';
    }
    return '';
  }
}
