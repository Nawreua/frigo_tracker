class Food {
  final int? id;
  final String name;
  final String barcode;

  static const String tableName = 'foods';

  const Food({this.id, required this.name, required this.barcode});

  // Convert a Food into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, Object?> toMap() {
    return {'id': id, 'name': name, 'barcode': barcode};
  }


  // Implement toString to make it easier to see information about
  // each food when using the print statement.
  @override
  String toString() {
    return 'Food{id: $id, name: $name, barcode: $barcode}';
  }
}

class FoodStored {
  final int? id;
  final int foodId;
  final DateTime expirationDate;

  static const String tableName = 'foodsStored';

  const FoodStored({this.id, required this.foodId, required this.expirationDate});

  // Convert a FoodStored into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, Object?> toMap() {
    return {'id': id, 'foodId': foodId, 'expirationDate': expirationDate.millisecondsSinceEpoch};
  }


  // Implement toString to make it easier to see information about
  // each food when using the print statement.
  @override
  String toString() {
    return 'FoodStored{id: $id, foodId: $foodId, expirationDate: $expirationDate}';
  }
}

class FoodStoredView {
  final String name;
  final FoodStored foodStored;

  const FoodStoredView({required this.name, required this.foodStored});

  // Implement toString to make it easier to see information about
  // each food when using the print statement.
  @override
  String toString() {
    return 'FoodStoredView{name: $name, food stored: ${foodStored.toString()}}';
  }
}