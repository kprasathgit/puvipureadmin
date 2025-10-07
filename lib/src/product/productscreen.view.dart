import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:puvipureadmin/src/product/editproduct.view.dart';
import 'package:puvipureadmin/src/product/productcontroller.dart';
import 'package:puvipureadmin/src/models/product.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late ProductController controller;
  List<Product> filteredProducts = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = context.read<ProductController>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await controller.fetchProducts();
      setState(() {
        filteredProducts = controller.products;
      });
    });

    searchController.addListener(() {
      final query = searchController.text.toLowerCase();
      setState(() {
        filteredProducts = controller.products
            .where(
              (p) =>
                  p.proname.toLowerCase().contains(query) ||
                  p.procode.toLowerCase().contains(query),
            )
            .toList();
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _deleteProduct(String procode) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this product?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await controller.deleteProduct(procode);
      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Product deleted")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to delete product")),
        );
      }
      setState(() {
        filteredProducts = controller.products;
      });
    }
  }

  void _editProduct(Product product) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditProductScreen(product: product)),
    );

    if (updated != null) {
      setState(() {
        final index = filteredProducts.indexWhere(
          (p) => p.procode == updated.procode,
        );
        if (index != -1) filteredProducts[index] = updated;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    controller = context.watch<ProductController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Products"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await controller.fetchProducts();
              setState(() {
                filteredProducts = controller.products;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Open add product form
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search products...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
      ),
      body: controller.loading
          ? const Center(child: CircularProgressIndicator())
          : filteredProducts.isEmpty
          ? const Center(child: Text("No products available"))
          : ListView.separated(
              itemCount: filteredProducts.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (_, index) {
                final p = filteredProducts[index];
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      p.imageurl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image_not_supported),
                    ),
                  ),
                  title: Text(
                    p.proname,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text("Stock: ${p.stockqty} | ₹${p.price}"),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == "edit") {
                        _editProduct(p);
                      } else if (value == "delete") {
                        _deleteProduct(p.procode);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: "edit", child: Text("Edit")),
                      //PopupMenuItem(value: "delete", child: Text("Delete")),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
