import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'routes.dart';
import '../auth/auth_service.dart';

/// Dashboard screen with modern mobile design
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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

    if (confirm == true) {
      try {
        await AuthService.signOut();
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error logging out: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      drawer: _buildDrawer(context, user),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFF1A1A1A)),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_none, color: Color(0xFF1A1A1A), size: 20),
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.email?.split('@')[0] ?? 'Welcome',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Manage your business efficiently',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // Quick Stats Cards
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Today\'s Sales',
                      '\$0',
                      Icons.attach_money,
                      const Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Products',
                      '0',
                      Icons.inventory_2,
                      const Color(0xFF2196F3),
                    ),
                  ),
                ],
              ),
            ),

            // Menu Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Access',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.1,
                    children: [
                      _buildMenuCard(
                        context,
                        title: 'Point of Sale',
                        icon: Icons.point_of_sale,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                        ),
                        route: AppRoutes.pos,
                      ),
                      _buildMenuCard(
                        context,
                        title: 'Inventory',
                        icon: Icons.inventory_2,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
                        ),
                        route: AppRoutes.inventory,
                      ),
                      _buildMenuCard(
                        context,
                        title: 'Customers',
                        icon: Icons.people,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
                        ),
                        route: AppRoutes.customers,
                      ),
                      _buildMenuCard(
                        context,
                        title: 'Reports',
                        icon: Icons.assessment,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
                        ),
                        route: AppRoutes.reports,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildMenuCard(
                    context,
                    title: 'Sync Data',
                    icon: Icons.sync,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
                    ),
                    route: AppRoutes.sync,
                    isFullWidth: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, User? user) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Drawer Header
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.email?.split('@')[0] ?? 'User',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (user?.email != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          user!.email!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(color: Colors.white24),
              
              // Menu Items
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _buildDrawerItem(
                        context,
                        icon: Icons.dashboard,
                        title: 'Dashboard',
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      _buildDrawerItem(
                        context,
                        icon: Icons.point_of_sale,
                        title: 'Point of Sale',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, AppRoutes.pos);
                        },
                      ),
                      _buildDrawerItem(
                        context,
                        icon: Icons.inventory_2,
                        title: 'Inventory',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, AppRoutes.inventory);
                        },
                      ),
                      _buildDrawerItem(
                        context,
                        icon: Icons.people,
                        title: 'Customers',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, AppRoutes.customers);
                        },
                      ),
                      _buildDrawerItem(
                        context,
                        icon: Icons.assessment,
                        title: 'Reports',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, AppRoutes.reports);
                        },
                      ),
                      _buildDrawerItem(
                        context,
                        icon: Icons.sync,
                        title: 'Sync Data',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, AppRoutes.sync);
                        },
                      ),
                      const Divider(),
                      _buildDrawerItem(
                        context,
                        icon: Icons.logout,
                        title: 'Logout',
                        textColor: Colors.red,
                        iconColor: Colors.red,
                        onTap: () {
                          Navigator.pop(context);
                          _handleLogout(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? const Color(0xFF1A1A1A)),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? const Color(0xFF1A1A1A),
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Gradient gradient,
    required String route,
    bool isFullWidth = false,
  }) {
    return Container(
      height: isFullWidth ? 80 : null,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, route),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(20),
            child: isFullWidth
                ? Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.sync, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Sync Data',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: Colors.white, size: 32),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
