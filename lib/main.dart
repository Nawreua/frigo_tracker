import 'package:material_ui/material_ui.dart';
import 'package:frigo/data/dataview.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'package:frigo/data/db.dart';
import 'package:frigo/data/food.dart';
import 'package:frigo/openfood.dart';
import 'package:frigo/scanner.dart';

void main() async {
  // Avoid errors caused by flutter upgrade.
  // Importing 'package:flutter/widgets.dart' is required.
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR');
  initializeOpenFood();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Frigo',
      theme: ThemeData(
        // This is the theme of your application.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Contenu du frigo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<FoodStoredView> _items = [];

  // Load foods stored from database
  void _loadFrigoItems() {
    foodsStored().then((value) => {
      if (mounted) {
        setState(() {
          _items.clear();
          _items.addAll(value);
        })
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadFrigoItems();
  }

  // Scan for barcode and select the expiration data
  void _openScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProductScanner())
    ).then((_) => _loadFrigoItems());
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: _items.length,
        itemBuilder: (BuildContext context, int index) {
          // Compute the color
          Color color = Colors.lightGreen;
          if (_items[index].foodStored.expirationDate.isBefore(DateTime.now())) {
            color = Colors.red;
          }
          return ListTile(
            tileColor:  color,
            title: Text(
              'Produit : ${_items[index].name}, DLC : ${DateFormat.yMd('fr_FR').format(_items[index].foodStored.expirationDate)}'
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => {
                deleteFoodStored(_items[index].foodStored.id!).then((_) => _loadFrigoItems())
              },
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(
            height: 1.0,
            width: double.infinity,
            child: ColoredBox(color: Color(0xFF000000)),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openScanner,
        tooltip: 'Ajouter produit',
        child: const Icon(Icons.barcode_reader),
      ),
      persistentFooterButtons: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DataViewPage())
            ).then((_) => _loadFrigoItems());
          },
          icon: Icon(Icons.dataset))
      ],
      persistentFooterDecoration: BoxDecoration(
        color: Theme.of(context).colorScheme.inversePrimary,
        border: Border(top: BorderSide())
      ),
    );
  }
}
