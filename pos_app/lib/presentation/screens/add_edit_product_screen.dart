import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/product.dart';
import '../providers/product_provider.dart';
import '../widgets/qr_scanner_widget.dart';

/// Add/Edit Product screen
/// Allows creating new products or editing existing ones
class AddEditProductScreen extends StatefulWidget {
  final ProductProvider productProvider;
  final Product? product;
  final String? preFilledSku;

  const AddEditProductScreen({
    super.key,
    required this.productProvider,
    this.product,
    this.preFilledSku,
  });

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _skuController;
  late TextEditingController _nameController;
  late TextEditingController _costPriceController;
  late TextEditingController _sellingPriceController;
  late TextEditingController _stockController;
  late TextEditingController _lowStockThresholdController;
  late TextEditingController _descriptionController;
  String? _categoryId;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _skuController = TextEditingController(
      text: product?.sku ?? widget.preFilledSku ?? '',
    );
    _nameController = TextEditingController(text: product?.name ?? '');
    _costPriceController = TextEditingController(
      text: product?.costPrice.toString() ?? '0.00',
    );
    _sellingPriceController = TextEditingController(
      text: product?.sellingPrice.toString() ?? '0.00',
    );
    _stockController = TextEditingController(
      text: product?.currentStock.toString() ?? '0',
    );
    _lowStockThresholdController = TextEditingController(
      text: product?.lowStockThreshold.toString() ?? '10',
    );
    _descriptionController = TextEditingController(text: product?.description ?? '');
    _categoryId = product?.categoryId;
  }

  @override
  void dispose() {
    _skuController.dispose();
    _nameController.dispose();
    _costPriceController.dispose();
    _sellingPriceController.dispose();
    _stockController.dispose();
    _lowStockThresholdController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _scanSkuQrCode() async {
    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QrScannerWidget(
          onScan: (scannedCode) {
            // Set the scanned code as SKU
            setState(() {
              _skuController.text = scannedCode.trim();
            });
          },
        ),
      ),
    );
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final now = DateTime.now();
    final product = Product(
      id: widget.product?.id ?? '',
      sku: _skuController.text.trim(),
      name: _nameController.text.trim(),
      categoryId: _categoryId,
      costPrice: double.tryParse(_costPriceController.text) ?? 0.0,
      sellingPrice: double.tryParse(_sellingPriceController.text) ?? 0.0,
      currentStock: int.tryParse(_stockController.text) ?? 0,
      lowStockThreshold: int.tryParse(_lowStockThresholdController.text) ?? 10,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      createdAt: widget.product?.createdAt ?? now,
      updatedAt: now,
    );

    final success = widget.product == null
        ? await widget.productProvider.createProduct(product)
        : await widget.productProvider.updateProduct(product);

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.product == null
              ? 'Product created successfully'
              : 'Product updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.productProvider.errorMessage ?? 'Failed to save product'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Product' : 'Add Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // SKU Field with QR Scan
              TextFormField(
                controller: _skuController,
                decoration: InputDecoration(
                  labelText: 'SKU *',
                  hintText: 'Enter product SKU or scan QR code',
                  prefixIcon: const Icon(Icons.tag),
                  suffixIcon: !isEdit
                      ? IconButton(
                          icon: const Icon(Icons.qr_code_scanner),
                          onPressed: _scanSkuQrCode,
                          tooltip: 'Scan QR Code for SKU',
                        )
                      : null,
                  border: const OutlineInputBorder(),
                ),
                enabled: !isEdit, // SKU cannot be changed after creation
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter SKU';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name *',
                  hintText: 'Enter product name',
                  prefixIcon: Icon(Icons.inventory_2),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter product name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Cost Price Field
              TextFormField(
                controller: _costPriceController,
                decoration: const InputDecoration(
                  labelText: 'Cost Price *',
                  hintText: '0.00',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter cost price';
                  }
                  final price = double.tryParse(value);
                  if (price == null || price < 0) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Selling Price Field
              TextFormField(
                controller: _sellingPriceController,
                decoration: const InputDecoration(
                  labelText: 'Selling Price *',
                  hintText: '0.00',
                  prefixIcon: Icon(Icons.sell),
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter selling price';
                  }
                  final price = double.tryParse(value);
                  if (price == null || price < 0) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Current Stock Field
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(
                  labelText: 'Current Stock *',
                  hintText: '0',
                  prefixIcon: Icon(Icons.inventory),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter stock quantity';
                  }
                  final stock = int.tryParse(value);
                  if (stock == null || stock < 0) {
                    return 'Please enter a valid stock quantity';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Low Stock Threshold Field
              TextFormField(
                controller: _lowStockThresholdController,
                decoration: const InputDecoration(
                  labelText: 'Low Stock Threshold *',
                  hintText: '10',
                  prefixIcon: Icon(Icons.warning),
                  border: OutlineInputBorder(),
                  helperText: 'Alert when stock falls below this level',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter low stock threshold';
                  }
                  final threshold = int.tryParse(value);
                  if (threshold == null || threshold < 0) {
                    return 'Please enter a valid threshold';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter product description (optional)',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Save Button
              ElevatedButton(
                onPressed: _isLoading ? null : _saveProduct,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        isEdit ? 'Update Product' : 'Create Product',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

