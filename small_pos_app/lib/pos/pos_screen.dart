import 'dart:io';
import 'package:flutter/material.dart';
import '../inventory/services/product_service.dart';
import '../inventory/models/product_model.dart';
import '../core/screens/qr_scanner_screen.dart';
import '../core/routes.dart';
import '../core/widgets/bottom_nav_bar.dart';
import '../customers/services/customer_service.dart';
import '../customers/models/customer_model.dart';
import '../customers/screens/add_edit_customer_screen.dart';
import '../core/database/settings_database.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../core/services/printer_service.dart';

/// Point of Sale screen matching the design
class POSScreen extends StatefulWidget {
  const POSScreen({super.key});

  @override
  State<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> {
  final ProductService _productService = ProductService();
  final CustomerService _customerService = CustomerService();
  final SettingsDatabase _settingsDB = SettingsDatabase.instance;
  final TextEditingController _searchController = TextEditingController();
  List<Product> _products = [];
  List<CartItem> _cartItems = [];
  String _selectedCategory = 'All Items';
  List<String> _categories = ['All Items'];
  double _discount = 0.0;
  double _tax = 5.0;
  Customer? _selectedCustomer;
  String _currencySymbol = '\$';

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadCategories();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await _settingsDB.getSettings();
      setState(() {
        _currencySymbol = settings.currencySymbol;
        _tax = settings.defaultTaxRate;
      });
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _productService.getCategories();
      setState(() {
        _categories = ['All Items', ...categories];
      });
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  void _showAddCategoryDialog() {
    final categoryController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Category'),
        content: TextField(
          controller: categoryController,
          decoration: const InputDecoration(
            hintText: 'Category name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (categoryController.text.trim().isNotEmpty) {
                setState(() {
                  final newCategory = categoryController.text.trim();
                  if (!_categories.contains(newCategory)) {
                    _categories.add(newCategory);
                    _categories.sort();
                  }
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    final products = await _productService.getAllProducts();
    setState(() {
      _products = products;
    });
  }

  void _addToCart(Product product) {
    setState(() {
      final existingIndex = _cartItems.indexWhere((item) => item.product.id == product.id);
      if (existingIndex >= 0) {
        _cartItems[existingIndex].quantity++;
      } else {
        _cartItems.add(CartItem(product: product, quantity: 1));
      }
    });
  }

  void _updateQuantity(int index, int quantity) {
    setState(() {
      if (quantity <= 0) {
        _cartItems.removeAt(index);
      } else {
        _cartItems[index].quantity = quantity;
      }
    });
  }

  void _clearCart() {
    setState(() {
      _cartItems.clear();
      _discount = 0.0;
    });
  }

  Future<void> _selectCustomer() async {
    final customers = await _customerService.getAllCustomers();
    final selected = await showDialog<Customer>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Customer'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: customers.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return ListTile(
                  leading: const Icon(Icons.store),
                  title: const Text('Walk-in Customer'),
                  onTap: () => Navigator.pop(context, null),
                );
              }
              final customer = customers[index - 1];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(customer.name[0].toUpperCase()),
                ),
                title: Text(customer.name),
                subtitle: customer.phone != null ? Text(customer.phone!) : null,
                onTap: () => Navigator.pop(context, customer),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
    setState(() {
      _selectedCustomer = selected;
    });
  }

  void _processCheckout() {
    if (_cartItems.isEmpty) return;

    // First select customer if not selected
    if (_selectedCustomer == null) {
      _selectCustomer().then((_) {
        _showCheckoutDialog();
      });
    } else {
      _showCheckoutDialog();
    }
  }

  Future<void> _saveTransaction() async {
    try {
      String customerId;
      
      if (_selectedCustomer != null) {
        customerId = _selectedCustomer!.id!;
      } else {
        // Ensure walk-in customer exists
        customerId = 'walkin';
        final walkInCustomer = await _customerService.getCustomerById('walkin');
        if (walkInCustomer == null) {
          await _customerService.addCustomer(
            Customer(
              id: 'walkin',
              name: 'Walk-in Customer',
              balance: 0.0,
              totalSpent: 0.0,
            ),
          );
        }
      }
      
      // Create transaction description with item details
      final itemList = _cartItems.map((item) => 
        '${item.product.name} x${item.quantity}'
      ).join(', ');
      final description = 'Sale: $itemList';
      
      // Generate order reference
      final orderRef = 'ORD-${DateTime.now().millisecondsSinceEpoch}';
      
      // Save transaction
      await _customerService.recordDebit(
        customerId: customerId,
        amount: _total,
        description: description,
        reference: orderRef,
      );
      
      // Print receipt
      await _printReceipt(orderRef);
      
      _clearCart();
      setState(() {
        _selectedCustomer = null;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sale completed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing sale: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _printReceipt(String orderRef) async {
    try {
      final settings = await _settingsDB.getSettings();
      final pdf = pw.Document();

      // Thermal printer format - 80mm width
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(80 * PdfPageFormat.mm, double.infinity),
          margin: const pw.EdgeInsets.all(0),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // Store Name
                pw.Text(
                  settings.storeName,
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 4),
                // Store Address
                if (settings.storeAddress != null && settings.storeAddress!.isNotEmpty)
                  pw.Text(
                    settings.storeAddress!,
                    style: const pw.TextStyle(fontSize: 10),
                    textAlign: pw.TextAlign.center,
                  ),
                if (settings.storePhone != null && settings.storePhone!.isNotEmpty)
                  pw.Text(
                    'Tel: ${settings.storePhone}',
                    style: const pw.TextStyle(fontSize: 10),
                    textAlign: pw.TextAlign.center,
                  ),
                pw.SizedBox(height: 8),
                pw.Divider(),
                pw.SizedBox(height: 8),
                // Order Info
                pw.Text(
                  'Order: $orderRef',
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  'Date: ${DateTime.now().toString().substring(0, 19)}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.SizedBox(height: 8),
                pw.Divider(),
                pw.SizedBox(height: 8),
                // Items
                ..._cartItems.map((item) {
                  return pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 4),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                item.product.name,
                                style: const pw.TextStyle(fontSize: 10),
                              ),
                              pw.Text(
                                '${item.quantity} x ${settings.currencySymbol}${item.product.sellingPrice.toStringAsFixed(2)}',
                                style: const pw.TextStyle(fontSize: 9),
                              ),
                            ],
                          ),
                        ),
                        pw.Text(
                          '${settings.currencySymbol}${(item.product.sellingPrice * item.quantity).toStringAsFixed(2)}',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  );
                }),
                pw.SizedBox(height: 8),
                pw.Divider(),
                pw.SizedBox(height: 8),
                // Totals
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Subtotal:', style: pw.TextStyle(fontSize: 10)),
                    pw.Text(
                      '${settings.currencySymbol}${_subtotal.toStringAsFixed(2)}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
                if (_discount > 0)
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Discount (${_discount.toStringAsFixed(1)}%):', style: const pw.TextStyle(fontSize: 10)),
                      pw.Text(
                        '-${settings.currencySymbol}${_discountAmount.toStringAsFixed(2)}',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Tax (${_tax.toStringAsFixed(1)}%):', style: const pw.TextStyle(fontSize: 10)),
                    pw.Text(
                      '${settings.currencySymbol}${_taxAmount.toStringAsFixed(2)}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Divider(),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'TOTAL:',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      '${settings.currencySymbol}${_total.toStringAsFixed(2)}',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Divider(),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Thank you for your business!',
                  style: const pw.TextStyle(fontSize: 10),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            );
          },
        ),
      );

      // Print directly to thermal printer without PDF saving
      final printed = await PrinterService.instance.printDirectly(pdf);
      if (!printed) {
        // Fallback: show error or use system dialog
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdf.save(),
        );
      }
    } catch (e) {
      print('Error printing receipt: $e');
      // Don't show error to user, just log it
    }
  }

