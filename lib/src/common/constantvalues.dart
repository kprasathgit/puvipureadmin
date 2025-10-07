import 'package:flutter/material.dart';

class ConstantValues {
  static const defaultProductImageUrl =
      "https://static.clontalk.com/images/default.jpg";
  static const String dateTimeWithMicroSeconds = "yyyy-MM-dd HH:mm:ss.SSSSSS";

  static const String commonErrorMsg = "Unexpected Error";
  static const String commonServerProbMsg = "Server Problem.Try later.";

  // Url Path and Query Parameters constant values.

  static const String orderSummaryCheckout = "ordercheckout";
  static const String productCheckout = "productcheckout";
  static const List<String> blockedStatuses = [
    'P',
    'A',
    'I',
    'R',
  ]; // Placed, Awaiting Payment, Partially Shipped

  static const Map<String, String> orderLabels = {
    'P': 'Placed',
    'C': 'Confirmed',
    'S': 'Shipped',
    'D': 'Delivered',
    'X': 'Cancelled',
    'A': 'Awaiting Payment',
    'I': 'Partially Shipped',
    'R': 'Refunded',
  };
  static const Map<String, Color> orderColors = {
    'P': Colors.blueGrey,
    'C': Colors.blue,
    'S': Colors.orange,
    'D': Colors.green,
    'X': Colors.red,
    'A': Colors.deepPurple,
    'I': Colors.teal,
    'R': Colors.pink,
  };

  static String label(String code) => orderLabels[code] ?? code;
  static Color color(String code) => orderColors[code] ?? Colors.grey;

  static const paymentLabels = {
    "P": "Pending",
    "S": "Success",
    "F": "Failed",
    "T": "Timeout",
    "R": "Refunded",
    "B": "Chargeback",
  };

  static String paymentLabel(String code) => paymentLabels[code] ?? code;

  static Color paymentColor(String code) {
    switch (code) {
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

  static const Map<String, String> deliveryLabels = {
    "PN": "Pending",
    "PR": "Processing",
    "DS": "Dispatched",
    "IT": "In Transit",
    "FD": "Out for Delivery",
    "DV": "Delivered",
    "F": "Failed",
    "R": "Returned",
    "C": "Cancelled",
  };

  static Color deliveryColor(String? code) {
    switch (code) {
      case "PN":
        return Colors.brown;

      case "PR":
        return Colors.grey;
      case "DS":
        return Colors.blue;
      case "IT":
        return Colors.indigo;
      case "FD":
        return Colors.teal;
      case "DV":
        return Colors.green;
      case "F":
        return Colors.red;
      case "R":
        return Colors.purple;
      case "C":
        return Colors.orange;
      default:
        return Colors.black54;
    }
  }

  static String deliveryLabel(String? code) {
    return deliveryLabels[code] ?? "Unknown";
  }
}
