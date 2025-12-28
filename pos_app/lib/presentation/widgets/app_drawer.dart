import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../screens/products_screen.dart';
import '../screens/billing_screen.dart';

/// App Navigation Drawer
/// Provides navigation to all major sections of the app
class AppDrawer extends StatefulWidget {
  final String currentRoute;

  const AppDrawer({
    super.key,
    this.currentRoute = '/dashboard',
  });

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final Map<String, bool> _expandedSections = {
    'items': false,
    'inventory': false,
    'reports': false,
    'tax_discount': false,
  };

  void _toggleSection(String section) {
    setState(() {
      _expandedSections[section] = !(_expandedSections[section] ?? false);
    });
  }

  bool _isSelected(String route) {
    return widget.currentRoute == route;
  }

  void _navigateTo(String route) {
    Navigator.pop(context); // Close drawer
    
    final productProvider = ServiceLocator().productProvider;
    
    switch (route) {
      case '/dashboard':
        // Already on dashboard, do nothing or navigate back
        Navigator.of(context).popUntil((route) => route.isFirst);
        break;
      case '/products':
      case '/products/add':
      case '/inventory':
      case '/inventory/logs':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductsScreen(productProvider: productProvider),
          ),
        );
        break;
      case '/billing':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BillingScreen(productProvider: productProvider),
          ),
        );
        break;
      case '/customers':
      case '/settings':
      case '/reports/sales':
      case '/reports/purchase':
      case '/reports/item-sales':
      case '/tax-discount/tax':
      case '/tax-discount/discount':
      case '/premium':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$route feature coming soon!')),
        );
        break;
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ServiceLocator().authProvider.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ServiceLocator().authProvider.currentUser;

    return Drawer(
      child: Column(
        children: [
          // User Profile Section
          Container(
            padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.green,
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.fullName ?? 'Admin',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? 'Admin',
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

          // Navigation Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Dashboard
                _DrawerItem(
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  isSelected: _isSelected('/dashboard'),
                  onTap: () => _navigateTo('/dashboard'),
                ),

                // Items (Products)
                _ExpandableDrawerItem(
                  icon: Icons.inventory_2,
                  title: 'Items',
                  isExpanded: _expandedSections['items'] ?? false,
                  onToggle: () => _toggleSection('items'),
                  children: [
                    _DrawerSubItem(
                      icon: Icons.list,
                      title: 'Product List',
                      onTap: () => _navigateTo('/products'),
                    ),
                    _DrawerSubItem(
                      icon: Icons.add_box,
                      title: 'Add Product',
                      onTap: () => _navigateTo('/products/add'),
                    ),
                  ],
                ),

                // Bill
                _DrawerItem(
                  icon: Icons.receipt_long,
                  title: 'Bill',
                  isSelected: _isSelected('/billing'),
                  onTap: () => _navigateTo('/billing'),
                ),

                // Customers
                _DrawerItem(
                  icon: Icons.people,
                  title: 'Customers',
                  isSelected: _isSelected('/customers'),
                  onTap: () => _navigateTo('/customers'),
                ),

                // Settings
                _DrawerItem(
                  icon: Icons.settings,
                  title: 'Settings',
                  isSelected: _isSelected('/settings'),
                  onTap: () => _navigateTo('/settings'),
                ),

                // Inventory
                _ExpandableDrawerItem(
                  icon: Icons.warehouse,
                  title: 'Inventory',
                  isExpanded: _expandedSections['inventory'] ?? false,
                  onToggle: () => _toggleSection('inventory'),
                  children: [
                    _DrawerSubItem(
                      icon: Icons.list_alt,
                      title: 'Inventory List',
                      onTap: () => _navigateTo('/inventory'),
                    ),
                    _DrawerSubItem(
                      icon: Icons.history,
                      title: 'Inventory Logs',
                      onTap: () => _navigateTo('/inventory/logs'),
                    ),
                  ],
                ),

                // Reports
                _ExpandableDrawerItem(
                  icon: Icons.bar_chart,
                  title: 'Reports',
                  isExpanded: _expandedSections['reports'] ?? false,
                  onToggle: () => _toggleSection('reports'),
                  children: [
                    _DrawerSubItem(
                      icon: Icons.trending_up,
                      title: 'Sales Report',
                      onTap: () => _navigateTo('/reports/sales'),
                    ),
                    _DrawerSubItem(
                      icon: Icons.shopping_bag,
                      title: 'Purchase Report',
                      onTap: () => _navigateTo('/reports/purchase'),
                    ),
                    _DrawerSubItem(
                      icon: Icons.analytics,
                      title: 'Item Sales Report',
                      onTap: () => _navigateTo('/reports/item-sales'),
                    ),
                  ],
                ),

                // Tax & Discount
                _ExpandableDrawerItem(
                  icon: Icons.local_offer,
                  title: 'Tax & Discount',
                  isExpanded: _expandedSections['tax_discount'] ?? false,
                  onToggle: () => _toggleSection('tax_discount'),
                  children: [
                    _DrawerSubItem(
                      icon: Icons.receipt,
                      title: 'Tax',
                      onTap: () => _navigateTo('/tax-discount/tax'),
                    ),
                    _DrawerSubItem(
                      icon: Icons.discount,
                      title: 'Discount',
                      onTap: () => _navigateTo('/tax-discount/discount'),
                    ),
                  ],
                ),

                // Premium Upgrade
                _DrawerItem(
                  icon: Icons.diamond,
                  title: 'Premium Upgrade',
                  iconColor: Colors.green,
                  textColor: Colors.green,
                  onTap: () => _navigateTo('/premium'),
                ),
              ],
            ),
          ),

          // Logout Button
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleLogout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final Color? iconColor;
  final Color? textColor;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    this.isSelected = false,
    this.iconColor,
    this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selectedColor = Theme.of(context).primaryColor;
    final defaultColor = Colors.black87;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? selectedColor
            : (iconColor ?? defaultColor),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected
              ? selectedColor
              : (textColor ?? defaultColor),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: selectedColor.withOpacity(0.1),
      onTap: onTap,
    );
  }
}

class _ExpandableDrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isExpanded;
  final VoidCallback onToggle;
  final List<Widget> children;

  const _ExpandableDrawerItem({
    required this.icon,
    required this.title,
    required this.isExpanded,
    required this.onToggle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon),
          title: Text(title),
          trailing: Icon(
            isExpanded ? Icons.expand_less : Icons.expand_more,
          ),
          onTap: onToggle,
        ),
        if (isExpanded) ...children,
      ],
    );
  }
}

class _DrawerSubItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerSubItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const SizedBox(width: 16),
      title: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 16),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}

