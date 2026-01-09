import 'package:flutter/material.dart';
import '../../inventory/services/product_service.dart';
import '../../inventory/models/product_model.dart';

/// Screen to display low stock notifications
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ProductService _productService = ProductService();
  List<Product> _lowStockProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLowStockProducts();
  }

  Future<void> _loadLowStockProducts() async {
    try {
      final products = await _productService.getAllProducts();
      setState(() {
        _lowStockProducts = products.where((p) => p.isLowStock).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Low Stock Notifications'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _lowStockProducts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No Low Stock Items',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'All products are well stocked',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadLowStockProducts,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _lowStockProducts.length,
                    itemBuilder: (context, index) {
                      final product = _lowStockProducts[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.warning,
                              color: Colors.orange,
                            ),
                          ),
                          title: Text(
                            product.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                'Stock: ${product.stockQuantity ?? 0}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              if (product.lowStockThreshold != null)
                                Text(
                                  'Threshold: ${product.lowStockThreshold}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.arrow_forward_ios, size: 16),
                            onPressed: () {
                              // Navigate to product details or inventory
                              Navigator.pushNamed(context, '/inventory');
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

