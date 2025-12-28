import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/inventory_transaction.dart';
import '../providers/product_provider.dart';

/// Inventory Update Dialog
/// Allows updating product stock with different transaction types
class InventoryUpdateDialog extends StatefulWidget {
  final Product product;
  final ProductProvider productProvider;

  const InventoryUpdateDialog({
    super.key,
    required this.product,
    required this.productProvider,
  });

  @override
  State<InventoryUpdateDialog> createState() => _InventoryUpdateDialogState();
}

class _InventoryUpdateDialogState extends State<InventoryUpdateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _referenceNumberController = TextEditingController();
  final _notesController = TextEditingController();
  
  TransactionType _selectedType = TransactionType.stockIn;
  bool _isLoading = false;

  @override
  void dispose() {
    _quantityController.dispose();
    _referenceNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _updateStock() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final quantity = int.parse(_quantityController.text);

    final success = await widget.productProvider.updateStock(
      productId: widget.product.id,
      quantity: quantity,
      transactionType: _selectedType,
      referenceNumber: _referenceNumberController.text.trim().isEmpty
          ? null
          : _referenceNumberController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stock updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.productProvider.errorMessage ?? 'Failed to update stock'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  int _calculateNewStock() {
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    int newStock = widget.product.currentStock;

    switch (_selectedType) {
      case TransactionType.stockIn:
      case TransactionType.return_:
        newStock += quantity;
        break;
      case TransactionType.stockOut:
      case TransactionType.sale:
        newStock -= quantity;
        break;
      case TransactionType.adjustment:
        newStock = quantity;
        break;
    }

    return newStock < 0 ? 0 : newStock;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    const Icon(Icons.inventory, size: 32, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Update Stock',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            widget.product.name,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Current Stock:',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        '${widget.product.currentStock}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Transaction Type
                Text(
                  'Transaction Type *',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                SegmentedButton<TransactionType>(
                  segments: [
                    const ButtonSegment(
                      value: TransactionType.stockIn,
                      label: Text('Stock In'),
                      icon: Icon(Icons.add),
                    ),
                    const ButtonSegment(
                      value: TransactionType.stockOut,
                      label: Text('Stock Out'),
                      icon: Icon(Icons.remove),
                    ),
                    const ButtonSegment(
                      value: TransactionType.adjustment,
                      label: Text('Adjust'),
                      icon: Icon(Icons.edit),
                    ),
                  ],
                  selected: {_selectedType},
                  onSelectionChanged: (Set<TransactionType> newSelection) {
                    setState(() {
                      _selectedType = newSelection.first;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Quantity Field
                TextFormField(
                  controller: _quantityController,
                  decoration: InputDecoration(
                    labelText: _selectedType == TransactionType.adjustment
                        ? 'New Stock Quantity *'
                        : 'Quantity *',
                    hintText: 'Enter quantity',
                    prefixIcon: const Icon(Icons.numbers),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter quantity';
                    }
                    final qty = int.tryParse(value);
                    if (qty == null || qty <= 0) {
                      return 'Please enter a valid quantity';
                    }
                    if (_selectedType != TransactionType.adjustment &&
                        (_selectedType == TransactionType.stockOut ||
                            _selectedType == TransactionType.sale) &&
                        qty > widget.product.currentStock) {
                      return 'Insufficient stock. Available: ${widget.product.currentStock}';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {}); // Update preview
                  },
                ),
                const SizedBox(height: 16),

                // Preview new stock
                if (_quantityController.text.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'New Stock:',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Text(
                          '${_calculateNewStock()}',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                        ),
                      ],
                    ),
                  ),
                if (_quantityController.text.isNotEmpty) const SizedBox(height: 16),

                // Reference Number Field
                TextFormField(
                  controller: _referenceNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Reference Number',
                    hintText: 'PO/Invoice number (optional)',
                    prefixIcon: Icon(Icons.receipt),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Notes Field
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    hintText: 'Additional notes (optional)',
                    prefixIcon: Icon(Icons.note),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _updateStock,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Update Stock'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

