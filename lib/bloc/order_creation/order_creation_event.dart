import 'package:equatable/equatable.dart';

enum OrderType { pickup, dineIn }

abstract class OrderCreationEvent extends Equatable {
  const OrderCreationEvent();

  @override
  List<Object?> get props => [];
}

class SelectOrderType extends OrderCreationEvent {
  final OrderType type;
  const SelectOrderType(this.type);

  @override
  List<Object?> get props => [type];
}

class UpdatePickupDetails extends OrderCreationEvent {
  final String name;
  final String phone;

  const UpdatePickupDetails({required this.name, required this.phone});

  @override
  List<Object?> get props => [name, phone];
}

class SelectDineInFloor extends OrderCreationEvent {
  final String floor;
  const SelectDineInFloor(this.floor);

  @override
  List<Object?> get props => [floor];
}

class SelectDineInTable extends OrderCreationEvent {
  final String tableNumber;
  const SelectDineInTable(this.tableNumber);

  @override
  List<Object?> get props => [tableNumber];
}

class ValidatePickupForm extends OrderCreationEvent {}

class ResetOrderCreation extends OrderCreationEvent {}
