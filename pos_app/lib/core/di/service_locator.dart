import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../data/datasources/local_storage_datasource.dart';
import '../../data/database/database_helper.dart';
import '../../data/daos/product_dao.dart';
import '../../data/daos/category_dao.dart';
import '../../data/daos/inventory_transaction_dao.dart';
import '../../data/repositories/supabase_auth_repository.dart';
import '../../data/repositories/local_product_repository.dart';
import '../../data/repositories/remote_product_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/providers/product_provider.dart';

/// Service Locator / Dependency Injection container
/// This class manages all dependencies and provides a single place to configure them
/// This makes it easy to swap implementations (e.g., swap Supabase for another backend)
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();
  
  // Lazy initialization variables
  SharedPreferences? _sharedPreferences;
  LocalStorageDataSource? _localStorageDataSource;
  supabase.SupabaseClient? _supabaseClient;
  AuthRepository? _authRepository;
  AuthProvider? _authProvider;
  
  // Product management dependencies
  DatabaseHelper? _databaseHelper;
  ProductDao? _productDao;
  CategoryDao? _categoryDao;
  InventoryTransactionDao? _inventoryTransactionDao;
  ProductRepository? _productRepository;
  ProductProvider? _productProvider;
  
  /// Initializes all dependencies
  /// This must be called before using any services
  Future<void> initialize() async {
    // Initialize SharedPreferences for local storage
    _sharedPreferences = await SharedPreferences.getInstance();
    
    // Initialize LocalStorageDataSource
    _localStorageDataSource = LocalStorageDataSource(_sharedPreferences!);
    
    // Initialize Supabase client
    // IMPORTANT: Replace AppConstants values with your actual Supabase credentials
    await supabase.Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );
    _supabaseClient = supabase.Supabase.instance.client;
    
    // Initialize AuthRepository (Supabase implementation)
    _authRepository = SupabaseAuthRepository(
      supabase: _supabaseClient!,
      localStorage: _localStorageDataSource!,
    );
    
    // Initialize AuthProvider
    _authProvider = AuthProvider(_authRepository!);
    
    // Initialize auth state (check for existing session)
    await _authProvider!.initialize();
    
    // Initialize database helper
    _databaseHelper = DatabaseHelper();
    await _databaseHelper!.database; // Initialize database
    
    // Initialize DAOs
    _productDao = ProductDao();
    _categoryDao = CategoryDao();
    _inventoryTransactionDao = InventoryTransactionDao();
    
    // Initialize ProductRepository (using local repository for offline-first)
    _productRepository = LocalProductRepository(
      productDao: _productDao!,
      transactionDao: _inventoryTransactionDao!,
    );
    
    // Initialize ProductProvider
    _productProvider = ProductProvider(_productRepository!);
  }
  
  /// Gets the AuthProvider instance
  /// Throws an error if not initialized
  AuthProvider get authProvider {
    if (_authProvider == null) {
      throw Exception(
        'ServiceLocator not initialized. Call initialize() first.',
      );
    }
    return _authProvider!;
  }
  
  /// Gets the AuthRepository instance
  /// Throws an error if not initialized
  AuthRepository get authRepository {
    if (_authRepository == null) {
      throw Exception(
        'ServiceLocator not initialized. Call initialize() first.',
      );
    }
    return _authRepository!;
  }
  
  /// Gets the SupabaseClient instance
  /// Throws an error if not initialized
  supabase.SupabaseClient get supabaseClient {
    if (_supabaseClient == null) {
      throw Exception(
        'ServiceLocator not initialized. Call initialize() first.',
      );
    }
    return _supabaseClient!;
  }
  
  /// Gets the ProductProvider instance
  /// Throws an error if not initialized
  ProductProvider get productProvider {
    if (_productProvider == null) {
      throw Exception(
        'ServiceLocator not initialized. Call initialize() first.',
      );
    }
    return _productProvider!;
  }

  /// Gets the ProductRepository instance
  /// Throws an error if not initialized
  ProductRepository get productRepository {
    if (_productRepository == null) {
      throw Exception(
        'ServiceLocator not initialized. Call initialize() first.',
      );
    }
    return _productRepository!;
  }

  /// Gets the DatabaseHelper instance
  DatabaseHelper get databaseHelper {
    if (_databaseHelper == null) {
      throw Exception(
        'ServiceLocator not initialized. Call initialize() first.',
      );
    }
    return _databaseHelper!;
  }

  /// Resets all dependencies (useful for testing)
  void reset() {
    _sharedPreferences = null;
    _localStorageDataSource = null;
    _supabaseClient = null;
    _authRepository = null;
    _authProvider = null;
    _databaseHelper = null;
    _productDao = null;
    _categoryDao = null;
    _inventoryTransactionDao = null;
    _productRepository = null;
    _productProvider = null;
  }
}

