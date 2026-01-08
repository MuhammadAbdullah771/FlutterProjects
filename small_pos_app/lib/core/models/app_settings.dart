/// App settings model for storing user preferences
class AppSettings {
  final String? id;
  final String currencySymbol;
  final String currencyCode;
  final double defaultTaxRate;
  final bool isDarkMode;
  final String storeName;
  final String? storeAddress;
  final String? storePhone;
  final DateTime? updatedAt;

  AppSettings({
    this.id,
    this.currencySymbol = '\$',
    this.currencyCode = 'USD',
    this.defaultTaxRate = 5.0,
    this.isDarkMode = false,
    this.storeName = 'My Store',
    this.storeAddress,
    this.storePhone,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id ?? 'settings',
      'currency_symbol': currencySymbol,
      'currency_code': currencyCode,
      'default_tax_rate': defaultTaxRate,
      'is_dark_mode': isDarkMode ? 1 : 0,
      'store_name': storeName,
      'store_address': storeAddress,
      'store_phone': storePhone,
      'updated_at': updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      id: map['id']?.toString(),
      currencySymbol: map['currency_symbol'] ?? '\$',
      currencyCode: map['currency_code'] ?? 'USD',
      defaultTaxRate: (map['default_tax_rate'] ?? 5.0).toDouble(),
      isDarkMode: (map['is_dark_mode'] ?? 0) == 1,
      storeName: map['store_name'] ?? 'My Store',
      storeAddress: map['store_address'],
      storePhone: map['store_phone'],
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  AppSettings copyWith({
    String? id,
    String? currencySymbol,
    String? currencyCode,
    double? defaultTaxRate,
    bool? isDarkMode,
    String? storeName,
    String? storeAddress,
    String? storePhone,
    DateTime? updatedAt,
  }) {
    return AppSettings(
      id: id ?? this.id,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      currencyCode: currencyCode ?? this.currencyCode,
      defaultTaxRate: defaultTaxRate ?? this.defaultTaxRate,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      storeName: storeName ?? this.storeName,
      storeAddress: storeAddress ?? this.storeAddress,
      storePhone: storePhone ?? this.storePhone,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

