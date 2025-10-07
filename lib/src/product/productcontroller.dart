import 'package:flutter/material.dart';
import '../models/product.dart';
import '../common/apiservice.dart';
import '../common/urls.dart';

class ProductController with ChangeNotifier {
  List<Product> products = [];
  bool loading = false;

  /// -------------------------
  /// Fetch all products
  /// -------------------------
  Future<void> fetchProducts() async {
    loading = true;
    notifyListeners();

    // Map backend Result -> List<Product>
    final result = await ApiService.get<List<Product>>(
      url: Urls.allProducts,
      fromJson: (data) {
        // `data` here is `returnObject` from backend Result
        final list = (data as List<dynamic>? ?? []);
        return list
            .map((e) => Product.fromMap(e as Map<String, dynamic>))
            .toList();
      },
    );

    if (result.status && result.returnObject != null) {
      products = result.returnObject!;
    } else {
      debugPrint("❌ Fetch Products Error: ${result.message}");
      products = [];
    }

    loading = false;
    notifyListeners();
  }

  /// -------------------------
  /// Add product
  /// -------------------------
  Future<Product?> addProduct(Product product) async {
    final result = await ApiService.post<Map<String, dynamic>>(
      url: Urls.addProducts,
      body: product.toMap(),
      fromJson: (data) => data['returnObject'] as Map<String, dynamic>,
    );

    if (result.status && result.returnObject != null) {
      final newProduct = Product.fromMap(result.returnObject!);
      products.add(newProduct);
      notifyListeners();
      return newProduct;
    } else {
      debugPrint("❌ Add Product Error: ${result.message}");
    }
    return null;
  }

  /// -------------------------
  /// Update product (handles Result wrapper)
  /// -------------------------
  Future<Product?> updateProduct(Map<String, dynamic> updateBody) async {
    final result = await ApiService.post<Product>(
      url: Urls.updateProducts,
      body: updateBody,
      fromJson: (data) => Product.fromMap(
        data as Map<String, dynamic>,
      ), // directly return Product
    );

    if (result.status && result.returnObject != null) {
      final updatedProduct = result.returnObject!;

      // Update local list
      final index = products.indexWhere(
        (p) => p.procode == updateBody['procode'],
      );
      if (index != -1) {
        products[index] = updatedProduct;
        notifyListeners();
      }

      return updatedProduct; // ✅ returns Product
    } else {
      debugPrint("❌ Update Product Error: ${result.message}");
      return null;
    }
  }

  /// -------------------------
  /// Delete product
  /// -------------------------
  Future<bool> deleteProduct(String procode) async {
    final result = await ApiService.post<Map<String, dynamic>>(
      url: Urls.deleteProducts,
      body: {'procode': procode},
      fromJson: (data) => data,
    );

    if (result.status) {
      products.removeWhere((p) => p.procode == procode);
      notifyListeners();
      return true;
    } else {
      debugPrint("❌ Delete Product Error: ${result.message}");
    }
    return false;
  }

  /// -------------------------
  /// Fetch low stock products
  /// -------------------------
  Future<List<Product>> fetchLowStockProducts({int threshold = 10}) async {
    final result = await ApiService.get<List<dynamic>>(
      url: Urls.getLowStockProducts,
      queryParams: {'threshold': threshold.toString()},
      fromJson: (data) => (data['returnObject'] ?? []) as List<dynamic>,
    );

    if (result.status && result.returnObject != null) {
      return result.returnObject!
          .map((e) => Product.fromMap(e as Map<String, dynamic>))
          .toList();
    } else {
      debugPrint("❌ Low Stock Fetch Error: ${result.message}");
    }

    return [];
  }
}
