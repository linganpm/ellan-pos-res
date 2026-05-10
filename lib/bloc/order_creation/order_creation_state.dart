import 'package:equatable/equatable.dart';
import 'order_creation_event.dart';

class OrderCreationState extends Equatable {
  final OrderType orderType;
  final String pickupName;
  final String pickupPhone;
  final String selectedFloor;
  final String selectedTable;
  final bool isPickupValid;
  final String? nameError;
  final String? phoneError;

  const OrderCreationState({
    this.orderType = OrderType.pickup,
    this.pickupName = '',
    this.pickupPhone = '',
    this.selectedFloor = 'first',
    this.selectedTable = '',
    this.isPickupValid = false,
    this.nameError,
    this.phoneError,
  });

  OrderCreationState copyWith({
    OrderType? orderType,
    String? pickupName,
    String? pickupPhone,
    String? selectedFloor,
    String? selectedTable,
    bool? isPickupValid,
    String? nameError,
    String? phoneError,
  }) {
    return OrderCreationState(
      orderType: orderType ?? this.orderType,
      pickupName: pickupName ?? this.pickupName,
      pickupPhone: pickupPhone ?? this.pickupPhone,
      selectedFloor: selectedFloor ?? this.selectedFloor,
      selectedTable: selectedTable ?? this.selectedTable,
      isPickupValid: isPickupValid ?? this.isPickupValid,
      nameError: nameError,
      phoneError: phoneError,
    );
  }

  @override
  List<Object?> get props => [
        orderType,
        pickupName,
        pickupPhone,
        selectedFloor,
        selectedTable,
        isPickupValid,
        nameError,
        phoneError,
      ];
}
