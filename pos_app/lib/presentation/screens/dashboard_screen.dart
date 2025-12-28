import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../widgets/app_drawer.dart';
import 'products_screen.dart';
import 'billing_screen.dart';

/// Dashboard Screen
/// Main landing page showing business overview and quick actions
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final productProvider = ServiceLocator().productProvider;
    await productProvider.loadProducts();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = ServiceLocator().productProvider;
    final totalProducts = productProvider.products.length;
    final lowStockProducts = productProvider.lowStockProducts.length;
    final outOfStockProducts = productProvider.products.where((p) => p.currentStock <= 0).length;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(currentRoute: '/dashboard'),
      appBar: AppBar(
        title: const Text('Dashboard'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            const SizedBox(height: 8),
            Text(
              'Dashboard',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Welcome back! Here\'s your business overview.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),

            // Quick Actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.point_of_sale,
                    title: 'New Sale',
                    subtitle: 'Create bill',
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BillingScreen(
                            productProvider: productProvider,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.inventory_2,
                    title: 'Add Product',
                    subtitle: 'Manage inventory',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductsScreen(
                            productProvider: productProvider,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Sales Summary Card
            _SummaryCard(
              title: 'Sales Summary (Last 7 Days)',
              onTap: () {
                // Navigate to sales report
              },
              children: [
                _SummaryMetric(
                  icon: Icons.trending_up,
                  label: 'Total Sales',
                  value: '0',
                  iconColor: Colors.blue,
                ),
                _SummaryMetric(
                  icon: Icons.attach_money,
                  label: 'Revenue',
                  value: 'Pkr0.00',
                  iconColor: Colors.green,
                ),
                _SummaryMetric(
                  icon: Icons.inventory_2,
                  label: 'Items Sold',
                  value: '0',
                  iconColor: Colors.blue,
                ),
                _SummaryMetric(
                  icon: Icons.undo,
                  label: 'Returns',
                  value: '0',
                  iconColor: Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Purchase Summary Card
            _SummaryCard(
              title: 'Purchase Summary (Last 7 Days)',
              onTap: () {
                // Navigate to purchase report
              },
              children: [
                _SummaryMetric(
                  icon: Icons.shopping_bag,
                  label: 'Total Purchases',
                  value: '0',
                  iconColor: Colors.purple,
                ),
                _SummaryMetric(
                  icon: Icons.attach_money,
                  label: 'Purchase Value',
                  value: 'Pkr0.00',
                  iconColor: Colors.purple,
                ),
                _SummaryMetric(
                  icon: Icons.inventory_2,
                  label: 'Items Purchased',
                  value: '0',
                  iconColor: Colors.blue,
                ),
                _SummaryMetric(
                  icon: Icons.people,
                  label: 'Active Vendors',
                  value: '0',
                  iconColor: Colors.pink,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Stock Overview Card
            _SummaryCard(
              title: 'Stock Overview',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductsScreen(
                      productProvider: productProvider,
                    ),
                  ),
                );
              },
              children: [
                _SummaryMetric(
                  icon: Icons.grid_view,
                  label: 'Total Products',
                  value: totalProducts.toString(),
                  iconColor: Colors.blue,
                ),
                _SummaryMetric(
                  icon: Icons.warning,
                  label: 'Low Stock Items',
                  value: lowStockProducts.toString(),
                  iconColor: Colors.orange,
                ),
                _SummaryMetric(
                  icon: Icons.close,
                  label: 'Out of Stock',
                  value: outOfStockProducts.toString(),
                  iconColor: Colors.red,
                ),
                _SummaryMetric(
                  icon: Icons.check_circle,
                  label: 'Stock Status',
                  value: lowStockProducts == 0 && outOfStockProducts == 0 ? 'Good' : 'Attention',
                  iconColor: lowStockProducts == 0 && outOfStockProducts == 0 ? Colors.green : Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final VoidCallback onTap;

  const _SummaryCard({
    required this.title,
    required this.children,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600]),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        children[0],
                        const SizedBox(height: 16),
                        children[2],
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        children[1],
                        const SizedBox(height: 16),
                        children[3],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  const _SummaryMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

