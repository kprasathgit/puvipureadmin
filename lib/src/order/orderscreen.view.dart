import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:puvipureadmin/src/common/commonmethods.dart';
import 'package:puvipureadmin/src/common/constantvalues.dart';
import 'package:puvipureadmin/src/models/order_models.dart';
import 'package:puvipureadmin/src/order/ordercontroller.dart';
import 'package:puvipureadmin/src/widgets/ordercontent.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key, this.orderId});
  final String? orderId;

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final _scroll = ScrollController();
  final _searchCtrl = TextEditingController();
  StreamSubscription<QuerySnapshot>? _orderStream;
  final List<DocumentChange> _bufferedChanges = [];

  @override
  void initState() {
    super.initState();
    final ctrl = context.read<OrderController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ctrl.fetchNext();
      _startRealTimeStreaming(ctrl);

      // If a specific orderId is requested → scroll to it
      if (widget.orderId != null) {
        _scrollToOrder(widget.orderId!, ctrl);
      }
    });
    // WidgetsBinding.instance.addPostFrameCallback((_) => ctrl.fetchNext());

    _scroll.addListener(() {
      if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 300) {
        ctrl.fetchNext();
      }
    });
  }

  void _startRealTimeStreaming(OrderController ctrl) {
    _orderStream?.cancel();

    _orderStream = FirebaseFirestore.instance
        .collection('orders')
        .orderBy('createdtime', descending: true)
        .snapshots()
        .listen((snapshot) async {
          if (ctrl.loading) {
            // 🔹 If pagination is running, buffer changes
            _bufferedChanges.addAll(snapshot.docChanges);
            return;
          }

          // 🔹 If not loading, process normally
          await _processChanges(snapshot.docChanges, ctrl);
        });

    // 🔹 When loading finishes → flush buffer
    ctrl.addListener(() async {
      if (!ctrl.loading && _bufferedChanges.isNotEmpty) {
        final buffered = List<DocumentChange>.from(_bufferedChanges);
        _bufferedChanges.clear();
        await _processChanges(buffered, ctrl);
      }
    });
  }

  Future<void> _processChanges(
    List<DocumentChange> changes,
    OrderController ctrl,
  ) async {
    final List<Future<void>> fetchTasks = [];

    for (var change in changes) {
      final orderId = change.doc.id;
      final idx = ctrl.orders.indexWhere((o) => o.orderid == orderId);

      if (idx == -1) {
        // New order → fetch from backend
        fetchTasks.add(() async {
          final order = await ctrl.fetchOrderById(orderId);
          if (order != null) ctrl.orders.insert(0, order);
        }());
      } else {
        // Existing order → check status mismatch
        final localOrder = ctrl.orders[idx];
        final firestoreStatus = change.doc.get('status') as String?;

        if (localOrder.orderstatus != firestoreStatus) {
          fetchTasks.add(() async {
            final updatedOrder = await ctrl.fetchOrderById(orderId);
            if (updatedOrder != null) ctrl.orders[idx] = updatedOrder;
          }());
        }
      }
    }

    await Future.wait(fetchTasks);

    // 🔹 Refresh summary after processing all changes
    await ctrl.refreshSummary();
    ctrl.notifyListeners();
  }

  void _scrollToOrder(String orderId, OrderController ctrl) {
    final index = ctrl.orders.indexWhere((o) => o.orderid == orderId);
    if (index != -1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scroll.animateTo(
          index * 100.0, // rough estimate of card height
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _orderStream?.cancel();
    _scroll.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.read<OrderController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Orders',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            tooltip: "Refresh Orders",
            onPressed: () => ctrl.refresh(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: _buildSearchAndFilters(ctrl),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Consumer<OrderController>(
      builder: (context, ctrl, _) {
        // 🔹 Show loading initially if first page is loading
        if (ctrl.loading && ctrl.orders.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // 🔹 No orders case
        if (ctrl.orders.isEmpty) {
          return const Center(child: Text('No orders found'));
        }

        return RefreshIndicator(
          onRefresh: () => ctrl.refresh(),
          child: Column(
            children: [
              // 🔹 Summary from backend
              Selector<OrderController, Map<String, int>>(
                selector: (_, c) => c.summary,
                shouldRebuild: (prev, next) =>
                    prev.toString() != next.toString(),
                builder: (_, counts, __) => _buildSummary(counts),
              ),

              // 🔹 Date filter chip
              if (ctrl.fromDate != null && ctrl.toDate != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Chip(
                      avatar: const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.blueGrey,
                      ),
                      label: Text(
                        "${_formatDate(ctrl.fromDate!)} → ${_formatDate(ctrl.toDate!)}",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      onDeleted: () => ctrl.setDateRange(null, null),
                    ),
                  ),
                ),

              // 🔹 Orders list with pagination
              Expanded(
                child: ListView.builder(
                  controller: _scroll,
                  itemCount: ctrl.orders.length + (ctrl.hasMore ? 1 : 0),
                  itemBuilder: (context, idx) {
                    // 🔹 Bottom loader
                    if (idx == ctrl.orders.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final orderId = ctrl.orders[idx].orderid;

                    return Selector<OrderController, OrderFull?>(
                      selector: (_, c) {
                        try {
                          return c.orders.firstWhere(
                            (o) => o.orderid == orderId,
                          );
                        } catch (_) {
                          return null;
                        }
                      },
                      shouldRebuild: (prev, next) => prev != next,
                      builder: (_, updatedOrder, __) {
                        if (updatedOrder == null) {
                          return const SizedBox.shrink();
                        }
                        return OrderCardContent(order: updatedOrder);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummary(Map<String, int> counts) {
    return Container(
      color: Colors.grey.shade100,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _summaryTile("Total", counts["total"] ?? 0, Colors.blueGrey),
          _summaryTile("Paid", counts["paid"] ?? 0, Colors.green),
          _summaryTile("Pending", counts["pending"] ?? 0, Colors.orange),
          _summaryTile("Failed", counts["failed"] ?? 0, Colors.red),
        ],
      ),
    );
  }

  Widget _summaryTile(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters(OrderController ctrl) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        children: [
          // Search box ~40% width
          SizedBox(
            width: 100, // approx 40% on desktop, adjust as needed
            child: TextField(
              controller: _searchCtrl,
              onSubmitted: (v) => ctrl.setSearch(v.trim()),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, size: 20),
                hintText: "Search by Order ID, User Name, or Mobile No",
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Order Status Dropdown
          DropdownButton<String>(
            value: ctrl.filterStatus,
            underline: const SizedBox(),
            // alignment: Alignment.center,
            isDense: true,
            onChanged: (v) {
              if (v != null) ctrl.setFilter(v);
            },
            items: [
              const DropdownMenuItem(value: "ALL", child: Text("All")),
              ...ConstantValues.orderLabels.entries.map(
                (e) => DropdownMenuItem(value: e.key, child: Text(e.value)),
              ),
            ],
          ),
          const SizedBox(width: 8),

          // Sort Dropdown
          DropdownButton<String>(
            value: ctrl.sort,
            underline: const SizedBox(),
            onChanged: (v) {
              if (v != null) ctrl.setSort(v);
            },
            items: const [
              DropdownMenuItem(value: "NEWEST", child: Text("Newest")),
              DropdownMenuItem(value: "OLDEST", child: Text("Oldest")),
              DropdownMenuItem(value: "AMOUNT", child: Text("Amount")),
            ],
          ),
          const SizedBox(width: 8),

          // Date filter button
          IconButton(
            icon: const Icon(Icons.calendar_today, size: 20),
            tooltip: "Filter by Date",
            onPressed: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020, 1, 1),
                lastDate: DateTime.now(),
                initialDateRange: (ctrl.fromDate != null && ctrl.toDate != null)
                    ? DateTimeRange(start: ctrl.fromDate!, end: ctrl.toDate!)
                    : null,
              );
              if (picked != null) {
                ctrl.setDateRange(picked.start, picked.end);
              }
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) => "${d.day}/${d.month}/${d.year}";
}

