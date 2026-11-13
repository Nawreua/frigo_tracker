import 'package:openfoodfacts/openfoodfacts.dart';

void initializeOpenFood() {
  OpenFoodAPIConfiguration.userAgent = UserAgent(name: 'Frigo', url: '');
  
  OpenFoodAPIConfiguration.globalLanguages = <OpenFoodFactsLanguage>[
    OpenFoodFactsLanguage.FRENCH
  ];
  
  OpenFoodAPIConfiguration.globalCountry = OpenFoodFactsCountry.FRANCE;
}

Future<Product?> searchByBarcode(String barcode) async {
  ProductResultV3 productResult = await OpenFoodAPIClient.getProductV3(
    ProductQueryConfiguration(barcode, version: ProductQueryVersion.v3_5)
  );

  return productResult.product;
}

Future<String?> findProductName(String barcode) async {
  Product? product = await searchByBarcode(barcode);
  if (product != null) {
    if (product.productNameInLanguages?[OpenFoodFactsLanguage.FRENCH] != null) {
      return product.productNameInLanguages?[OpenFoodFactsLanguage.FRENCH];
    } else if (product.productNameInLanguages?[OpenFoodFactsLanguage.ENGLISH] != null) {
      return product.productNameInLanguages?[OpenFoodFactsLanguage.ENGLISH];
    } else if (product.productNameInLanguages?[OpenFoodFactsLanguage.GERMAN] != null) {
      return product.productNameInLanguages?[OpenFoodFactsLanguage.GERMAN];
    } else {
      return product.productName;
    }
  }
  return null;
}
