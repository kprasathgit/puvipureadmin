import 'dart:async';

import 'package:flutter/material.dart';

import '../common/apiservice.dart';
import '../common/urls.dart';
import '../models/order_models.dart';

class OrderController with ChangeNotifier {
  List<OrderFull> orders = [];
  bool loading = false;
  int page = 0;
  final int size = 50;
  bool hasMore = true;

  String searchQuery = "";
  String filterStatus = "ALL";
  String sort = "NEWEST";

  DateTime? fromDate;
  DateTime? toDate;

  final ValueNotifier<String?> updatingOrderId = ValueNotifier(null);

  Map<String, int> summary = {"total": 0, "paid": 0, "pending": 0, "failed": 0};
  // Map<String, dynamic> summary = {
  //   "total": 0,
  //   "orderStatus": {
  //     "placed": 0,
  //     "confirmed": 0,
  //     "shipped": 0,
  //     "delivered": 0,
  //     "cancelled": 0,
  //     "awaiting_payment": 0,
  //   },
  //   "paymentStatus": {"pending": 0, "success": 0, "failed": 0},
  // };

  int totalPages = 0;

  // 🔹 Existing functions intact
  Future<void> refresh() async {
    page = 0;
    hasMore = true;
    orders = [];
    notifyListeners();
    await fetchNext();
  }

  Future<void> fetchNext() async {
    if (loading || !hasMore) return;
    loading = true;
    notifyListeners();

    try {
      final result = await ApiService.get<Map<String, dynamic>>(
        url: Urls.getAllOrders,
        queryParams: {
          'page': page.toString(),
          'size': size.toString(),
          if (searchQuery.isNotEmpty) 'search': searchQuery,
          if (filterStatus != "ALL") 'status': filterStatus,
          'sort': sort,
          if (fromDate != null) 'fromDate': fromDate!.toIso8601String(),
          if (toDate != null) 'toDate': toDate!.toIso8601String(),
        },
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (result.status && result.returnObject != null) {
        final map = result.returnObject!;
        final List<dynamic> content = map['content'] ?? [];

        // 🔹 Capture summary + totalPages
        // Inside fetchNext() after fetching the map
        final rawSummary = map['summary'] as Map<String, dynamic>? ?? {};
        final paymentStatus = Map<String, dynamic>.from(
          rawSummary["paymentStatus"] ?? {},
        );
        summary = {
          "total": rawSummary["total"] ?? 0,
          "paid": paymentStatus["success"] ?? 0,
          "pending": paymentStatus["pending"] ?? 0,
          "failed": paymentStatus["failed"] ?? 0,
        };

        if (page == 0) orders = [];

        if (content.isEmpty) {
          hasMore = false;
        } else {
          orders = [
            ...orders,
            ...content.map(
              (e) => OrderFull.fromJson(Map<String, dynamic>.from(e)),
            ),
          ];
          page++;
          hasMore = content.length >= size;
        }
      } else {
        debugPrint("Error fetching orders: ${result.message}");
        hasMore = false;
      }
    } catch (e) {
      debugPrint("fetchNext error $e");
      hasMore = false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // Fetch single order by ID
  Future<OrderFull?> fetchOrderById(String orderId) async {
    try {
      final result = await ApiService.get<Map<String, dynamic>>(
        url: '${Urls.getSingleOrder}/$orderId',
        fromJson: (data) => data as Map<String, dynamic>,
      );
      if (result.status && result.returnObject != null) {
        return OrderFull.fromJson(
          Map<String, dynamic>.from(result.returnObject!),
        );
      }
    } catch (e) {
      debugPrint("fetchOrderById error $e");
    }
    return null;
  }

  Future<void> refreshSummary() async {
    try {
      final result = await ApiService.get<Map<String, dynamic>>(
        url: Urls.getOrderSummary,
        queryParams: {
          if (searchQuery.isNotEmpty) 'search': searchQuery,
          if (filterStatus != "ALL") 'status': filterStatus,
          'sort': sort,
          if (fromDate != null) 'fromDate': fromDate!.toIso8601String(),
          if (toDate != null) 'toDate': toDate!.toIso8601String(),
        },
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (result.status && result.returnObject != null) {
        final rawSummary = result.returnObject!;

        final paymentStatus = Map<String, dynamic>.from(
          rawSummary["paymentStatus"] ?? {},
        );

        summary = {
          "total": rawSummary["total"] ?? 0,
          "paid": paymentStatus["success"] ?? 0,
          "pending": paymentStatus["pending"] ?? 0,
          "failed": paymentStatus["failed"] ?? 0,
        };
        notifyListeners();
      } else {
        debugPrint("Error refreshing summary: ${result.message}");
      }
    } catch (e) {
      debugPrint("refreshSummary error: $e");
    }
  }

  Future<bool> updateOrderStatus(String orderId, String status) async {
    updatingOrderId.value = orderId;

    try {
      final result = await ApiService.post<OrderFull>(
        url: '${Urls.orderMappingUrl}/$orderId/status',
        body: {'status': status},
        fromJson: (data) => OrderFull.fromJson(Map<String, dynamic>.from(data)),
      );

      debugPrint(
        "API Result: status=${result.status}, message=${result.message}",
      );

      if (result.status && result.returnObject != null) {
        final updatedOrder = result.returnObject!;
        final index = orders.indexWhere((o) => o.orderid == orderId);
        if (index != -1) {
          orders[index] = updatedOrder;
          notifyListeners();
        }

        // 🔹 Refresh summary after status update
        unawaited(refreshSummary());

        return true;
      } else {
        // Throw backend message as exception
        throw Exception(result.message ?? "Failed to update order status");
      }
    } catch (e) {
      throw Exception("Update failed: $e");
    } finally {
      updatingOrderId.value = null;
    }

    //return false;
  }

  void setSearch(String q) {
    searchQuery = q;
    refresh();
  }

  void setFilter(String status) {
    filterStatus = status;
    refresh();
  }

  void setSort(String s) {
    sort = s;
    refresh();
  }

  void setDateRange(DateTime? from, DateTime? to) {
    fromDate = from;
    toDate = to;
    refresh();
  }
}
