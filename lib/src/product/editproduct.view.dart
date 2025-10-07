import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:puvipureadmin/src/models/product.dart';
import 'package:puvipureadmin/src/product/productcontroller.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;
  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController priceController;
  late TextEditingController priceQtyController;
  late TextEditingController stockController;
  late TextEditingController priceQtyUnitController;
  late TextEditingController isActiveController;

  List<TextEditingController> detailTitleControllers = [];
  List<TextEditingController> detailContentControllers = [];
  List<String?> detailTitleErrors = [];
  List<String?> detailContentErrors = [];

  // Track IDs for existing details
  List<int?> detailIds = [];

  // Track deleted detail IDs
  List<int> deletedDetailIds = [];

  bool loading = false;
  final _formKey = GlobalKey<FormState>();

  // Safe max lengths
  static const int procodeMax = 95;
  static const int pronameMax = 190;
  static const int descriptionMax = 800;
  static const int detailTitleMax = 100;
  static const int detailContentMax = 2000;

  String? nameError;
  String? descriptionError;
  String? priceError;
  String? priceQtyError;
  String? stockError;
  String? unitError;
  String? statusError;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    nameController = TextEditingController(text: p.proname)..addListener(_validateName);
    descriptionController = TextEditingController(text: p.description)..addListener(_validateDescription);
    priceController = TextEditingController(text: p.price.toString())..addListener(_validatePrice);
    priceQtyController = TextEditingController(text: p.priceqty.toString())..addListener(_validatePriceQty);
    stockController = TextEditingController(text: p.stockqty.toString())..addListener(_validateStock);
    priceQtyUnitController = TextEditingController(text: p.priceqtyunit);
    isActiveController = TextEditingController(text: p.isactive);

    // Load existing product details with IDs
    for (var d in p.details) {
      detailTitleControllers.add(TextEditingController(text: d.title));
      detailContentControllers.add(TextEditingController(text: d.content));
      detailTitleErrors.add(null);
      detailContentErrors.add(null);
      detailIds.add(d.id); // track ID

      final index = detailTitleControllers.length - 1;
      detailTitleControllers[index].addListener(() => _validateDetailTitle(index));
      detailContentControllers[index].addListener(() => _validateDetailContent(index));
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    priceQtyController.dispose();
    stockController.dispose();
    priceQtyUnitController.dispose();
    isActiveController.dispose();
    for (var c in detailTitleControllers) c.dispose();
    for (var c in detailContentControllers) c.dispose();
    super.dispose();
  }

  // ---------------- Live Validators ----------------
  void _validateName() {
    setState(() {
      final text = nameController.text.trim();
      if (text.isEmpty) nameError = "Required";
      else if (text.length > pronameMax) nameError = "Max length $pronameMax";
      else nameError = null;
    });
  }

  void _validateDescription() {
    setState(() {
      final text = descriptionController.text.trim();
      if (text.isEmpty) descriptionError = "Required";
      else if (text.length > descriptionMax) descriptionError = "Max length $descriptionMax";
      else descriptionError = null;
    });
  }

  void _validatePrice() {
    setState(() {
      final n = double.tryParse(priceController.text.trim());
      if (priceController.text.trim().isEmpty) priceError = "Required";
      else if (n == null || n <= 0) priceError = "Must be > 0";
      else priceError = null;
    });
  }

  void _validatePriceQty() {
    setState(() {
      final n = double.tryParse(priceQtyController.text.trim());
      if (priceQtyController.text.trim().isEmpty) priceQtyError = "Required";
      else if (n == null || n <= 0) priceQtyError = "Must be > 0";
      else priceQtyError = null;
    });
  }

  void _validateStock() {
    setState(() {
      final n = double.tryParse(stockController.text.trim());
      if (stockController.text.trim().isEmpty) stockError = "Required";
      else if (n == null || n < 0) stockError = "Cannot be negative";
      else stockError = null;
    });
  }

  void _validateDetailTitle(int index) {
    setState(() {
      final text = detailTitleControllers[index].text.trim();
      if (text.isEmpty) detailTitleErrors[index] = "Required";
      else if (text.length > detailTitleMax) detailTitleErrors[index] = "Max length $detailTitleMax";
      else detailTitleErrors[index] = null;
    });
  }

  void _validateDetailContent(int index) {
    setState(() {
      final text = detailContentControllers[index].text.trim();
      if (text.isEmpty) detailContentErrors[index] = "Required";
      else if (text.length > detailContentMax) detailContentErrors[index] = "Max length $detailContentMax";
      else detailContentErrors[index] = null;
    });
  }

  // ---------------- Save ----------------
  Future<void> _saveProduct() async {
    // Validate
    _validateName();
    _validateDescription();
    _validatePrice();
    _validatePriceQty();
    _validateStock();
    unitError = priceQtyUnitController.text.isEmpty ? "Required" : null;
    statusError = isActiveController.text.isEmpty ? "Required" : null;
    for (int i = 0; i < detailTitleControllers.length; i++) {
      _validateDetailTitle(i);
      _validateDetailContent(i);
    }

    final errors = [
      nameError,
      descriptionError,
      priceError,
      priceQtyError,
      stockError,
      unitError,
      statusError,
      ...detailTitleErrors,
      ...detailContentErrors,
    ].whereType<String>().toList();

    if (errors.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errors.join("\n")), duration: const Duration(seconds: 3)),
      );
      return;
    }

    setState(() => loading = true);
    final controller = context.read<ProductController>();

    // Build details payload with IDs
    final detailsPayload = List.generate(detailTitleControllers.length, (i) {
      return {
        if (detailIds[i] != null) "id": detailIds[i], // include existing IDs
        "title": detailTitleControllers[i].text.trim(),
        "content": detailContentControllers[i].text.trim(),
      };
    });

    final updateBody = {
      "procode": widget.product.procode,
      "proname": nameController.text.trim(),
      "description": descriptionController.text.trim(),
      "price": double.tryParse(priceController.text) ?? 0,
      "priceqty": double.tryParse(priceQtyController.text) ?? 0,
      "priceqtyunit": priceQtyUnitController.text.trim(),
      "stockqty": double.tryParse(stockController.text) ?? 0,
      "isactive": isActiveController.text.trim(),
      "details": detailsPayload,
      "deletedDetailIds": deletedDetailIds, // backend can remove these
    };

    final updated = await controller.updateProduct(updateBody);
    setState(() => loading = false);

    if (updated != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product updated successfully")),
      );
      Navigator.pop(context, updated);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update product")),
      );
    }
  }

  // ---------------- Delete Detail ----------------
  Future<void> _deleteDetail(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Detail"),
        content: const Text("Are you sure you want to delete this detail?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        if (detailIds[index] != null) {
          deletedDetailIds.add(detailIds[index]!); // track deletion
        }
        detailTitleControllers.removeAt(index);
        detailContentControllers.removeAt(index);
        detailTitleErrors.removeAt(index);
        detailContentErrors.removeAt(index);
        detailIds.removeAt(index);
      });
    }
  }

  // ---------------- Add Detail ----------------
  void _addDetail() {
    setState(() {
      detailTitleControllers.add(TextEditingController());
      detailContentControllers.add(TextEditingController());
      detailTitleErrors.add(null);
      detailContentErrors.add(null);
      detailIds.add(null); // new detail has no ID
      final index = detailTitleControllers.length - 1;
      detailTitleControllers[index].addListener(() => _validateDetailTitle(index));
      detailContentControllers[index].addListener(() => _validateDetailContent(index));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Product"),
        backgroundColor: Colors.green[200],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Code
                        TextFormField(
                          initialValue: widget.product.procode,
                          maxLength: procodeMax,
                          decoration: InputDecoration(
                            labelText: "Product Code",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            counterText: "",
                          ),
                          readOnly: true,
                        ),
                        const SizedBox(height: 16),

                        // Name
                        TextFormField(
                          controller: nameController,
                          maxLength: pronameMax,
                          decoration: InputDecoration(
                            labelText: "Product Name",
                            errorText: nameError,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Description
                        TextFormField(
                          controller: descriptionController,
                          maxLines: 4,
                          maxLength: descriptionMax,
                          decoration: InputDecoration(
                            labelText: "Description",
                            errorText: descriptionError,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Price, Qty, Unit Row
                        Row(
                          children: [
                            Flexible(
                              flex: 2,
                              child: TextFormField(
                                controller: priceController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: InputDecoration(
                                  labelText: "Price",
                                  errorText: priceError,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              flex: 2,
                              child: TextFormField(
                                controller: priceQtyController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: InputDecoration(
                                  labelText: "Price Qty",
                                  errorText: priceQtyError,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              flex: 2,
                              child: DropdownButtonFormField<String>(
                                value: priceQtyUnitController.text,
                                isDense: true,
                                decoration: InputDecoration(
                                  labelText: "Unit",
                                  errorText: unitError,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                items: const [
                                  DropdownMenuItem(value: "L", child: Text("Liter")),
                                  DropdownMenuItem(value: "KG", child: Text("Kilogram")),
                                ],
                                onChanged: (val) => setState(() => priceQtyUnitController.text = val ?? "L"),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Stock
                        TextFormField(
                          controller: stockController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: "Stock Qty",
                            errorText: stockError,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Active Status
                        DropdownButtonFormField<String>(
                          value: isActiveController.text,
                          isDense: true,
                          decoration: InputDecoration(
                            labelText: "Active Status",
                            errorText: statusError,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          items: const [
                            DropdownMenuItem(value: "Y", child: Text("Active")),
                            DropdownMenuItem(value: "N", child: Text("Inactive")),
                          ],
                          onChanged: (val) => setState(() => isActiveController.text = val ?? "Y"),
                        ),
                        const SizedBox(height: 24),

                        // Product Details
                        Text("Product Details", style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        ...List.generate(detailTitleControllers.length, (i) {
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: detailTitleControllers[i],
                                    decoration: InputDecoration(
                                      labelText: "Title",
                                      errorText: detailTitleErrors[i],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: detailContentControllers[i],
                                    decoration: InputDecoration(
                                      labelText: "Content",
                                      errorText: detailContentErrors[i],
                                    ),
                                    maxLines: 3,
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: IconButton(
                                      icon: const Icon(Icons.delete, color: Color.fromARGB(255, 197, 17, 4)),
                                      onPressed: () => _deleteDetail(i),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),

                        // Add new detail
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(Icons.add, color: Colors.green),
                            onPressed: _addDetail,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Save button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: _saveProduct,
                            child: const Text("Save Changes", style: TextStyle(fontSize: 16, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
