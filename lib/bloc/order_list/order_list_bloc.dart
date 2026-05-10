import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'order_list_event.dart';
import 'order_list_state.dart';
import '../../data/models/order_list_model.dart';

class OrderListBloc extends Bloc<OrderListEvent, OrderListState> {
  static const int _pageSize = 10;
  List<OrderListModel> _allMockOrders = [];

  OrderListBloc() : super(OrderListInitial()) {
    on<FetchInitialOrders>(_onFetchInitialOrders);
    on<FetchNextPage>(_onFetchNextPage);
    on<FilterByType>(_onFilterByType);
    on<FilterByStatus>(_onFilterByStatus);
    on<ClearStatusFilter>(_onClearStatusFilter);
    on<SearchOrders>(_onSearchOrders);
    on<RefreshOrders>(_onRefreshOrders);
    on<UpdateOrderStatus>(_onUpdateOrderStatus);

    _generateMockData();
  }

  void _generateMockData() {
    final types = ['Dine In', 'Pickup', 'Delivery'];
    final statuses = [
      'Completed',
      'Order Pending',
      'Order Preparing',
      'Cancelled',
      'Order Delivered',
      'Ready To Serve',
    ];
    
    _allMockOrders = List.generate(50, (index) {
      final type = types[index % types.length];
      final isPaid = index % 3 != 0; // 2/3 probability of being paid

      return OrderListModel(
        id: 'db_id_$index',
        orderId: '1000${index + 1}',
        orderType: type,
        floorName: type == 'Dine In' ? (index % 2 == 0 ? 'First Floor' : 'Second Floor') : null,
        tableNumber: type == 'Dine In' ? '${(index % 10) + 1}' : null,
        customerName: 'Customer ${index + 1}',
        phoneNumber: '9876543210',
        timestamp: DateTime.now().subtract(Duration(minutes: index * 15)),
        orderStatus: statuses[index % statuses.length],
        paymentStatus: isPaid ? 'Paid' : 'Unpaid',
        itemCount: (index % 5) + 1,
        totalAmount: ((index % 10) + 1) * 15.5,
      );
    });
  }

  Future<void> _onFetchInitialOrders(
    FetchInitialOrders event,
    Emitter<OrderListState> emit,
  ) async {
    emit(OrderListLoading());
    try {
      await Future.delayed(const Duration(milliseconds: 800)); // Simulate API delay
      final initialData = _applyFiltersAndPagination('All', null, '', 0);
      emit(OrderListLoaded(
        orders: initialData,
        hasReachedMax: initialData.length < _pageSize,
      ));
    } catch (e) {
      emit(const OrderListError('Failed to fetch orders.'));
    }
  }

  Future<void> _onFetchNextPage(
    FetchNextPage event,
    Emitter<OrderListState> emit,
  ) async {
    if (state is OrderListLoaded) {
      final currentState = state as OrderListLoaded;
      if (currentState.hasReachedMax || currentState.isFetchingMore) return;

      emit(currentState.copyWith(isFetchingMore: true));
      try {
        await Future.delayed(const Duration(milliseconds: 800)); // Simulate API delay
        final currentLength = currentState.orders.length;
        
        final moreData = _applyFiltersAndPagination(
          currentState.selectedTypeFilter,
          currentState.selectedStatusFilter,
          currentState.searchQuery,
          currentLength,
        );

        emit(moreData.isEmpty
            ? currentState.copyWith(hasReachedMax: true, isFetchingMore: false)
            : currentState.copyWith(
                orders: List.of(currentState.orders)..addAll(moreData),
                hasReachedMax: moreData.length < _pageSize,
                isFetchingMore: false,
              ));
      } catch (e) {
        emit(currentState.copyWith(isFetchingMore: false));
      }
    }
  }

  Future<void> _onFilterByType(
    FilterByType event,
    Emitter<OrderListState> emit,
  ) async {
    if (state is OrderListLoaded) {
      final currentState = state as OrderListLoaded;
      emit(OrderListLoading());
      
      await Future.delayed(const Duration(milliseconds: 300));
      final filteredData = _applyFiltersAndPagination(
        event.type,
        currentState.selectedStatusFilter,
        currentState.searchQuery,
        0,
      );

      emit(OrderListLoaded(
        orders: filteredData,
        selectedTypeFilter: event.type,
        selectedStatusFilter: currentState.selectedStatusFilter,
        searchQuery: currentState.searchQuery,
        hasReachedMax: filteredData.length < _pageSize,
      ));
    }
  }

  Future<void> _onFilterByStatus(
    FilterByStatus event,
    Emitter<OrderListState> emit,
  ) async {
    if (state is OrderListLoaded) {
      final currentState = state as OrderListLoaded;
      emit(OrderListLoading());
      
      await Future.delayed(const Duration(milliseconds: 300));
      final filteredData = _applyFiltersAndPagination(
        currentState.selectedTypeFilter,
        event.status,
        currentState.searchQuery,
        0,
      );

      emit(OrderListLoaded(
        orders: filteredData,
        selectedTypeFilter: currentState.selectedTypeFilter,
        selectedStatusFilter: event.status,
        searchQuery: currentState.searchQuery,
        hasReachedMax: filteredData.length < _pageSize,
      ));
    }
  }

