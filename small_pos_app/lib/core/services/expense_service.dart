import '../database/expense_database.dart';
import '../models/expense_model.dart';

/// Service for expense management
class ExpenseService {
  final ExpenseDatabase _db = ExpenseDatabase.instance;

  Future<String> addExpense(Expense expense) async {
    return await _db.createExpense(expense);
  }

  Future<List<Expense>> getAllExpenses({DateTime? startDate, DateTime? endDate}) async {
    return await _db.getAllExpenses(startDate: startDate, endDate: endDate);
  }

  Future<Expense?> getExpenseById(String id) async {
    return await _db.getExpenseById(id);
  }

  Future<void> updateExpense(Expense expense) async {
    await _db.updateExpense(expense);
  }

  Future<void> deleteExpense(String id) async {
    await _db.deleteExpense(id);
  }

  Future<List<String>> getCategories() async {
    return await _db.getCategories();
  }

  Future<double> getTotalExpenses({DateTime? startDate, DateTime? endDate}) async {
    return await _db.getTotalExpenses(startDate: startDate, endDate: endDate);
  }
}

