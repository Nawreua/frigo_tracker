import 'dart:async';

import 'package:path/path.dart';
import 'package:frigo/data/food.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHandler {
  // make this a singleton class
  DatabaseHandler._privateConstructor();
  static final DatabaseHandler instance = DatabaseHandler._privateConstructor();
  static const String databaseName = 'product.db';

  static Future<Database>? _database;

  Future<Database> getDatabase() async {
    if (_database != null) return _database!;
    _database = _initializeDatabase();
    return _database!;
  }

  Future<String> getDatabasePath() async {
    // Get the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    return join(await getDatabasesPath(), databaseName);
  }

  Future<void> clearDatabase() async {
    final db = await getDatabase();
    await db.transaction((txn) async {
      await txn.execute('DROP TABLE IF EXISTS ${FoodStored.tableName}');
      await txn.execute('DROP TABLE IF EXISTS ${Food.tableName}');
      await txn.execute(
        'CREATE TABLE ${Food.tableName}(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, barcode TEXT NOT NULL UNIQUE)',
      );
      await txn.execute(
        'CREATE TABLE ${FoodStored.tableName}(id INTEGER PRIMARY KEY, foodId INTEGER NOT NULL REFERENCES ${Food.tableName}(id), expirationDate INTEGER NOT NULL)'
      );
    });
  }

  Future<Database> _initializeDatabase() async {
    // Open the database and store the reference.
    return openDatabase(
      await getDatabasePath(),
      // When the database is first created, create tables to store.
      onCreate: (db, version) {
        // Run the CREATE TABLE statement on the database.
        return db.transaction((txn) async {
          await txn.execute(
            'CREATE TABLE ${Food.tableName}(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, barcode TEXT NOT NULL UNIQUE)',
          );
          await txn.execute(
            'CREATE TABLE ${FoodStored.tableName}(id INTEGER PRIMARY KEY, foodId INTEGER NOT NULL REFERENCES ${Food.tableName}(id), expirationDate INTEGER NOT NULL)'
          );
        });
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
    );
  }
}

Future<Food> insertFood(Food food) async {
  // Get a reference to the database.
  final db = await DatabaseHandler.instance.getDatabase();

  // Insert the Food into the correct table. You might also specify the
  // `conflictAlgorithm` to use in case the same food is inserted twice.
  final id = await db.insert(
    Food.tableName,
    food.toMap(),
    conflictAlgorithm: ConflictAlgorithm.fail
  );
  return Food(id: id, name: food.name, barcode: food.barcode);
}

Future<Food?> findFoodByBarcode(String barcode) async {
  // Get a reference to the database.
  final db = await DatabaseHandler.instance.getDatabase();

  // Find if a food is associated with the barcode
  final List<Map<String, Object?>> food = await db.query(Food.tableName, where: 'barcode = ?', whereArgs: [barcode]);
  if (food.isNotEmpty) {
    return Food(id: food.first['id'] as int, name: food.first['name'] as String, barcode: food.first['barcode'] as String);
  }
  return null;
}

Future<FoodStored> insertFoodStored(FoodStored foodStored) async {
  // Get a reference to the database.
  final db = await DatabaseHandler.instance.getDatabase();

  // Insert the Food into the correct table. You might also specify the
  // `conflictAlgorithm` to use in case the same food is inserted twice.
  final id = await db.insert(
    FoodStored.tableName,
    foodStored.toMap(),
  );
  return FoodStored(id: id, foodId: foodStored.foodId, expirationDate: foodStored.expirationDate);
}

Future<void> deleteFoodStored(int id) async {
  // Get a reference to the database.
  final db = await DatabaseHandler.instance.getDatabase();

  // Remove the FoodStored from the database.
  await db.delete(
    FoodStored.tableName,
    // Use a `where` clause to delete a specific food stored.
    where: 'id = ?',
    // Pass the FoodStored's id as a whereArg to prevent SQL injection.
    whereArgs: [id],
  );
}

// A method that retrieves all the foods stored from the foodsStored table.
Future<List<FoodStoredView>> foodsStored() async {
  // Get a reference to the database.
  final db = await DatabaseHandler.instance.getDatabase();

  // Query the view for all the foods stored with their name.
  final List<Map<String, Object?>> foodsStored = await db.rawQuery("""
  SELECT ${FoodStored.tableName}.id, foodId, expirationDate, name
  FROM ${FoodStored.tableName}
  JOIN ${Food.tableName} ON ${Food.tableName}.id = ${FoodStored.tableName}.foodId
  ORDER BY expirationDate
"""
  );

  // Convert the list of each food stored's fields into a list of `FoodStored` objects.
  return [
    for (final {'id': id as int, 'foodId': foodId as int, 'expirationDate': expirationDate as int, 'name': name as String}
        in foodsStored)
      FoodStoredView(
        name: name,
        foodStored: FoodStored(
          id: id,
          foodId: foodId,
          expirationDate: DateTime.fromMillisecondsSinceEpoch(expirationDate)
        )
      ),
  ];
}
