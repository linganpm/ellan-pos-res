import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/localization/l10n/app_localizations.dart';
import '../../core/utils/font_utility.dart';
import '../../bloc/order_list/order_list_bloc.dart';
import '../../bloc/order_list/order_list_event.dart';
import '../../bloc/order_list/order_list_state.dart';
import '../widgets/order_list/order_list_row.dart';

class OrderListScreen extends StatelessWidget {
  const OrderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OrderListBloc()..add(FetchInitialOrders()),
      child: const _OrderListScreenContent(),
    );
  }
}

class _OrderListScreenContent extends StatefulWidget {
  const _OrderListScreenContent();

  @override
  State<_OrderListScreenContent> createState() => _OrderListScreenContentState();
}

class _OrderListScreenContentState extends State<_OrderListScreenContent> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
      context.read<OrderListBloc>().add(FetchNextPage());
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<OrderListBloc>().add(SearchOrders(query));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.05),
        title: Text(
          AppLocalizations.of(context)!.homeOrdersList,
          style: FontUtility.heading.copyWith(fontSize: 22),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.black87),
            onPressed: () {
              context.read<OrderListBloc>().add(RefreshOrders());
            },
            tooltip: AppLocalizations.of(context)!.orderListRefreshButton,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTopFilters(context),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildTableHeader(context),
                      Expanded(child: _buildOrderList()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopFilters(BuildContext context) {
    return Row(
      children: [
        // Order Type Segmented Control
        BlocBuilder<OrderListBloc, OrderListState>(
          builder: (context, state) {
            String selectedType = 'All';
            if (state is OrderListLoaded) {
              selectedType = state.selectedTypeFilter;
            }

            return Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSegment(AppLocalizations.of(context)!.orderListFilterAll, 'All', selectedType == 'All'),
                  Container(width: 1, color: Colors.grey.withOpacity(0.2)),
                  _buildSegment(AppLocalizations.of(context)!.orderListFilterDineIn, 'Dine In', selectedType == 'Dine In'),
                  Container(width: 1, color: Colors.grey.withOpacity(0.2)),
                  _buildSegment(AppLocalizations.of(context)!.orderListFilterPickup, 'Pickup', selectedType == 'Pickup'),
                  Container(width: 1, color: Colors.grey.withOpacity(0.2)),
                  _buildSegment(AppLocalizations.of(context)!.orderListFilterDelivery, 'Delivery', selectedType == 'Delivery'),
                ],
              ),
            );
          },
        ),
        const Spacer(),
        // Search
        SizedBox(
          width: 300,
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.orderListSearchHint,
              hintStyle: FontUtility.body.copyWith(color: Colors.black38),
              prefixIcon: const Icon(Icons.search_rounded, color: Colors.black45),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear_rounded, color: Colors.black45, size: 20),
                onPressed: () {
                  _searchController.clear();
                  _onSearchChanged('');
                },
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF4A00E0)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Filter Button
        BlocBuilder<OrderListBloc, OrderListState>(
          builder: (context, state) {
            String? statusFilter;
            if (state is OrderListLoaded) {
              statusFilter = state.selectedStatusFilter;
            }

            return PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'Clear') {
                  context.read<OrderListBloc>().add(ClearStatusFilter());
                } else {
                  context.read<OrderListBloc>().add(FilterByStatus(value));
                }
              },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: statusFilter != null ? const Color(0xFF4A00E0).withOpacity(0.1) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: statusFilter != null ? const Color(0xFF4A00E0) : Colors.grey.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.filter_list_rounded,
                      color: statusFilter != null ? const Color(0xFF4A00E0) : Colors.black87,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.orderListFilterButton,
                      style: FontUtility.body.copyWith(
                        color: statusFilter != null ? const Color(0xFF4A00E0) : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'Clear', child: Text('Clear Filter')),
                const PopupMenuDivider(),
                const PopupMenuItem(value: 'Order Pending', child: Text('Order Pending')),
                const PopupMenuItem(value: 'Order Preparing', child: Text('Order Preparing')),
                const PopupMenuItem(value: 'Ready To Serve', child: Text('Ready To Serve')),
                const PopupMenuItem(value: 'Completed', child: Text('Completed')),
                const PopupMenuItem(value: 'Cancelled', child: Text('Cancelled')),
                const PopupMenuItem(value: 'Order Delivered', child: Text('Order Delivered')),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildSegment(String title, String value, bool isSelected) {
    return InkWell(
      onTap: () {
        context.read<OrderListBloc>().add(FilterByType(value));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4A00E0) : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Text(
          title,
          style: FontUtility.body.copyWith(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeader(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.2))),
      ),
      child: Row(
        children: [
          Expanded(flex: 1, child: _headerText(loc.orderListColumnSlNo)),
          Expanded(flex: 2, child: _headerText(loc.orderListColumnOrderId)),
          Expanded(flex: 2, child: _headerText(loc.orderListColumnOrderType)),
          Expanded(flex: 3, child: _headerText(loc.orderListColumnName)),
          Expanded(flex: 2, child: _headerText(loc.orderListColumnTime)),
          Expanded(flex: 2, child: _headerText(loc.orderListColumnStatus)),
          Expanded(flex: 2, child: _headerText(loc.orderListColumnPayment)),
          Expanded(flex: 1, child: _headerText(loc.orderListColumnItems, textAlign: TextAlign.center)),
          Expanded(flex: 2, child: _headerText(loc.orderListColumnTotal, textAlign: TextAlign.right)),
          Expanded(flex: 2, child: _headerText(loc.orderListColumnActions, textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _headerText(String text, {TextAlign textAlign = TextAlign.left}) {
    return Text(
      text,
      textAlign: textAlign,
      style: FontUtility.body.copyWith(
        fontWeight: FontWeight.w600,
        color: Colors.black54,
        fontSize: 13,
      ),
    );
  }

  Widget _buildOrderList() {
    return BlocBuilder<OrderListBloc, OrderListState>(
      builder: (context, state) {
        if (state is OrderListLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF4A00E0)),
          );
        } else if (state is OrderListError) {
          return Center(
            child: Text(state.message, style: FontUtility.body.copyWith(color: Colors.red)),
          );
        } else if (state is OrderListLoaded) {
          if (state.orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_rounded, size: 64, color: Colors.grey.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text(
                    'No orders found',
                    style: FontUtility.subheading.copyWith(color: Colors.black54),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            itemCount: state.orders.length + (state.isFetchingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= state.orders.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF4A00E0), strokeWidth: 3),
                  ),
                );
              }

              final order = state.orders[index];
              return OrderListRow(
                order: order,
                index: index,
                onInfoTap: () {
                  // Navigate to Order Details
                },
                onPrintTap: () {
                  _showPrintDialog(context, order.orderId);
                },
                onUpdateTap: () {
                  _showUpdateStatusDialog(context, order.orderId, order.orderStatus);
                },
                onPayNowTap: () {
                  // Handle Pay Now
                },
              );
            },
          );
        }
        return const SizedBox();
      },
    );
  }

  void _showPrintDialog(BuildContext context, String orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Print Invoice', style: FontUtility.heading.copyWith(fontSize: 20)),
        content: Text('Print invoice for Order #$orderId?', style: FontUtility.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: FontUtility.button.copyWith(color: Colors.black54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A00E0),
              foregroundColor: Colors.white,
            ),
            child: Text('Print', style: FontUtility.button.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showUpdateStatusDialog(BuildContext context, String orderId, String currentStatus) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Update Status', style: FontUtility.heading.copyWith(fontSize: 20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select new status for Order #$orderId:', style: FontUtility.body),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'Order Pending',
                'Order Preparing',
                'Ready To Serve',
                'Completed',
                'Cancelled',
              ].map((status) {
                final isSelected = status == currentStatus;
                return ChoiceChip(
                  label: Text(status),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      context.read<OrderListBloc>().add(
                            UpdateOrderStatus(orderId: orderId, newStatus: status),
                          );
                      Navigator.pop(dialogContext);
                    }
                  },
                  selectedColor: const Color(0xFF4A00E0).withOpacity(0.1),
                  labelStyle: FontUtility.body.copyWith(
                    color: isSelected ? const Color(0xFF4A00E0) : Colors.black87,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: FontUtility.button.copyWith(color: Colors.black54)),
          ),
        ],
      ),
    );
  }
}
