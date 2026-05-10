import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/font_utility.dart';
import '../../bloc/cart/cart_bloc.dart';
import '../../bloc/cart/cart_event.dart';
import '../../bloc/cart/cart_state.dart';
import '../widgets/category_card.dart';
import '../widgets/product_item_card.dart';
import '../widgets/cart_item_tile.dart';
import '../widgets/order_summary_widget.dart';
import '../widgets/checkout_tab_bar.dart';
import '../widgets/checkout_footer_buttons.dart';
import '../widgets/order_history_card.dart';
import 'billing_summary_screen.dart';

class OrderCreateScreenArgs {
  final String orderType; // 'Pickup' or 'DineIn'
  final String? name;
  final String? phone;
  final String? floor;
  final String? table;

  OrderCreateScreenArgs({
    required this.orderType,
    this.name,
    this.phone,
    this.floor,
    this.table,
  });
}

class OrderCreateScreen extends StatelessWidget {
  final OrderCreateScreenArgs args;

  const OrderCreateScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CartBloc()..add(LoadInitialData()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'New ${args.orderType} Order',
                style: FontUtility.heading.copyWith(fontSize: 20),
              ),
              if (args.orderType == 'Pickup' && args.name != null)
                Text(
                  '${args.name} | ${args.phone}',
                  style: FontUtility.body.copyWith(fontSize: 12, color: Colors.grey.shade600),
                )
              else if (args.orderType == 'DineIn' && args.table != null)
                Text(
                  'Floor: ${args.floor} | Table: ${args.table}',
                  style: FontUtility.body.copyWith(fontSize: 12, color: Colors.grey.shade600),
                )
            ],
          ),
          centerTitle: false,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(
              color: Colors.grey.withOpacity(0.2),
              height: 1.0,
            ),
          ),
        ),
        body: SafeArea(
          child: Row(
            children: [
              // LEFT SIDE - PRODUCTS (65%)
              Expanded(
                flex: 65,
                child: _buildLeftPanel(),
              ),

              // RIGHT SIDE - CART (35%)
              Container(
                width: 1,
                color: Colors.grey.withOpacity(0.2),
              ),
              Expanded(
                flex: 35,
                child: _buildRightPanel(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeftPanel() {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Categories List
            Container(
              height: 80,
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: state.categories.length,
                itemBuilder: (context, index) {
                  final category = state.categories[index];
                  return CategoryCard(
                    category: category,
                    isSelected: state.selectedCategoryId == category.id,
                    onTap: () {
                      context.read<CartBloc>().add(SelectCategory(category.id));
                    },
                  );
                },
              ),
            ),
            
            // Products Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // Responsive count could be calculated here based on LayoutBuilder
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: state.filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = state.filteredProducts[index];
                    return ProductItemCard(
                      product: product,
                      onTap: () {
                        context.read<CartBloc>().add(AddProductToCart(product));
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRightPanel() {
    return Container(
      color: Colors.white,
      child: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          return Column(
            children: [
              // Top Section (Tabs + List) - 67% height
              Expanded(
                flex: 65,
                child: Column(
                  children: [
                    // Tabs
                    CheckoutTabBar(
                      isHistoryActive: state.isHistoryTabActive,
                      newOrderCount: state.totalItems,
                      onNewOrderTap: () {
                        context.read<CartBloc>().add(const ToggleCheckoutTab(false));
                      },
                      onHistoryTap: () {
                        context.read<CartBloc>().add(const ToggleCheckoutTab(true));
                      },
                    ),

                    // List Content
                    Expanded(
                      child: state.isHistoryTabActive
                          ? _buildHistoryList(state, context)
                          : _buildActiveCartList(state, context),
                    ),
                  ],
                ),
              ),

              // Summary Section - 22% height
              Expanded(
                flex: 26,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: Center(
                    child: OrderSummaryWidget(
                      subTotal: state.subTotal,
                      deliveryCharge: state.cartItems.isEmpty ? 0 : state.deliveryCharge,
                      netTotal: state.cartItems.isEmpty ? 0 : state.netTotal,
                    ),
                  ),
                ),
              ),

              // Footer Buttons Section - 11% height
              Expanded(
                flex: 11,
                child: CheckoutFooterButtons(
                  hasItems: state.cartItems.isNotEmpty && !state.isHistoryTabActive,
                  onKOT: () {
                    context.read<CartBloc>().add(SendToKOT());
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('KOT sent to kitchen'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  onBill: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (navContext) => BlocProvider.value(
                          value: context.read<CartBloc>(),
                          child: const BillingSummaryScreen(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActiveCartList(CartState state, BuildContext context) {
    if (state.cartItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Your cart is empty',
              style: FontUtility.subheading.copyWith(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: state.cartItems.length,
      itemBuilder: (context, index) {
        final item = state.cartItems[index];
        return CartItemTile(
          cartItem: item,
          onIncrease: () {
            context.read<CartBloc>().add(UpdateCartItemQuantity(item.product, item.quantity + 1));
          },
          onDecrease: () {
            context.read<CartBloc>().add(UpdateCartItemQuantity(item.product, item.quantity - 1));
          },
          onRemove: () {
            context.read<CartBloc>().add(RemoveProductFromCart(item.product));
          },
        );
      },
    );
  }

  Widget _buildHistoryList(CartState state, BuildContext context) {
    if (state.orderHistory.isEmpty) {
      return Column(
        children: [
          _buildHistoryHeader(context),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_rounded, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'No order history yet',
                    style: FontUtility.subheading.copyWith(color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        _buildHistoryHeader(context),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: state.orderHistory.length,
            itemBuilder: (context, index) {
              final order = state.orderHistory[index];
              return OrderHistoryCard(order: order);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Past Orders',
            style: FontUtility.subheading.copyWith(color: Colors.grey.shade700),
          ),
          IconButton(
            onPressed: () {
              // Optionally trigger a bloc event to reload history if it was from an API
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('History Refreshed')),
              );
            },
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF4A00E0)),
            tooltip: 'Refresh History',
          ),
        ],
      ),
    );
  }
}
