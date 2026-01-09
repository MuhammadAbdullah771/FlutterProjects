import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../../core/database/settings_database.dart';
import '../../core/screens/qr_scanner_screen.dart';

/// Add/Edit product screen matching the design
class AddEditProductScreen extends StatefulWidget {
  final Product? product;

  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productService = ProductService();
  final _skuController = TextEditingController();
  final _nameController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _categoryController = TextEditingController();
  final _quantityController = TextEditingController();
  final _lowStockController = TextEditingController();

  File? _productImage;
  List<String> _categories = [];
  String? _selectedCategory;
  bool _trackStock = false;
  final ImagePicker _imagePicker = ImagePicker();
  String _currencySymbol = '\$';

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadCurrencySymbol();
    
    if (widget.product != null) {
      _skuController.text = widget.product!.sku;
      _nameController.text = widget.product!.name;
      _sellingPriceController.text = widget.product!.sellingPrice.toStringAsFixed(2);
      _costPriceController.text = widget.product!.costPrice.toStringAsFixed(2);
      _categoryController.text = widget.product!.category;
      _selectedCategory = widget.product!.category;
      _trackStock = widget.product!.stockQuantity != null;
      _quantityController.text = widget.product!.stockQuantity?.toString() ?? '0';
      _lowStockController.text = widget.product!.lowStockThreshold?.toString() ?? '5';
      // Load existing image if available
      _loadExistingImage();
    } else {
      _quantityController.text = '0';
      _lowStockController.text = '5';
    }
  }

  Future<void> _loadExistingImage() async {
    if (widget.product?.imagePath != null) {
      final imageFile = File(widget.product!.imagePath!);
      if (await imageFile.exists()) {
        setState(() {
          _productImage = imageFile;
        });
      }
    }
  }

  @override
  void dispose() {
    _skuController.dispose();
    _nameController.dispose();
    _sellingPriceController.dispose();
    _costPriceController.dispose();
    _categoryController.dispose();
    _quantityController.dispose();
    _lowStockController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrencySymbol() async {
    try {
      final settings = await SettingsDatabase.instance.getSettings();
      setState(() {
        _currencySymbol = settings.currencySymbol;
      });
    } catch (e) {
      // Use default
    }
  }

  Future<void> _loadCategories() async {
    final categories = await _productService.getCategories();
    setState(() {
      _categories = categories;
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _productImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<String?> _saveImageToPersistentStorage(File? imageFile, String productSku) async {
    if (imageFile == null || !await imageFile.exists()) {
      return null;
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagesDirectory = Directory(path.join(directory.path, 'product_images'));
      if (!await imagesDirectory.exists()) {
        await imagesDirectory.create(recursive: true);
      }

      final extension = path.extension(imageFile.path);
      final fileName = '${productSku}_${DateTime.now().millisecondsSinceEpoch}$extension';
      final savedImagePath = path.join(imagesDirectory.path, fileName);
      final savedImage = await imageFile.copy(savedImagePath);
      
      return savedImage.path;
    } catch (e) {
      print('Error saving image: $e');
      return null;
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Quick validation without loading indicator
    try {
      final sku = _skuController.text.trim().toUpperCase();
      String? savedImagePath;

      // Save image in background if needed (non-blocking for new products)
      if (_productImage != null) {
        if (widget.product == null || _productImage!.path != widget.product!.imagePath) {
          // For new products, save image in background
          if (widget.product == null) {
            // Quick save first, then update image path
            savedImagePath = null; // Will be updated after save
            _saveImageToPersistentStorage(_productImage, sku).then((path) {
              if (path != null && mounted) {
                // Update product with image path in background
                _productService.getProductBySku(sku).then((product) {
                  if (product != null) {
                    _productService.updateProduct(product.copyWith(imagePath: path));
                  }
                });
              }
            });
          } else {
            savedImagePath = await _saveImageToPersistentStorage(_productImage, sku);
          }
        } else {
          savedImagePath = widget.product!.imagePath;
        }
      } else if (widget.product != null) {
        savedImagePath = widget.product!.imagePath;
      }

      final product = Product(
        id: widget.product?.id,
        sku: sku,
        name: _nameController.text.trim(),
        sellingPrice: double.parse(_sellingPriceController.text),
        costPrice: double.parse(_costPriceController.text),
        category: _selectedCategory ?? _categoryController.text.trim(),
        stockQuantity: _trackStock ? int.tryParse(_quantityController.text) : null,
        lowStockThreshold: _trackStock ? int.tryParse(_lowStockController.text) : null,
        imagePath: savedImagePath,
      );

      if (widget.product == null) {
        // Quick SKU check
        final existing = await _productService.getProductBySku(product.sku);
        if (existing != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Product with this SKU already exists')),
            );
          }
          return;
        }

        // Quick save - no loading indicator
        await _productService.createProduct(product);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product created successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1),
            ),
          );
          Navigator.pop(context, true); // Return true to refresh list
        }
      } else {
        // Update product
        await _productService.updateProduct(product);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product updated successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1),
            ),
          );
          Navigator.pop(context, true); // Return true to refresh list
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.product == null ? 'Add Product' : 'Edit Product',
          style: const TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Image Upload Area
              Container(
                margin: const EdgeInsets.all(16),
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: InkWell(
                  onTap: _pickImage,
                  borderRadius: BorderRadius.circular(12),
                  child: _productImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _productImage!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2196F3),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Tap to upload image',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              // Basic Information Section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Basic Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Product Name
                    const Text(
                      'Product Name',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'e.g., Coca Cola 500ml',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter product name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Category
                    const Text(
                      'Category',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_categories.isNotEmpty)
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          hintText: 'Select Category',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF5F5F5),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        ),
                        items: [
                          ..._categories.map((category) => DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              )),
                          const DropdownMenuItem(
                            value: '__new__',
                            child: Text('+ Add New Category'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == '__new__') {
                            _showAddCategoryDialog();
                          } else {
                            setState(() {
                              _selectedCategory = value;
                              _categoryController.text = value ?? '';
                            });
                          }
                        },
                      )
                    else
                      TextFormField(
                        controller: _categoryController,
                        decoration: InputDecoration(
                          hintText: 'Select Category',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF5F5F5),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter category';
                          }
                          return null;
                        },
                      ),
                    const SizedBox(height: 16),

                    // SKU / Barcode
                    const Text(
                      'SKU / Barcode',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _skuController,
                      decoration: InputDecoration(
                        hintText: 'Scan or enter code',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.qr_code_scanner, color: Color(0xFF2196F3)),
                          onPressed: () async {
                            final result = await Navigator.push<String>(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const QRScannerScreen(),
                              ),
                            );
                            if (result != null && mounted) {
                              setState(() {
                                _skuController.text = result;
                              });
                            }
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                      textCapitalization: TextCapitalization.characters,
                      enabled: widget.product == null,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter SKU';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Pricing Section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pricing',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Selling Price
                    const Text(
                      'Selling Price',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _sellingPriceController,
                      decoration: InputDecoration(
                        hintText: '0.00',
                        prefixText: '$_currencySymbol ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Cost Price
                    const Text(
                      'Cost Price',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _costPriceController,
                      decoration: InputDecoration(
                        hintText: '0.00',
                        prefixText: '$_currencySymbol ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Inventory Section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Inventory',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Track Stock Toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Track Stock',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Enable stock management',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: _trackStock,
                          onChanged: (value) {
                            setState(() {
                              _trackStock = value;
                            });
                          },
                          activeColor: const Color(0xFF2196F3),
                        ),
                      ],
                    ),

                    if (_trackStock) ...[
                      const SizedBox(height: 16),
                      // Quantity
                      const Text(
                        'Quantity',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _quantityController,
                        decoration: InputDecoration(
                          hintText: '0',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF5F5F5),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (_trackStock && (value == null || value.isEmpty)) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Low Stock Alert
                      const Text(
                        'Low Stock Alert',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _lowStockController,
                        decoration: InputDecoration(
                          hintText: '5',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF5F5F5),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (_trackStock && (value == null || value.isEmpty)) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Save Product Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  onPressed: _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    widget.product == null ? 'Save Product' : 'Update Product',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddCategoryDialog() {
    final categoryController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Category'),
        content: TextField(
          controller: categoryController,
          decoration: const InputDecoration(
            hintText: 'Category name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (categoryController.text.isNotEmpty) {
                setState(() {
                  _selectedCategory = categoryController.text.trim();
                  _categoryController.text = categoryController.text.trim();
                  _categories.add(categoryController.text.trim());
                  _categories.sort();
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
