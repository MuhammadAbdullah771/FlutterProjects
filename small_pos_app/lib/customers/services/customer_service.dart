import 'package:supabase_flutter/supabase_flutter.dart';
import '../database/customer_database.dart';
import '../models/customer_model.dart';
import '../models/transaction_model.dart';

/// Service layer for customer and transaction management
class CustomerService {
  final CustomerDatabase _localDB = CustomerDatabase.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  // Customer operations
  Future<String> addCustomer(Customer customer) async {
    try {
      // Add to local database first (offline-first)
      final id = await _localDB.insertCustomer(customer);

      // Sync to Supabase in background
      _syncCustomerToSupabase(customer.copyWith(id: id)).catchError((e) {
        print('Error syncing customer to Supabase: $e');
      });

      return id;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Customer>> getAllCustomers() async {
    try {
      return await _localDB.getAllCustomers();
    } catch (e) {
      return [];
    }
  }

  Future<Customer?> getCustomerById(String id) async {
    try {
      return await _localDB.getCustomerById(id);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateCustomer(Customer customer) async {
    try {
      await _localDB.updateCustomer(customer);

      // Sync to Supabase in background
      _syncCustomerToSupabase(customer).catchError((e) {
        print('Error syncing customer to Supabase: $e');
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCustomer(String id) async {
    try {
      await _localDB.deleteCustomer(id);

      // Delete from Supabase in background
      try {
        await _supabase.from('customers').delete().eq('id', id);
      } catch (e) {
        print('Error deleting customer from Supabase: $e');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Transaction/Ledger operations
  Future<String> addTransaction(Transaction transaction) async {
    try {
      // Add transaction to local database
      final id = await _localDB.insertTransaction(transaction);

      // Sync to Supabase in background
      _syncTransactionToSupabase(transaction.copyWith(id: id)).catchError((e) {
        print('Error syncing transaction to Supabase: $e');
      });

      return id;
    } catch (e) {
      rethrow;
    }
  }

  /// Record a debit (sale/invoice) - customer owes money
  Future<String> recordDebit({
    required String customerId,
    required double amount,
    String? description,
    String? reference,
  }) async {
    final transaction = Transaction(
      customerId: customerId,
      type: TransactionType.debit,
      amount: amount,
      description: description ?? 'Sale',
      reference: reference,
    );

    return await addTransaction(transaction);
  }

  /// Record a credit (payment) - customer paid money
  Future<String> recordCredit({
    required String customerId,
    required double amount,
    PaymentMethod? paymentMethod,
    String? description,
    String? reference,
  }) async {
    final transaction = Transaction(
      customerId: customerId,
      type: TransactionType.credit,
      amount: amount,
      description: description ?? 'Payment',
      reference: reference,
      paymentMethod: paymentMethod ?? PaymentMethod.cash,
    );

    return await addTransaction(transaction);
  }

  /// Record a payment - wrapper for recordCredit
  Future<String> recordPayment({
    required String customerId,
    required double amount,
    PaymentMethod paymentMethod = PaymentMethod.cash,
    String? description,
    String? reference,
  }) async {
    return await recordCredit(
      customerId: customerId,
      amount: amount,
      paymentMethod: paymentMethod,
      description: description ?? 'Payment received',
      reference: reference,
    );
  }

  Future<List<Transaction>> getCustomerTransactions(String customerId, {int? limit}) async {
    try {
      return await _localDB.getTransactionsByCustomerId(customerId, limit: limit);
    } catch (e) {
      return [];
    }
  }

  Future<Transaction?> getTransactionById(String id) async {
    try {
      return await _localDB.getTransactionById(id);
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await _localDB.deleteTransaction(id);

      // Delete from Supabase in background
      try {
        await _supabase.from('transactions').delete().eq('id', id);
      } catch (e) {
        print('Error deleting transaction from Supabase: $e');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<double> getCustomerBalance(String customerId) async {
    try {
      return await _localDB.getCustomerBalance(customerId);
    } catch (e) {
      return 0.0;
    }
  }

  // Sync operations
  Future<void> _syncCustomerToSupabase(Customer customer) async {
    try {
      final response = await _supabase
          .from('customers')
          .upsert(customer.toSupabaseMap())
          .select()
          .single();

      // Update local record with synced status
      final syncedCustomer = customer.copyWith(
        id: response['id']?.toString() ?? customer.id,
        isSynced: true,
      );
      await _localDB.updateCustomer(syncedCustomer);
    } catch (e) {
      print('Error syncing customer: $e');
      rethrow;
    }
  }

  Future<void> _syncTransactionToSupabase(Transaction transaction) async {
    try {
      final response = await _supabase
          .from('transactions')
          .upsert(transaction.toSupabaseMap())
          .select()
          .single();

      // Note: Transaction sync status update would require a separate field
      // For now, we'll just sync and assume success
    } catch (e) {
      print('Error syncing transaction: $e');
      rethrow;
    }
  }

  // Sync all pending customers and transactions
  Future<void> syncAll() async {
    try {
      final customers = await _localDB.getAllCustomers();
      for (var customer in customers) {
        if (!customer.isSynced) {
          await _syncCustomerToSupabase(customer);
        }
      }

      // Sync transactions (simplified - would need to track sync status)
      // For now, this is a placeholder
    } catch (e) {
      print('Error syncing all: $e');
      rethrow;
    }
  }
}

