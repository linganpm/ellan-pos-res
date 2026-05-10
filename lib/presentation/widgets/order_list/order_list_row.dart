import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/localization/l10n/app_localizations.dart';
import '../../../core/utils/font_utility.dart';
import '../../../data/models/order_list_model.dart';
import 'order_status_badge.dart';

class OrderListRow extends StatefulWidget {
  final OrderListModel order;
  final int index;
  final VoidCallback onInfoTap;
  final VoidCallback onPrintTap;
  final VoidCallback onUpdateTap;
  final VoidCallback onPayNowTap;

  const OrderListRow({
    super.key,
    required this.order,
    required this.index,
    required this.onInfoTap,
    required this.onPrintTap,
    required this.onUpdateTap,
    required this.onPayNowTap,
  });

  @override
  State<OrderListRow> createState() => _OrderListRowState();
}

class _OrderListRowState extends State<OrderListRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(symbol: '\$');
    final timeFormatter = DateFormat('MMM dd, hh:mm a');

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: _isHovered ? Colors.grey.withOpacity(0.05) : (widget.index % 2 == 0 ? Colors.white : Colors.grey.withOpacity(0.02)),
          border: Border(
            bottom: BorderSide(color: Colors.grey.withOpacity(0.1)),
          ),
        ),
        child: Row(
          children: [
            // 1. Sl No
            Expanded(
              flex: 1,
              child: Text(
                '${widget.index + 1}',
                style: FontUtility.body.copyWith(color: Colors.black54),
              ),
            ),
            // 2. Order ID
            Expanded(
              flex: 2,
              child: Text(
                '#${widget.order.orderId}',
                style: FontUtility.body.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            // 3. Type
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.order.orderType, style: FontUtility.body),
                  if (widget.order.isDineIn && widget.order.formattedTableInfo.isNotEmpty)
                    Text(
                      widget.order.formattedTableInfo,
                      style: FontUtility.body.copyWith(fontSize: 12, color: Colors.black54),
                    ),
                ],
              ),
            ),
            // 4. Name
            Expanded(
              flex: 3,
              child: Text(
                widget.order.customerName,
                style: FontUtility.body,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // 5. Time
            Expanded(
              flex: 2,
              child: Text(
                timeFormatter.format(widget.order.timestamp),
                style: FontUtility.body.copyWith(fontSize: 13, color: Colors.black54),
              ),
            ),
            // 6. Order Status
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: OrderStatusBadge(status: widget.order.orderStatus),
              ),
            ),
            // 7. Payment Status
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: widget.order.paymentStatus == 'Unpaid'
                    ? ElevatedButton(
                        onPressed: widget.onPayNowTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                          minimumSize: const Size(80, 32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.orderListPayNow,
                          style: FontUtility.body.copyWith(color: Colors.white, fontSize: 12),
                        ),
                      )
                    : OrderStatusBadge(status: widget.order.paymentStatus, isPaymentStatus: true),
              ),
            ),
            // 8. Items
            Expanded(
              flex: 1,
              child: Text(
                '${widget.order.itemCount}',
                style: FontUtility.body,
                textAlign: TextAlign.center,
              ),
            ),
            // 9. Total
            Expanded(
              flex: 2,
              child: Text(
                currencyFormatter.format(widget.order.totalAmount),
                style: FontUtility.body.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.right,
              ),
            ),
            // 10. Actions
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildActionButton(
                    icon: Icons.info_outline_rounded,
                    tooltip: 'Info',
                    onTap: widget.onInfoTap,
                    color: Colors.blue.shade600,
                  ),
                  _buildActionButton(
                    icon: Icons.print_rounded,
                    tooltip: 'Print',
                    onTap: widget.onPrintTap,
                    color: Colors.grey.shade700,
                  ),
                  _buildActionButton(
                    icon: Icons.edit_rounded,
                    tooltip: 'Update',
                    onTap: widget.onUpdateTap,
                    color: Colors.orange.shade700,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }
}
