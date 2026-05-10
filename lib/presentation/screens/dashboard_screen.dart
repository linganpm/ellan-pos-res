import 'package:flutter/material.dart';
import '../../core/localization/l10n/app_localizations.dart';
import '../../core/utils/font_utility.dart';
import '../widgets/dashboard/overview_card.dart';
import '../widgets/dashboard/sales_chart.dart';
import '../widgets/dashboard/top_items_list.dart';
import '../widgets/dashboard/payment_types_chart.dart';
import '../widgets/dashboard/credit_orders_table.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedFilter = 'Today';
  final List<String> _filters = ['Yesterday', 'Today', 'This Week', 'This Month', 'This Year'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildFilterSection(),
                const SizedBox(height: 24),
                _buildDashboardContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: Text(
        AppLocalizations.of(context)!.dashboardTitle,
        style: FontUtility.heading.copyWith(fontSize: 24),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
        onPressed: () => Navigator.pop(context),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: Colors.grey.withOpacity(0.2),
          height: 1.0,
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: _filters.map((filter) {
        final isSelected = _selectedFilter == filter;
        return Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedFilter = filter;
              });
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF4A00E0) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.grey.shade300,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF4A00E0).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [],
              ),
              child: Text(
                _getLocalizedFilter(context, filter),
                style: FontUtility.body.copyWith(
                  color: isSelected ? Colors.white : Colors.black54,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDashboardContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildOverviewMetrics(),
        const SizedBox(height: 32),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child: SizedBox(
                height: 420,
                child: SalesChart(filterSelected: _selectedFilter),
              ),
            ),
            const SizedBox(width: 24),
            const Expanded(
              flex: 4,
              child: SizedBox(
                height: 420,
                child: PaymentTypesChart(
                  cashPercentage: 35,
                  cardPercentage: 55,
                  onlinePercentage: 10,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child: SizedBox(
                height: 450,
                child: TopItemsList(
                  title: AppLocalizations.of(context)!.dashboardTopCategories,
                  items: [
                    TopItem(name: 'Main Course', count: 145, imageUrl: ''),
                    TopItem(name: 'Beverages', count: 98, imageUrl: ''),
                    TopItem(name: 'Appetizers', count: 76, imageUrl: ''),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 6,
              child: SizedBox(
                height: 450,
                child: CreditOrdersTable(
                  orders: [
                    CreditOrder(customerName: 'John Doe', amount: 150.50, date: '10:30 AM'),
                    CreditOrder(customerName: 'Jane Smith', amount: 45.00, date: '11:15 AM'),
                    CreditOrder(customerName: 'Bob Johnson', amount: 320.00, date: '12:00 PM'),
                    CreditOrder(customerName: 'Alice Brown', amount: 20.00, date: '01:20 PM'),
                  ],
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildOverviewMetrics() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      clipBehavior: Clip.none,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildOverviewCard(AppLocalizations.of(context)!.dashboardMetricDineIn, '45', Icons.restaurant_rounded, const Color(0xFF4A00E0)),
          const SizedBox(width: 24),
          _buildOverviewCard(AppLocalizations.of(context)!.dashboardMetricDelivered, '128', Icons.delivery_dining_rounded, const Color(0xFF00C9FF)),
          const SizedBox(width: 24),
          _buildOverviewCard(AppLocalizations.of(context)!.dashboardMetricPickup, '32', Icons.local_mall_rounded, const Color(0xFFFFA751)),
          const SizedBox(width: 24),
          _buildOverviewCard(AppLocalizations.of(context)!.dashboardMetricCancelled, '5', Icons.cancel_rounded, const Color(0xFFFF512F)),
          const SizedBox(width: 24),
          _buildOverviewCard(AppLocalizations.of(context)!.dashboardMetricOrders, '210', Icons.receipt_long_rounded, const Color(0xFF92FE9D)),
          const SizedBox(width: 24),
          _buildOverviewCard(AppLocalizations.of(context)!.dashboardMetricTotalSales, '\$4,250', Icons.attach_money_rounded, const Color(0xFFFF9A9E)),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(String title, String value, IconData icon, Color color) {
    return SizedBox(
      width: 260,
      child: OverviewCard(
        title: title,
        value: value,
        icon: icon,
        color: color,
      ),
    );
  }

  String _getLocalizedFilter(BuildContext context, String filter) {
    switch (filter) {
      case 'Yesterday': return AppLocalizations.of(context)!.dashboardFilterYesterday;
      case 'Today': return AppLocalizations.of(context)!.dashboardFilterToday;
      case 'This Week': return AppLocalizations.of(context)!.dashboardFilterWeek;
      case 'This Month': return AppLocalizations.of(context)!.dashboardFilterMonth;
      case 'This Year': return AppLocalizations.of(context)!.dashboardFilterYear;
      default: return filter;
    }
  }
}
