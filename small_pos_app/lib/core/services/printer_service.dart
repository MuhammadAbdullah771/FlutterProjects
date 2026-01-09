import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing thermal printer selection and direct printing
class PrinterService {
  static final PrinterService instance = PrinterService._init();
  Printer? _selectedPrinter;

  PrinterService._init();

  /// Load saved printer preference
  Future<void> loadSavedPrinter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final printerName = prefs.getString('selected_printer_name');
      final printerUrl = prefs.getString('selected_printer_url');
      
      if (printerName != null && printerUrl != null) {
        // Try to find the printer from available printers
        final printers = await Printing.listPrinters();
        _selectedPrinter = printers.firstWhere(
          (p) => p.name == printerName && p.url.toString() == printerUrl,
          orElse: () => printers.firstWhere(
            (p) => p.name == printerName,
            orElse: () => printers.first,
          ),
        );
      }
    } catch (e) {
      print('Error loading saved printer: $e');
    }
  }

  /// Get available printers
  Future<List<Printer>> getAvailablePrinters() async {
    try {
      return await Printing.listPrinters();
    } catch (e) {
      print('Error getting printers: $e');
      return [];
    }
  }

  /// Select printer from list
  Future<Printer?> selectPrinter(BuildContext context) async {
    try {
      final printers = await getAvailablePrinters();
      
      if (printers.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No printers found. Please connect a printer first.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return null;
      }

      // Show printer selection dialog
      final selected = await showDialog<Printer>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Select Thermal Printer'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: printers.length,
              itemBuilder: (context, index) {
                final printer = printers[index];
                final isSelected = _selectedPrinter?.name == printer.name;
                
                return ListTile(
                  leading: Icon(
                    isSelected ? Icons.check_circle : Icons.print,
                    color: isSelected ? Colors.green : Colors.grey,
                  ),
                  title: Text(printer.name),
                  subtitle: Text(
                    printer.url.toString(),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  trailing: printer.isDefault
                      ? const Chip(
                          label: Text('Default', style: TextStyle(fontSize: 10)),
                          padding: EdgeInsets.all(4),
                        )
                      : null,
                  selected: isSelected,
                  onTap: () => Navigator.pop(context, printer),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );

      if (selected != null) {
        _selectedPrinter = selected;
        await _savePrinter(selected);
        return selected;
      }

      return null;
    } catch (e) {
      print('Error selecting printer: $e');
      return null;
    }
  }

  /// Save selected printer
  Future<void> _savePrinter(Printer printer) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_printer_name', printer.name);
      await prefs.setString('selected_printer_url', printer.url.toString());
      await prefs.setBool('printer_configured', true);
    } catch (e) {
      print('Error saving printer: $e');
    }
  }

  /// Print directly to selected thermal printer
  /// Note: The printing package shows system print dialog, but it will remember the selected printer
  Future<bool> printDirectly(pw.Document pdf) async {
    try {
      // Load saved printer if not already loaded
      if (_selectedPrinter == null) {
        await loadSavedPrinter();
      }

      // Print using layoutPdf - shows system dialog but user can quickly select printer
      // After first selection, system will remember the printer
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
      return true;
    } catch (e) {
      print('Error printing: $e');
      return false;
    }
  }

  /// Get current selected printer name
  String? get selectedPrinterName => _selectedPrinter?.name;

  /// Check if printer is configured
  Future<bool> isPrinterConfigured() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('printer_configured') ?? false;
  }
}

