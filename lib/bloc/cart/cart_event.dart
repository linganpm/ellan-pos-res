import 'package:equatable/equatable.dart';
import '../../data/models/product_model.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object> get props => [];
}

class LoadInitialData extends CartEvent {}

class SelectCategory extends CartEvent {
  final String categoryId;

  const SelectCategory(this.categoryId);

  @override
  List<Object> get props => [categoryId];
}

class AddProductToCart extends CartEvent {
  final Product product;

  const AddProductToCart(this.product);

  @override
  List<Object> get props => [product];
}

class UpdateCartItemQuantity extends CartEvent {
  final Product product;
  final int quantity;

  const UpdateCartItemQuantity(this.product, this.quantity);

  @override
  List<Object> get props => [product, quantity];
}

class RemoveProductFromCart extends CartEvent {
  final Product product;

  const RemoveProductFromCart(this.product);

  @override
  List<Object> get props => [product];
}

class ClearCart extends CartEvent {}

class ToggleCheckoutTab extends CartEvent {
  final bool isHistoryActive;

  const ToggleCheckoutTab(this.isHistoryActive);

  @override
  List<Object> get props => [isHistoryActive];
}

class SendToKOT extends CartEvent {}

class ApplyDiscount extends CartEvent {
  final double percentage;
  const ApplyDiscount(this.percentage);
  @override
  List<Object> get props => [percentage];
}

class RemoveDiscount extends CartEvent {}

class ApplyServiceTax extends CartEvent {
  final double percentage;
  const ApplyServiceTax(this.percentage);
  @override
  List<Object> get props => [percentage];
}

class RemoveServiceTax extends CartEvent {}

class SelectPaymentMethod extends CartEvent {
  final String method;
  const SelectPaymentMethod(this.method);
  @override
  List<Object> get props => [method];
}