  void _showCheckoutDialog() {
    // Direct checkout without dialog - print directly to thermal printer
    _saveTransaction();
  }

  // Calculate subtotal: sum of (price * quantity) for all items
  double get _subtotal {
    return _cartItems.fold(0.0, (sum, item) {
      final itemTotal = item.product.sellingPrice * item.quantity;
      return sum + itemTotal;
    });
  }

  // Calculate discount amount: percentage of subtotal
  double get _discountAmount {
    if (_discount <= 0) return 0.0;
    return (_subtotal * _discount) / 100.0;
  }

  // Calculate tax amount: percentage of (subtotal - discount)
  double get _taxAmount {
    if (_tax <= 0) return 0.0;
    final taxableAmount = _subtotal - _discountAmount;
    return (taxableAmount * _tax) / 100.0;
  }

  // Calculate total: subtotal - discount + tax
  double get _total {
    final total = _subtotal - _discountAmount + _taxAmount;
    // Ensure total is never negative
    return total < 0 ? 0.0 : total;
  }

  List<Product> get _filteredProducts {
    var filtered = _products;
    
    if (_searchController.text.isNotEmpty) {
      filtered = filtered
          .where((p) =>
              p.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
              p.sku.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    }
    
    if (_selectedCategory != 'All Items') {
      filtered = filtered.where((p) => p.category == _selectedCategory).toList();
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    var stack = Stack(
        children: [
          Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search products or scan barcode...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.qr_code_scanner, color: Color(0xFF2196F3)),
                      onPressed: () async {
                        final result = await Navigator.push<String>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const QRScannerScreen(),
                          ),
                        );
                        if (result != null) {
                          _searchController.text = result;
                          setState(() {});
                          // Try to find product by SKU and add to cart
                          final product = await _productService.getProductBySku(result);
                          if (product != null) {
                            _addToCart(product);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Added ${product.name} to cart')),
                            );
                          }
                        }
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),

              // Category Filters
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _categories.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _categories.length) {
                      // Add category button
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add, size: 16),
                              SizedBox(width: 4),
                              Text('Add Category'),
                            ],
                          ),
                          selected: false,
                          onSelected: (_) => _showAddCategoryDialog(),
                          backgroundColor: Colors.grey[200],
                          labelStyle: const TextStyle(
                            color: Color(0xFF1A1A1A),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }
                    final category = _categories[index];
                    final isSelected = _selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        selectedColor: const Color(0xFF2196F3),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF1A1A1A),
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                        backgroundColor: Colors.grey[200],
                        checkmarkColor: Colors.white,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Product Grid
              Expanded(
                child: _filteredProducts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No products found',
                              style: TextStyle(color: Colors.grey[600], fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = _filteredProducts[index];
                          return _buildProductCard(product);
                        },
                      ),
              ),

              // Space for cart overlay
              SizedBox(height: _cartItems.isEmpty ? 0 : 320),
            ],
          ),

          // Cart Overlay
          if (_cartItems.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Cart Header
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2196F3),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${_cartItems.length} items',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Cart',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: _clearCart,
                            child: const Text(
                              'Clear All',
                              style: TextStyle(color: Color(0xFF2196F3)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Cart Items
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: _cartItems.length,
                        itemBuilder: (context, index) {
                          final item = _cartItems[index];
                          return _buildCartItem(item, index);
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Discount and Tax
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'DISCOUNT %',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: '0',
                                    suffixText: '%',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _discount = double.tryParse(value) ?? 0.0;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'TAX %',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: '5',
                                    suffixText: '%',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _tax = double.tryParse(value) ?? 5.0;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Total and Checkout
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Total Amount',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$_currencySymbol${_total.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2196F3),
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            onPressed: _cartItems.isEmpty ? null : () {
                              _processCheckout();
                            },
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('Checkout'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2196F3),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ),
        ],
      );
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'New Sale',
              style: TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Main Store • POS #1',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_add, color: Colors.white, size: 20),
            ),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddEditCustomerScreen(),
                ),
              );
              if (result == true) {
                // Reload customers if needed
              }
            },
          ),
        ],
      ),
      body: stack,
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
              break;
            case 1:
              // Already here
              break;
            case 2:
              Navigator.pushReplacementNamed(context, AppRoutes.inventory);
              break;
            case 3:
              Navigator.pushReplacementNamed(context, AppRoutes.customers);
              break;
            case 4:
              Navigator.pushReplacementNamed(context, AppRoutes.reports);
              break;
            case 5:
              Navigator.pushReplacementNamed(context, AppRoutes.settings);
              break;
          }
        },
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: product.imagePath != null && product.imagePath!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child: Image.file(
                        File(product.imagePath!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.image, color: Colors.grey, size: 40);
                        },
                      ),
                    )
                  : const Icon(Icons.image, color: Colors.grey, size: 40),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '$_currencySymbol${product.sellingPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2196F3),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () => _addToCart(product),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFF2196F3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem item, int index) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: item.product.imagePath != null && item.product.imagePath!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(item.product.imagePath!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.image, color: Colors.grey);
                      },
                    ),
                  )
                : const Icon(Icons.image, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Quantity Controls
                Row(
                  children: [
                    InkWell(
                      onTap: () => _updateQuantity(index, item.quantity - 1),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Icon(Icons.remove, size: 16, color: Colors.grey),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => _updateQuantity(index, item.quantity + 1),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Icon(Icons.add, size: 16, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Price
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$_currencySymbol${item.product.sellingPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$_currencySymbol${(item.product.sellingPrice * item.quantity).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, required this.quantity});
}
