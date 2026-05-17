import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_tablet/core/controllers/ui_store_controller.dart';
import '../../core/localization/l10n/app_localizations.dart';
import '../../core/utils/font_utility.dart';
import '../../bloc/language/language_bloc.dart';
import '../../bloc/language/language_event.dart';
import '../../bloc/order_creation/order_creation_bloc.dart';
import '../../bloc/order_creation/order_creation_event.dart';
import '../../bloc/order_creation/order_creation_state.dart';
import 'dashboard_screen.dart';
import 'order_create_screen.dart';
import 'order_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Soft background color suitable for POS
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(40.0), // Tablet spacing
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.homeWelcomeBack,
                style: FontUtility.subheading,
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.homeActivityPrompt,
                style: FontUtility.body.copyWith(color: Colors.black54),
              ),
              const SizedBox(height: 48),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _buildMenuCard(
                        context,
                        title: AppLocalizations.of(context)!.homePosDashboard,
                        description: AppLocalizations.of(context)!.homeDashboardDesc,
                        iconData: Icons.dashboard_rounded,
                        color: const Color(0xFF4A00E0),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DashboardScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 40),
                    Expanded(
                      child: _buildMenuCard(
                        context,
                        title: AppLocalizations.of(context)!.homeOrdersList,
                        description: AppLocalizations.of(context)!.homeOrdersListDesc,
                        iconData: Icons.receipt_long_rounded,
                        color: const Color(0xFF8E2DE2),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const OrderListScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16), // Space at bottom
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showOrderCreationBottomSheet(context),
        backgroundColor: const Color(0xFF4A00E0),
        foregroundColor: Colors.white,
        elevation: 4,
        highlightElevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        icon: const Icon(Icons.add_rounded, size: 28),
        label: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
          child: Text(
            AppLocalizations.of(context)!.homeCreateOrder,
            style: FontUtility.button,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4A00E0).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.point_of_sale_rounded,
              color: Color(0xFF4A00E0),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            AppLocalizations.of(context)!.homePosDashboard,
            style: FontUtility.heading.copyWith(fontSize: 24),
          ),
        ],
      ),
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded, color: Colors.black87),
        onPressed: () {
          // TODO: Open drawer
        },
        tooltip: 'Menu',
      ),
      actions: [
        PopupMenuButton<Locale>(
          onSelected: (Locale locale) {
            context.read<LanguageBloc>().add(ChangeLanguageEvent(locale));
          },
          icon: const Icon(Icons.language_rounded, color: Colors.black87),
          itemBuilder: (BuildContext context) => <PopupMenuEntry<Locale>>[
            const PopupMenuItem<Locale>(
              value: Locale('en'),
              child: Text('English'),
            ),
            const PopupMenuItem<Locale>(
              value: Locale('ta'),
              child: Text('Tamil'),
            ),
          ],
        ),
        const SizedBox(width: 16),
         Padding(
           padding: const EdgeInsets.only(right: 24.0),
           child: InkWell(
             onTap: () async{
               final controller = context.read<UiStoreController>();
               print("Current Organisation: ${controller.organisation?.orgName ?? 'Unknown'}");
               var session = await controller.currentSession();
               print("Current Session: ${session != null ? 'Active' : 'No active session'}");
               print("Current session ${session!.email} and org ${session.loginAt} and ${session.organisationRole}");
               // TODO: Open profile or settings
             },
             borderRadius: BorderRadius.circular(24),
             child: const CircleAvatar(
               backgroundColor: Color(0xFF4A00E0),
               radius: 20,
               child: Icon(Icons.person_rounded, color: Colors.white, size: 24),
             ),
           ),
         ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: Colors.grey.withOpacity(0.2),
          height: 1.0,
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData iconData,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        hoverColor: color.withOpacity(0.05),
        highlightColor: color.withOpacity(0.1),
        splashColor: color.withOpacity(0.2),
        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  iconData,
                  size: 80,
                  color: color,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                title,
                style: FontUtility.heading.copyWith(fontSize: 32),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                description,
                style: FontUtility.subheading.copyWith(
                  fontSize: 20,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOrderCreationBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BlocProvider(
          create: (context) => OrderCreationBloc(),
          child: const _OrderCreationBottomSheet(),
        );
      },
    );
  }
}

class _OrderCreationBottomSheet extends StatefulWidget {
  const _OrderCreationBottomSheet();

  @override
  State<_OrderCreationBottomSheet> createState() => _OrderCreationBottomSheetState();
}

