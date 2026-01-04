/// Report data models
class SalesReport {
  final DateTime date;
  final double totalSales;
  final int transactionCount;
  final double averageTransaction;
  final List<DailySales> dailyBreakdown;

  SalesReport({
    required this.date,
    required this.totalSales,
    required this.transactionCount,
    required this.averageTransaction,
    required this.dailyBreakdown,
  });
}

class DailySales {
  final DateTime date;
  final double amount;
  final int count;

  DailySales({
    required this.date,
    required this.amount,
    required this.count,
  });
}

class CustomerReport {
  final int totalCustomers;
  final int customersWithBalance;
  final double totalOutstanding;
  final double totalSpent;
  final List<TopCustomer> topCustomers;

  CustomerReport({
    required this.totalCustomers,
    required this.customersWithBalance,
    required this.totalOutstanding,
    required this.totalSpent,
    required this.topCustomers,
  });
}

class TopCustomer {
  final String customerId;
  final String customerName;
  final double totalSpent;
  final double balance;

  TopCustomer({
    required this.customerId,
    required this.customerName,
    required this.totalSpent,
    required this.balance,
  });
}

class ProductReport {
  final int totalProducts;
  final int lowStockProducts;
  final int outOfStockProducts;
  final double totalInventoryValue;
  final List<TopProduct> topProducts;

  ProductReport({
    required this.totalProducts,
    required this.lowStockProducts,
    required this.outOfStockProducts,
    required this.totalInventoryValue,
    required this.topProducts,
  });
}

class TopProduct {
  final String productId;
  final String productName;
  final int quantitySold;
  final double revenue;

  TopProduct({
    required this.productId,
    required this.productName,
    required this.quantitySold,
    required this.revenue,
  });
}

class FinancialReport {
  final double totalRevenue;
  final double totalCost;
  final double grossProfit;
  final double profitMargin;
  final double totalPayments;
  final double outstandingBalance;

  FinancialReport({
    required this.totalRevenue,
    required this.totalCost,
    required this.grossProfit,
    required this.profitMargin,
    required this.totalPayments,
    required this.outstandingBalance,
  });
}

