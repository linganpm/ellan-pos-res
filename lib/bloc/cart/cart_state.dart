import 'package:equatable/equatable.dart';
import '../../data/models/product_model.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/category_model.dart';
import '../../data/models/order_history_model.dart';

class CartState extends Equatable {
  final bool isLoading;
  final List<CategoryModel> categories;
  final List<Product> products;
  final String selectedCategoryId;
  final List<CartItem> cartItems;
  final double deliveryCharge;
  final List<OrderHistoryModel> orderHistory;
  final bool isHistoryTabActive;
  
  // Billing specific states
  final double discountPercentage;
  final double serviceTaxPercentage;
  final String? selectedPaymentMethod;

  const CartState({
    this.isLoading = true,
    this.categories = const [],
    this.products = const [],
    this.selectedCategoryId = 'all',
    this.cartItems = const [],
    this.deliveryCharge = 5.0, // Configurable default
    this.orderHistory = const [],
    this.isHistoryTabActive = false,
    this.discountPercentage = 0.0,
    this.serviceTaxPercentage = 0.0,
    this.selectedPaymentMethod,
  });

  List<Product> get filteredProducts {
    if (selectedCategoryId == 'all') {
      return products;
    }
    return products.where((p) => p.categoryId == selectedCategoryId).toList();
  }

  double get subTotal {
    return cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  double get baseTotal => subTotal > 0 ? subTotal + deliveryCharge : 0.0;
  
  double get discountValue => baseTotal * (discountPercentage / 100);
  
  double get serviceTaxValue => (baseTotal - discountValue) * (serviceTaxPercentage / 100);

  double get netTotal {
    if (subTotal == 0) return 0.0;
    return baseTotal - discountValue + serviceTaxValue;
  }
  
  int get totalItems {
    return cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  CartState copyWith({
    bool? isLoading,
    List<CategoryModel>? categories,
    List<Product>? products,
    String? selectedCategoryId,
    List<CartItem>? cartItems,
    double? deliveryCharge,
    List<OrderHistoryModel>? orderHistory,
    bool? isHistoryTabActive,
    double? discountPercentage,
    double? serviceTaxPercentage,
    String? selectedPaymentMethod,
  }) {
    return CartState(
      isLoading: isLoading ?? this.isLoading,
      categories: categories ?? this.categories,
      products: products ?? this.products,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      cartItems: cartItems ?? this.cartItems,
      deliveryCharge: deliveryCharge ?? this.deliveryCharge,
      orderHistory: orderHistory ?? this.orderHistory,
      isHistoryTabActive: isHistoryTabActive ?? this.isHistoryTabActive,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      serviceTaxPercentage: serviceTaxPercentage ?? this.serviceTaxPercentage,
      selectedPaymentMethod: selectedPaymentMethod ?? this.selectedPaymentMethod,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        categories,
        products,
        selectedCategoryId,
        cartItems,
        deliveryCharge,
        orderHistory,
        isHistoryTabActive,
        discountPercentage,
        serviceTaxPercentage,
        selectedPaymentMethod,
      ];
}
