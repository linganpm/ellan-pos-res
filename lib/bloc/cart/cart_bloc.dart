import 'package:flutter_bloc/flutter_bloc.dart';
import 'cart_event.dart';
import 'cart_state.dart';
import '../../data/models/product_model.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/category_model.dart';
import '../../data/models/order_history_model.dart';
import 'dart:math';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState()) {
    on<LoadInitialData>(_onLoadInitialData);
    on<SelectCategory>(_onSelectCategory);
    on<AddProductToCart>(_onAddProductToCart);
    on<UpdateCartItemQuantity>(_onUpdateCartItemQuantity);
    on<RemoveProductFromCart>(_onRemoveProductFromCart);
    on<ClearCart>(_onClearCart);
    on<ToggleCheckoutTab>(_onToggleCheckoutTab);
    on<SendToKOT>(_onSendToKOT);
    on<ApplyDiscount>(_onApplyDiscount);
    on<RemoveDiscount>(_onRemoveDiscount);
    on<ApplyServiceTax>(_onApplyServiceTax);
    on<RemoveServiceTax>(_onRemoveServiceTax);
    on<SelectPaymentMethod>(_onSelectPaymentMethod);
  }

  void _onLoadInitialData(LoadInitialData event, Emitter<CartState> emit) async {
    emit(state.copyWith(isLoading: true));

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Dummy Categories
    final categories = [
      const CategoryModel(id: 'all', name: 'All Items', imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=200&h=200&fit=crop'),
      const CategoryModel(id: 'burger', name: 'Burgers', imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=200&h=200&fit=crop'),
      const CategoryModel(id: 'pizza', name: 'Pizza', imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=200&h=200&fit=crop'),
      const CategoryModel(id: 'drinks', name: 'Drinks', imageUrl: 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=200&h=200&fit=crop'),
      const CategoryModel(id: 'dessert', name: 'Desserts', imageUrl: 'https://images.unsplash.com/photo-1551024506-0baa27542c81?w=200&h=200&fit=crop'),
    ];

    // Dummy Products
    final products = [
      const Product(
        id: '1',
        name: 'Classic Cheeseburger',
        description: 'Juicy beef patty with cheese, lettuce, and tomato.',
        price: 8.99,
        imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&h=400&fit=crop',
        categoryId: 'burger',
        offerTag: 'Best Seller',
      ),
      const Product(
        id: '2',
        name: 'Double Bacon Burger',
        description: 'Two beef patties, crispy bacon, and BBQ sauce.',
        price: 12.99,
        imageUrl: 'https://images.unsplash.com/photo-1594212887874-ce444005cbb6?w=400&h=400&fit=crop',
        categoryId: 'burger',
      ),
      const Product(
        id: '3',
        name: 'Margherita Pizza',
        description: 'Classic pizza with tomato sauce and mozzarella.',
        price: 14.50,
        imageUrl: 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=400&h=400&fit=crop',
        categoryId: 'pizza',
        offerTag: '15% OFF',
      ),
      const Product(
        id: '4',
        name: 'Pepperoni Pizza',
        description: 'Topped with spicy pepperoni and mozzarella cheese.',
        price: 16.50,
        imageUrl: 'https://images.unsplash.com/photo-1628840042765-356cda07504e?w=400&h=400&fit=crop',
        categoryId: 'pizza',
      ),
      const Product(
        id: '5',
        name: 'Coke',
        description: 'Chilled 500ml Coca-Cola.',
        price: 2.50,
        imageUrl: 'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=400&h=400&fit=crop',
        categoryId: 'drinks',
      ),
      const Product(
        id: '6',
        name: 'Chocolate Lava Cake',
        description: 'Warm chocolate cake with a gooey center.',
        price: 6.99,
        imageUrl: 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=400&h=400&fit=crop',
        categoryId: 'dessert',
      ),
      const Product(
        id: '7',
        name: 'French Fries',
        description: 'Crispy golden fries with a side of ketchup.',
        price: 4.50,
        imageUrl: 'https://images.unsplash.com/photo-1576107232684-1279f3908594?w=400&h=400&fit=crop',
        categoryId: 'burger', // Just putting it in burger category for dummy
      ),
    ];

    emit(state.copyWith(
      isLoading: false,
      categories: categories,
      products: products,
      selectedCategoryId: 'all',
    ));
  }

  void _onSelectCategory(SelectCategory event, Emitter<CartState> emit) {
    emit(state.copyWith(selectedCategoryId: event.categoryId));
  }

  void _onAddProductToCart(AddProductToCart event, Emitter<CartState> emit) {
    final updatedCart = List<CartItem>.from(state.cartItems);
    final existingIndex = updatedCart.indexWhere((item) => item.product.id == event.product.id);

    if (existingIndex >= 0) {
      // Increase quantity if item already exists
      final existingItem = updatedCart[existingIndex];
      updatedCart[existingIndex] = existingItem.copyWith(quantity: existingItem.quantity + 1);
    } else {
      // Add new item
      updatedCart.add(CartItem(product: event.product));
    }

    emit(state.copyWith(cartItems: updatedCart));
  }

  void _onUpdateCartItemQuantity(UpdateCartItemQuantity event, Emitter<CartState> emit) {
    final updatedCart = List<CartItem>.from(state.cartItems);
    final index = updatedCart.indexWhere((item) => item.product.id == event.product.id);

    if (index >= 0) {
      if (event.quantity <= 0) {
        updatedCart.removeAt(index);
      } else {
        updatedCart[index] = updatedCart[index].copyWith(quantity: event.quantity);
      }
      emit(state.copyWith(cartItems: updatedCart));
    }
  }

  void _onRemoveProductFromCart(RemoveProductFromCart event, Emitter<CartState> emit) {
    final updatedCart = List<CartItem>.from(state.cartItems);
    updatedCart.removeWhere((item) => item.product.id == event.product.id);
    emit(state.copyWith(cartItems: updatedCart));
  }

  void _onClearCart(ClearCart event, Emitter<CartState> emit) {
    emit(state.copyWith(cartItems: const []));
  }

  void _onToggleCheckoutTab(ToggleCheckoutTab event, Emitter<CartState> emit) {
    emit(state.copyWith(isHistoryTabActive: event.isHistoryActive));
  }

  void _onSendToKOT(SendToKOT event, Emitter<CartState> emit) {
    if (state.cartItems.isEmpty) return;

    final newHistoryItem = OrderHistoryModel(
      id: '#KOT-${Random().nextInt(99999).toString().padLeft(5, '0')}',
      items: List.from(state.cartItems),
      totalAmount: state.netTotal,
      timestamp: DateTime.now(),
    );

    final updatedHistory = List<OrderHistoryModel>.from(state.orderHistory)..insert(0, newHistoryItem);

    emit(state.copyWith(
      cartItems: const [], // clear cart
      orderHistory: updatedHistory,
      isHistoryTabActive: true, // switch to history tab automatically on success
      discountPercentage: 0.0, // reset billing states
      serviceTaxPercentage: 0.0,
      selectedPaymentMethod: null,
    ));
  }

  void _onApplyDiscount(ApplyDiscount event, Emitter<CartState> emit) {
    if (event.percentage > 0 && event.percentage <= 100) {
      emit(state.copyWith(discountPercentage: event.percentage));
    }
  }

  void _onRemoveDiscount(RemoveDiscount event, Emitter<CartState> emit) {
    emit(state.copyWith(discountPercentage: 0.0));
  }

  void _onApplyServiceTax(ApplyServiceTax event, Emitter<CartState> emit) {
    if (event.percentage > 0 && event.percentage <= 100) {
      emit(state.copyWith(serviceTaxPercentage: event.percentage));
    }
  }

  void _onRemoveServiceTax(RemoveServiceTax event, Emitter<CartState> emit) {
    emit(state.copyWith(serviceTaxPercentage: 0.0));
  }

  void _onSelectPaymentMethod(SelectPaymentMethod event, Emitter<CartState> emit) {
    emit(state.copyWith(selectedPaymentMethod: event.method));
  }
}