class _OrderCreationBottomSheetState extends State<_OrderCreationBottomSheet> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine screen width to constrain bottom sheet width on large tablets
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth > 600;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Center(
        child: Container(
          width: isTablet ? 600 : screenWidth,
          margin: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * 0.1,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withAlpha(2),width: 1)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.orderTypeSelection,
                      style: FontUtility.heading.copyWith(fontSize: 20),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Segmented Control
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: BlocBuilder<OrderCreationBloc, OrderCreationState>(
                  builder: (context, state) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildSegmentButton(
                              context,
                              title: AppLocalizations.of(context)!.orderTypePickup,
                              isSelected: state.orderType == OrderType.pickup,
                              onTap: () {
                                context.read<OrderCreationBloc>().add(
                                      const SelectOrderType(OrderType.pickup),
                                    );
                              },
                            ),
                          ),
                          Expanded(
                            child: _buildSegmentButton(
                              context,
                              title: AppLocalizations.of(context)!.orderTypeDineIn,
                              isSelected: state.orderType == OrderType.dineIn,
                              onTap: () {
                                context.read<OrderCreationBloc>().add(
                                      const SelectOrderType(OrderType.dineIn),
                                    );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Content based on selection
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: BlocBuilder<OrderCreationBloc, OrderCreationState>(
                    builder: (context, state) {
                      if (state.orderType == OrderType.pickup) {
                        return _buildPickupFlow(context, state);
                      } else {
                        return _buildDineInFlow(context, state);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentButton(
    BuildContext context, {
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4A00E0) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
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
        child: Center(
          child: Text(
            title,
            style: FontUtility.button.copyWith(
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPickupFlow(BuildContext context, OrderCreationState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _nameController,
          label: AppLocalizations.of(context)!.pickupName,
          hint: AppLocalizations.of(context)!.pickupNameHint,
          icon: Icons.person_outline_rounded,
          onChanged: (val) {
            context.read<OrderCreationBloc>().add(
                  UpdatePickupDetails(
                    name: val,
                    phone: _phoneController.text,
                  ),
                );
          },
          errorText: state.nameError != null
              ? _getLocalizedError(context, state.nameError!)
              : null,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _phoneController,
          label: AppLocalizations.of(context)!.pickupPhone,
          hint: AppLocalizations.of(context)!.pickupPhoneHint,
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          onChanged: (val) {
            context.read<OrderCreationBloc>().add(
                  UpdatePickupDetails(
                    name: _nameController.text,
                    phone: val,
                  ),
                );
          },
          errorText: state.phoneError != null
              ? _getLocalizedError(context, state.phoneError!)
              : null,
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                AppLocalizations.of(context)!.pickupCancelButton,
                style: FontUtility.button.copyWith(color: Colors.black54),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                context.read<OrderCreationBloc>().add(ValidatePickupForm());
                
                // Add a small delay to let bloc emit state, though it's synchronous
                Future.microtask(() {
                  if (mounted) {
                    final updatedState = context.read<OrderCreationBloc>().state;
                    if (updatedState.isPickupValid) {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderCreateScreen(
                            args: OrderCreateScreenArgs(
                              orderType: 'Pickup',
                              name: updatedState.pickupName,
                              phone: updatedState.pickupPhone,
                            ),
                          ),
                        ),
                      );
                    }
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A00E0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                AppLocalizations.of(context)!.pickupAddButton,
                style: FontUtility.button.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDineInFlow(BuildContext context, OrderCreationState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Floor selection
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildFloorButton(
                  context,
                  title: AppLocalizations.of(context)!.dineInFloorFirst,
                  isSelected: state.selectedFloor == 'first',
                  onTap: () {
                    context.read<OrderCreationBloc>().add(
                          const SelectDineInFloor('first'),
                        );
                  },
                ),
              ),
              Expanded(
                child: _buildFloorButton(
                  context,
                  title: AppLocalizations.of(context)!.dineInFloorSecond,
                  isSelected: state.selectedFloor == 'second',
                  onTap: () {
                    context.read<OrderCreationBloc>().add(
                          const SelectDineInFloor('second'),
                        );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // Table Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.0,
          ),
          itemCount: 10, // 10 tables per floor for demonstration
          itemBuilder: (context, index) {
            final tableNumber = '${index + 1}';
            final isSelected = state.selectedTable == tableNumber;
            
            return GestureDetector(
              onTap: () {
                context.read<OrderCreationBloc>().add(
                      SelectDineInTable(tableNumber),
                    );
                
                // Immediately navigate upon table selection
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderCreateScreen(
                      args: OrderCreateScreenArgs(
                        orderType: 'DineIn',
                        floor: state.selectedFloor == 'first' 
                            ? AppLocalizations.of(context)!.dineInFloorFirst 
                            : AppLocalizations.of(context)!.dineInFloorSecond,
                        table: AppLocalizations.of(context)!.dineInTable(tableNumber),
                      ),
                    ),
                  ),
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.grey.shade400 : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSelected ? Colors.grey.shade500 : const Color(0xFF4A00E0),width: 2)
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.table_restaurant_rounded,
                        color: isSelected ? Colors.white : const Color(0xFF4A00E0),
                        size: 28,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tableNumber,
                        style: FontUtility.subheading.copyWith(
                          fontSize: 16,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFloorButton(
    BuildContext context, {
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Center(
          child: Text(
            title,
            style: FontUtility.body.copyWith(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? Colors.black87 : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    required Function(String) onChanged,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: FontUtility.body.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: FontUtility.body.copyWith(color: Colors.black38),
            prefixIcon: Icon(icon, color: Colors.black45),
            errorText: errorText,
            filled: true,
            fillColor: Colors.grey.withOpacity(0.05),
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  String _getLocalizedError(BuildContext context, String errorKey) {
    switch (errorKey) {
      case 'errorNameMinLength':
        return AppLocalizations.of(context)!.errorNameMinLength;
      case 'errorInvalidPhone':
        return AppLocalizations.of(context)!.errorInvalidPhone;
      default:
        return 'Invalid input';
    }
  }
}
