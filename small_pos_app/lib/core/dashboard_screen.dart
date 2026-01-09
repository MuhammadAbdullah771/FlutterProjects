import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'routes.dart';
import '../core/widgets/bottom_nav_bar.dart';
import '../core/database/settings_database.dart';
import '../inventory/services/product_service.dart';
import '../customers/services/customer_service.dart';
import 'services/notification_service.dart';
import '../customers/models/transaction_model.dart';
import '../core/services/expense_service.dart';
import '../core/models/expense_model.dart';

/// Dashboard screen matching the attached design
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ProductService _productService = ProductService();
  final CustomerService _customerService = CustomerService();
  final ExpenseService _expenseService = ExpenseService();
  String _currencySymbol = '\$';
  int _totalProducts = 0;
  int _lowStockCount = 0;
  double _creditDue = 0.0;
  double _todaySales = 0.0;
  double _todayExpenses = 0.0;
  bool _isLoading = true;
  List<Transaction> _recentTransactions = [];
  List<Expense> _recentExpenses = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final settings = await SettingsDatabase.instance.getSettings();
      final products = await _productService.getAllProducts();
      final customers = await _customerService.getAllCustomers();
      
      final lowStock = products.where((p) => p.isLowStock).toList();
      final creditDue = customers.fold(0.0, (sum, c) => sum + (c.balance > 0 ? c.balance : 0));
      final todaySales = await _customerService.getTodaySales();
      final recentTransactions = await _customerService.getRecentTransactions(limit: 3);
      
      // Load today's expenses
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);
      final todayExpenses = await _expenseService.getAllExpenses(
        startDate: startOfDay,
        endDate: endOfDay,
      );
      final totalTodayExpenses = todayExpenses.fold(0.0, (sum, e) => sum + e.amount);
      final recentExpenses = todayExpenses.take(3).toList();
      
      setState(() {
        _currencySymbol = settings.currencySymbol;
        _totalProducts = products.length;
        _lowStockCount = lowStock.length;
        _creditDue = creditDue;
        _todaySales = todaySales;
        _todayExpenses = totalTodayExpenses;
        _recentTransactions = recentTransactions;
        _recentExpenses = recentExpenses;
        _isLoading = false;
      });
      
      // Check and notify for low stock products
      if (lowStock.isNotEmpty) {
        await NotificationService.instance.checkLowStockAndNotify(products);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onNavTap(int index) {
    switch (index) {
      case 0:
        // Already on dashboard, just refresh
        _loadData();
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppRoutes.pos);
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
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    
    if (_isLoading) {
      return Scaffold(
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                children: [
                  // User Avatar
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.grey[300],
                        child: const Icon(Icons.person, color: Colors.grey),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  // Welcome Message
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.email?.split('@')[0] ?? 'Green Valley Market',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Notification Bell
                  Stack(
                    children: [
                      IconButton(
                        icon: Icon(
                          _lowStockCount > 0
                              ? Icons.notifications
                              : Icons.notifications_none,
                          color: const Color(0xFF1A1A1A),
                        ),
                        onPressed: () {
                          // Navigate to notifications screen
                          Navigator.pushNamed(context, '/notifications');
                        },
                      ),
                      if (_lowStockCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Total Sales Today Card
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Sales Today',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.attach_money,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '$_currencySymbol${_todaySales.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.arrow_upward, color: Colors.white, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  '+12% vs yesterday',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Summary Cards
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              icon: Icons.inventory_2,
                              iconColor: const Color(0xFF2196F3),
                              title: 'Total Products',
                              value: '$_totalProducts',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSummaryCard(
                              icon: Icons.warning,
                              iconColor: const Color(0xFFFF9800),
                              title: 'Low Stock',
                              value: '$_lowStockCount Items',
                              accentColor: const Color(0xFFFF9800),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSummaryCard(
                              icon: Icons.wallet,
                              iconColor: const Color(0xFF9C27B0),
                              title: 'Credit Due',
                              value: '$_currencySymbol${_creditDue.toStringAsFixed(2)}',
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Quick Actions
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: const Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildQuickAction(
                            context,
                            icon: Icons.add_shopping_cart,
                            label: 'New Sale',
                            color: const Color(0xFF2196F3),
                            route: AppRoutes.pos,
                          ),
                          _buildQuickAction(
                            context,
                            icon: Icons.add_box,
                            label: 'Add Product',
                            color: const Color(0xFF1A1A1A),
                            route: AppRoutes.inventory,
                          ),
                          _buildQuickAction(
                            context,
                            icon: Icons.keyboard_return,
                            label: 'Returns',
                            color: const Color(0xFF1A1A1A),
                            route: AppRoutes.returns,
                          ),
                          _buildQuickAction(
                            context,
                            icon: Icons.receipt,
                            label: 'Expenses',
                            color: const Color(0xFF1A1A1A),
                            route: AppRoutes.expenses,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Today's Expenses Card (if any)
                    if (_todayExpenses > 0)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.receipt, color: Colors.orange.shade700),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Today\'s Expenses',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.orange.shade900,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$_currencySymbol${_todayExpenses.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange.shade900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, AppRoutes.expenses);
                              },
                              child: const Text('View'),
                            ),
                          ],
                        ),
                      ),

                    if (_todayExpenses > 0) const SizedBox(height: 24),

                    // Recent Activity
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Recent Activity',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, AppRoutes.reports);
                            },
                            child: const Text(
                              'View All',
                              style: TextStyle(color: Color(0xFF2196F3)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _recentTransactions.isEmpty && _recentExpenses.isEmpty
                          ? Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(Icons.receipt_long, size: 48, color: Colors.grey[400]),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No recent activity',
                                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Column(
                              children: [
                                // Show recent transactions
                                ..._recentTransactions.map((transaction) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _buildTransactionActivityCard(transaction),
                                  );
                                }).toList(),
                                // Show recent expenses
                                ..._recentExpenses.map((expense) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _buildExpenseActivityCard(expense),
                                  );
                                }).toList(),
                              ],
                            ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    Color? accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: accentColor != null
            ? Border(
                right: BorderSide(color: accentColor, width: 3),
              )
            : null,
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
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    String? route,
  }) {
    return InkWell(
      onTap: route != null
          ? () => Navigator.pushNamed(context, route)
          : () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$label coming soon')),
              );
            },
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionActivityCard(Transaction transaction) {
    // Get icon and color based on transaction type
    IconData icon;
    Color iconColor;
    String status;
    Color statusColor;
    
    if (transaction.type == TransactionType.debit) {
      icon = Icons.shopping_bag;
      iconColor = const Color(0xFF4CAF50);
      status = 'Sale';
      statusColor = const Color(0xFF4CAF50);
    } else {
      icon = Icons.payment;
      iconColor = const Color(0xFF2196F3);
      status = 'Payment';
      statusColor = const Color(0xFF2196F3);
    }
    
    // Format date
    String dateStr = _formatActivityDate(transaction.createdAt);
    
    // Get reference or description
    String title = transaction.reference ?? transaction.description ?? 'Transaction';
    if (title.startsWith('Sale: ')) {
      title = title.replaceFirst('Sale: ', '');
      if (title.length > 30) {
        title = '${title.substring(0, 30)}...';
      }
    }
    
    return _buildActivityCard(
      icon: icon,
      iconColor: iconColor,
      title: title,
      subtitle: dateStr,
      amount: '${_currencySymbol}${transaction.amount.toStringAsFixed(2)}',
      status: status,
      statusColor: statusColor,
    );
  }

  String _formatActivityDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    if (dateOnly == today) {
      final hours = date.hour;
      final minutes = date.minute.toString().padLeft(2, '0');
      final amPm = hours >= 12 ? 'PM' : 'AM';
      final displayHour = hours > 12 ? hours - 12 : (hours == 0 ? 12 : hours);
      return 'Today, $displayHour:$minutes $amPm';
    } else if (dateOnly == yesterday) {
      final hours = date.hour;
      final minutes = date.minute.toString().padLeft(2, '0');
      final amPm = hours >= 12 ? 'PM' : 'AM';
      final displayHour = hours > 12 ? hours - 12 : (hours == 0 ? 12 : hours);
      return 'Yesterday, $displayHour:$minutes $amPm';
    } else {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    }
  }

  Widget _buildActivityCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String amount,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                status,
                style: TextStyle(
                  fontSize: 12,
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseActivityCard(Expense expense) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.receipt, color: Colors.orange, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.description,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      expense.category,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatActivityDate(expense.date),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_currencySymbol}${expense.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Expense',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