  Future<void> _onClearStatusFilter(
    ClearStatusFilter event,
    Emitter<OrderListState> emit,
  ) async {
    if (state is OrderListLoaded) {
      final currentState = state as OrderListLoaded;
      if (currentState.selectedStatusFilter == null) return;

      emit(OrderListLoading());
      await Future.delayed(const Duration(milliseconds: 300));
      
      final filteredData = _applyFiltersAndPagination(
        currentState.selectedTypeFilter,
        null,
        currentState.searchQuery,
        0,
      );

      emit(OrderListLoaded(
        orders: filteredData,
        selectedTypeFilter: currentState.selectedTypeFilter,
        selectedStatusFilter: null,
        searchQuery: currentState.searchQuery,
        hasReachedMax: filteredData.length < _pageSize,
      ));
    }
  }

  Future<void> _onSearchOrders(
    SearchOrders event,
    Emitter<OrderListState> emit,
  ) async {
    if (state is OrderListLoaded) {
      final currentState = state as OrderListLoaded;
      emit(OrderListLoading());
      
      await Future.delayed(const Duration(milliseconds: 300));
      final filteredData = _applyFiltersAndPagination(
        currentState.selectedTypeFilter,
        currentState.selectedStatusFilter,
        event.query,
        0,
      );

      emit(OrderListLoaded(
        orders: filteredData,
        selectedTypeFilter: currentState.selectedTypeFilter,
        selectedStatusFilter: currentState.selectedStatusFilter,
        searchQuery: event.query,
        hasReachedMax: filteredData.length < _pageSize,
      ));
    }
  }

  Future<void> _onRefreshOrders(
    RefreshOrders event,
    Emitter<OrderListState> emit,
  ) async {
    if (state is OrderListLoaded) {
      final currentState = state as OrderListLoaded;
      emit(OrderListLoading());
      
      // Optionally re-generate mock data here
      _generateMockData();
      
      await Future.delayed(const Duration(milliseconds: 800));
      final refreshedData = _applyFiltersAndPagination(
        currentState.selectedTypeFilter,
        currentState.selectedStatusFilter,
        currentState.searchQuery,
        0,
      );

      emit(OrderListLoaded(
        orders: refreshedData,
        selectedTypeFilter: currentState.selectedTypeFilter,
        selectedStatusFilter: currentState.selectedStatusFilter,
        searchQuery: currentState.searchQuery,
        hasReachedMax: refreshedData.length < _pageSize,
      ));
    } else {
      add(FetchInitialOrders());
    }
  }

  Future<void> _onUpdateOrderStatus(
    UpdateOrderStatus event,
    Emitter<OrderListState> emit,
  ) async {
    if (state is OrderListLoaded) {
      final currentState = state as OrderListLoaded;
      
      // Update the mock database
      final orderIndex = _allMockOrders.indexWhere((o) => o.orderId == event.orderId);
      if (orderIndex != -1) {
        final order = _allMockOrders[orderIndex];
        _allMockOrders[orderIndex] = OrderListModel(
          id: order.id,
          orderId: order.orderId,
          orderType: order.orderType,
          floorName: order.floorName,
          tableNumber: order.tableNumber,
          customerName: order.customerName,
          phoneNumber: order.phoneNumber,
          timestamp: order.timestamp,
          orderStatus: event.newStatus,
          paymentStatus: order.paymentStatus,
          itemCount: order.itemCount,
          totalAmount: order.totalAmount,
        );
      }

      // Re-apply filters for the current view
      final updatedData = _applyFiltersAndPagination(
        currentState.selectedTypeFilter,
        currentState.selectedStatusFilter,
        currentState.searchQuery,
        0,
        limit: currentState.orders.length, // keep the same number of items loaded
      );

      emit(currentState.copyWith(orders: updatedData));
    }
  }

  List<OrderListModel> _applyFiltersAndPagination(
    String typeFilter,
    String? statusFilter,
    String searchQuery,
    int skip, {
    int limit = _pageSize,
  }) {
    var filtered = _allMockOrders;

    if (typeFilter != 'All') {
      filtered = filtered.where((o) => o.orderType == typeFilter).toList();
    }

    if (statusFilter != null && statusFilter.isNotEmpty) {
      filtered = filtered.where((o) => o.orderStatus == statusFilter).toList();
    }

    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((o) => 
        o.orderId.toLowerCase().contains(query) ||
        o.customerName.toLowerCase().contains(query) ||
        (o.phoneNumber?.toLowerCase().contains(query) ?? false)
      ).toList();
    }

    return filtered.skip(skip).take(limit).toList();
  }
}
