import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:puvipureadmin/src/common/commonmethods.dart';
import 'package:puvipureadmin/src/common/constantvalues.dart';
import 'package:puvipureadmin/src/models/order_models.dart';

import '../order/ordercontroller.dart';

class OrderCardContent extends StatelessWidget {
  final OrderFull order;

  const OrderCardContent({super.key, required this.order});

  Future<void> _changeStatus(BuildContext context, String newStatus) async {
    final confirmed = await CommonMethods.showPinConfirmDialog(context);
    if (!confirmed) return;

    final ctrl = context.read<OrderController>();
    try {
      await ctrl.updateOrderStatus(order.orderid!, newStatus);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Status updated successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Show backend error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
      // Optional: refresh UI to show previous status
      ctrl.notifyListeners();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.read<OrderController>();

    return ValueListenableBuilder<String?>(
      valueListenable: ctrl.updatingOrderId,
      builder: (context, updatingId, _) {
        final isUpdating = updatingId == order.orderid;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ExpansionTile(
            key: ValueKey(
              "${order.orderid}_${order.orderstatus}_${order.paymentstatus}_${order.delivery?.deliverystatus}",
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    "Order #${order.orderid ?? ''}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (isUpdating)
                  const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  _buildStatusChip(context),
              ],
            ),
            subtitle: _buildSubtitle(),
            children: _buildChildren(context),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    bool isBlocked(String target) {
      final current = order.orderstatus!;
      // Cannot change if already cancelled
      if (current == "X") return true;

      // Awaiting payment cannot move forward
      if (current == "A" && target != "P") return true;

      // Flow order: P → C → S → D (cannot go backward)
      const flow = ["P", "C", "S", "D"];
      final currentIndex = flow.indexOf(current);
      final targetIndex = flow.indexOf(target);
      if (currentIndex != -1 &&
          targetIndex != -1 &&
          targetIndex <= currentIndex)
        return true;

      return false;
    }

    return PopupMenuButton<String>(
      tooltip: "Change Status",
      onSelected: (v) {
        if (isBlocked(v)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Cannot change to this status")),
          );
        } else {
          _changeStatus(context, v);
        }
      },
      itemBuilder: (ctx) => ConstantValues.orderLabels.entries
          .where((e) => !ConstantValues.blockedStatuses.contains(e.key))
          .map(
            (e) => PopupMenuItem(
              value: e.key,
              enabled: !isBlocked(e.key),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 6,
                    backgroundColor: ConstantValues.color(e.key),
                  ),
                  const SizedBox(width: 8),
                  Text(e.value),
                ],
              ),
            ),
          )
          .toList(),
      child: SizedBox(
        height: 32,
        child: Chip(
          label: Text(
            ConstantValues.label(order.orderstatus ?? ""),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: ConstantValues.color(
            order.orderstatus ?? "",
          ).withOpacity(0.15),
          labelStyle: TextStyle(
            color: ConstantValues.color(order.orderstatus ?? ""),
          ),
        ),
      ),
    );
  }

  Widget _buildSubtitle() => Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Row(
      children: [
        Expanded(
          child: Text(
            "User: ${order.user?.name ?? ''} • ₹${order.totalamount}",
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ),
        if (order.paymentid != null && order.paymentid!.isNotEmpty)
          Text(
            _shortPaymentId(order.paymentid!),
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    ),
  );

  List<Widget> _buildChildren(BuildContext context) {
    return [
      const SizedBox(height: 6),
      Row(
        children: [
          Icon(
            Icons.payment,
            size: 18,
            color: _paymentColor(order.paymentstatus),
          ),
          const SizedBox(width: 6),
          Chip(
            label: Text(order.paymentstatus ?? "Unknown"),
            backgroundColor: _paymentColor(
              order.paymentstatus,
            ).withOpacity(0.15),
            labelStyle: TextStyle(
              color: _paymentColor(order.paymentstatus),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            "Mode: ${order.paymentmode ?? '-'}",
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
      const Divider(),
      if (order.user != null)
        ListTile(
          leading: const Icon(Icons.person, color: Colors.blueGrey),
          title: Text(
            order.user?.name ?? "",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(order.user!.mobileno ?? ""),
        ),
      if (order.user?.address != null && order.user!.address!.trim().isNotEmpty)
        ListTile(
          leading: const Icon(Icons.location_on, color: Colors.teal),
          title: const Text(
            "Address",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            order.user!.address!,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ),
      if (order.delivery != null)
        ListTile(
          leading: Icon(
            Icons.local_shipping,
            color: ConstantValues.deliveryColor(order.delivery?.deliverystatus),
          ),
          title: Text(
            order.delivery!.couriername ?? "",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            "Status: ${ConstantValues.deliveryLabel(order.delivery?.deliverystatus)}",
          ),
        ),
      if (order.paymentid != null && order.paymentid!.isNotEmpty)
        ListTile(
          leading: const Icon(Icons.payment, color: Colors.deepPurple),
          title: const Text(
            "Payment ID",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: SelectableText(order.paymentid ?? ""),
          trailing: IconButton(
            icon: const Icon(Icons.copy, size: 18),
            tooltip: "Copy Payment ID",
            onPressed: () => ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text("Payment ID copied"))),
          ),
        ),
      const Divider(),
      ...order.items.map(
        (it) => ListTile(
          leading: const Icon(
            Icons.shopping_bag_outlined,
            color: Colors.orange,
          ),
          title: Text(it.procode ?? ""),
          subtitle: Text("Qty: ${it.qty}  •  Price: ₹${it.price}"),
        ),
      ),
    ];
  }

  static Color _paymentColor(String? status) {
    switch (status) {
      case "P":
        return Colors.orange;
      case "S":
        return Colors.green;
      case "F":
        return Colors.red;
      case "T":
        return Colors.purple;
      case "R":
        return Colors.blueGrey;
      case "B":
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  static String _shortPaymentId(String id) {
    if (id.length <= 10) return id;
    return "${id.substring(0, 6)}...${id.substring(id.length - 4)}";
  }
}
