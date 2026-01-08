import '../models/report_model.dart';
import '../../customers/services/customer_service.dart';
import '../../customers/database/customer_database.dart';
import '../../customers/models/transaction_model.dart';
import '../../inventory/services/product_service.dart';

/// Service for generating various reports
class ReportService {
  final CustomerService _customerService = CustomerService();
  final ProductService _productService = ProductService();
  final CustomerDatabase _customerDB = CustomerDatabase.instance;

  /// Generate sales report for a date range
  Future<SalesReport> getSalesReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final end = endDate ?? DateTime.now();
      final start =
          startDate ??
          DateTime(
            end.year,
            end.month,
            end.day,
          ).subtract(const Duration(days: 30));

      // Get all transactions in date range
      final db = await _customerDB.database;
      final transactions = await db.query(
        'transactions',
        where: 'type = ? AND created_at >= ? AND created_at <= ?',
        whereArgs: ['debit', start.toIso8601String(), end.toIso8601String()],
        orderBy: 'created_at ASC',
      );

      double totalSales = 0.0;
      final Map<String, DailySales> dailyMap = {};

      for (var map in transactions) {
        final transaction = Transaction.fromMap(map);
        totalSales += transaction.amount;

        final dateKey = _getDateKey(transaction.createdAt);
        if (dailyMap.containsKey(dateKey)) {
          final existing = dailyMap[dateKey]!;
          dailyMap[dateKey] = DailySales(
            date: existing.date,
            amount: existing.amount + transaction.amount,
            count: existing.count + 1,
          );
        } else {
          dailyMap[dateKey] = DailySales(
            date: transaction.createdAt,
            amount: transaction.amount,
            count: 1,
          );
        }
      }

      final dailyBreakdown = dailyMap.values.toList()
        ..sort((a, b) => a.date.compareTo(b.date));

      return SalesReport(
        date: DateTime.now(),
        totalSales: totalSales,
        transactionCount: transactions.length,
        averageTransaction: transactions.isEmpty
            ? 0.0
            : totalSales / transactions.length,
        dailyBreakdown: dailyBreakdown,
      );
    } catch (e) {
      return SalesReport(
        date: DateTime.now(),
        totalSales: 0.0,
        transactionCount: 0,
        averageTransaction: 0.0,
        dailyBreakdown: [],
      );
    }
  }

  /// Generate customer report
  Future<CustomerReport> getCustomerReport() async {
    try {
      final customers = await _customerService.getAllCustomers();

      int customersWithBalance = 0;
      double totalOutstanding = 0.0;
      double totalSpent = 0.0;
      final List<TopCustomer> topCustomers = [];

      for (var customer in customers) {
        if (customer.balance > 0) {
          customersWithBalance++;
          totalOutstanding += customer.balance;
        }
        totalSpent += customer.totalSpent;

        topCustomers.add(
          TopCustomer(
            customerId: customer.id ?? '',
            customerName: customer.name,
            totalSpent: customer.totalSpent,
            balance: customer.balance,
          ),
        );
      }

      topCustomers.sort((a, b) => b.totalSpent.compareTo(a.totalSpent));

      return CustomerReport(
        totalCustomers: customers.length,
        customersWithBalance: customersWithBalance,
        totalOutstanding: totalOutstanding,
        totalSpent: totalSpent,
        topCustomers: topCustomers.take(10).toList(),
      );
    } catch (e) {
      return CustomerReport(
        totalCustomers: 0,
        customersWithBalance: 0,
        totalOutstanding: 0.0,
        totalSpent: 0.0,
        topCustomers: [],
      );
    }
  }

  /// Generate product report
  Future<ProductReport> getProductReport() async {
    try {
      final products = await _productService.getAllProducts();

      int lowStockProducts = 0;
      int outOfStockProducts = 0;
      double totalInventoryValue = 0.0;
      final List<TopProduct> topProducts = [];

      for (var product in products) {
        // Calculate inventory value (using cost price)
        // Note: Product model doesn't have stockQuantity, so we'll skip inventory calculations
        // totalInventoryValue += (product.costPrice * (product.stockQuantity ?? 0));

        // Note: Stock tracking not implemented in Product model yet
        // if ((product.stockQuantity ?? 0) == 0) {
        //   outOfStockProducts++;
        // } else if ((product.stockQuantity ?? 0) <= (product.lowStockThreshold ?? 10)) {
        //   lowStockProducts++;
        // }

        // For top products, we'd need sales data - simplified for now
        topProducts.add(
          TopProduct(
            productId: product.id ?? '',
            productName: product.name,
            quantitySold: 0, // Would need to track from sales
            revenue: 0.0, // Would need to track from sales
          ),
        );
      }

      return ProductReport(
        totalProducts: products.length,
        lowStockProducts: lowStockProducts,
        outOfStockProducts: outOfStockProducts,
        totalInventoryValue: totalInventoryValue,
        topProducts: topProducts.take(10).toList(),
      );
    } catch (e) {
      return ProductReport(
        totalProducts: 0,
        lowStockProducts: 0,
        outOfStockProducts: 0,
        totalInventoryValue: 0.0,
        topProducts: [],
      );
    }
  }

  /// Generate financial report
  Future<FinancialReport> getFinancialReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final end = endDate ?? DateTime.now();
      final start =
          startDate ??
          DateTime(
            end.year,
            end.month,
            end.day,
          ).subtract(const Duration(days: 30));

      // Get revenue from debit transactions
      final db = await _customerDB.database;
      final debitTransactions = await db.query(
        'transactions',
        where: 'type = ? AND created_at >= ? AND created_at <= ?',
        whereArgs: ['debit', start.toIso8601String(), end.toIso8601String()],
      );

      double totalRevenue = 0.0;
      for (var map in debitTransactions) {
        totalRevenue += (map['amount'] as num).toDouble();
      }

      // Get payments from credit transactions
      final creditTransactions = await db.query(
        'transactions',
        where: 'type = ? AND created_at >= ? AND created_at <= ?',
        whereArgs: ['credit', start.toIso8601String(), end.toIso8601String()],
      );

      double totalPayments = 0.0;
      for (var map in creditTransactions) {
        totalPayments += (map['amount'] as num).toDouble();
      }

      // Calculate cost (simplified - would need to track actual cost per sale)
      final products = await _productService.getAllProducts();
      double totalCost = 0.0;
      // This is a simplified calculation - in reality, you'd track cost per transaction
      // For now, we'll estimate based on average cost price
      if (products.isNotEmpty) {
        // Rough estimate: assume 60% of revenue is cost
        totalCost = totalRevenue * 0.6;
      }

      final grossProfit = totalRevenue - totalCost;
      final profitMargin = totalRevenue > 0
          ? (grossProfit / totalRevenue) * 100
          : 0.0;

      // Get outstanding balance
      final customers = await _customerService.getAllCustomers();
      double outstandingBalance = 0.0;
      for (var customer in customers) {
        if (customer.balance > 0) {
          outstandingBalance += customer.balance;
        }
      }

      return FinancialReport(
        totalRevenue: totalRevenue,
        totalCost: totalCost,
        grossProfit: grossProfit,
        profitMargin: profitMargin,
        totalPayments: totalPayments,
        outstandingBalance: outstandingBalance,
      );
    } catch (e) {
      return FinancialReport(
        totalRevenue: 0.0,
        totalCost: 0.0,
        grossProfit: 0.0,
        profitMargin: 0.0,
        totalPayments: 0.0,
        outstandingBalance: 0.0,
      );
    }
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
