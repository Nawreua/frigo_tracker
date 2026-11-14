import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:frigo/data/db.dart';
import 'package:frigo/data/food.dart';
import 'package:frigo/openfood.dart';

/// Implementation of Mobile Scanner example with simple configuration
class ProductScanner extends StatefulWidget {
  /// Constructor for simple Mobile Scanner example
  const ProductScanner({super.key});

  @override
  State<ProductScanner> createState() => _ProductScannerState();
}

class _ProductScannerState extends State<ProductScanner> {
  bool _scanInProgress = false;

  Future<bool?> _isCorrectProduct(String name) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Est-ce le bon produit ?"),
          content: Text(name),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Oui')),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Non'))
          ],
        );
      }
    );
  }

  Future<String?> _inputProductName() async {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: Text("Nom du produit ?"),
          content: TextField(
            autofocus: true,
            decoration: InputDecoration(hintText: 'Entrez le nom du produit'),
            controller: controller,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(controller.text.trim());
              },
              child: Text('Valider')
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop('');
              },
              child: Text('Annuler')
            )
          ],
        );
      }
    );
  }

  Future<String> _findAndAddProduct(String barcode) async {
    // Find the product associated with it
    Food? food = await findFoodByBarcode(barcode);
    if (food == null) {
      // If the food is not found, create the row for it
      String? name = await findProductName(barcode);
      // If no name was found, ask the user directly
      if (name == null && mounted) {
        name = await _inputProductName();
        if (name != null && name.isEmpty) {
          name = null;
        }
      }
      if (name != null && mounted) {
        final result = await _isCorrectProduct(name);
        if (result != null && result) {  
          food = await insertFood(Food(name: name, barcode: barcode));
        } else {
          return "Le produit scanné n'est pas le bon";
        }
      } else {
        return "Le produit scanné n'a pas été trouvé";
      }
    } else {
      final result = await _isCorrectProduct(food.name);
      if (result == null || !result) {
        return "Le produit scanné n'est pas le bon";
      }
    }

    if (food.id != null) {
      if (mounted) {
        // Select the expiration date
        DateTime? expirationDate = await showDatePicker(
          context: context,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365 * 2)) 
        );

        // Insert the food stored if conditions are met
        if (expirationDate != null) {
          await insertFoodStored(FoodStored(foodId: food.id!, expirationDate: expirationDate));
          return 'Produit ajouté au frigo';
        } else {
          return 'Aucun date choisie';
        }
      }
    }
    return "Une erreur a eu lieu pendant l'insertion";
  }

  void _handleBarcode(BarcodeCapture barcodes) async {
    if (barcodes.barcodes.firstOrNull != null
        && barcodes.barcodes.first.rawValue != null
        && !_scanInProgress) {
      _scanInProgress = true;
      String snackBarMessage = 'Une erreur critique a eu lieu';
      try {
        snackBarMessage = await _findAndAddProduct(barcodes.barcodes.first.rawValue!);
      } catch (e) {
        snackBarMessage = e.toString();
      }
      finally {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(snackBarMessage)));
          Navigator.pop(context, true);
        }
        _scanInProgress = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan de produit')),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(onDetect: _handleBarcode)
        ],
      ),
    );
  }
}