import 'package:equatable/equatable.dart';
import '../../data/models/order_list_model.dart';

abstract class OrderListState extends Equatable {
  const OrderListState();

  @override
  List<Object?> get props => [];
}

class OrderListInitial extends OrderListState {}

class OrderListLoading extends OrderListState {}

class OrderListLoaded extends OrderListState {
  final List<OrderListModel> orders;
  final String selectedTypeFilter; // All, Dine In, Pickup, Delivery
  final String? selectedStatusFilter; // Status text, null if no status filter
  final String searchQuery;
  final bool hasReachedMax;
  final bool isFetchingMore;

  const OrderListLoaded({
    required this.orders,
    this.selectedTypeFilter = 'All',
    this.selectedStatusFilter,
    this.searchQuery = '',
    this.hasReachedMax = false,
    this.isFetchingMore = false,
  });

  OrderListLoaded copyWith({
    List<OrderListModel>? orders,
    String? selectedTypeFilter,
    String? selectedStatusFilter,
    String? searchQuery,
    bool? hasReachedMax,
    bool? isFetchingMore,
  }) {
    return OrderListLoaded(
      orders: orders ?? this.orders,
      selectedTypeFilter: selectedTypeFilter ?? this.selectedTypeFilter,
      selectedStatusFilter: selectedStatusFilter ?? this.selectedStatusFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
    );
  }

  @override
  List<Object?> get props => [
        orders,
        selectedTypeFilter,
        selectedStatusFilter,
        searchQuery,
        hasReachedMax,
        isFetchingMore,
      ];
}

class OrderListError extends OrderListState {
  final String message;

  const OrderListError(this.message);

  @override
  List<Object?> get props => [message];
}
