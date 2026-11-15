import 'package:flutter/material.dart';
import 'package:frigo/data/db.dart';
import 'package:frigo/data/food.dart';

class DataViewPage extends StatefulWidget {
  const DataViewPage({super.key});

  @override
  State<DataViewPage> createState() => _DataViewPageState();
}

class _DataViewPageState extends State<DataViewPage> {
  final List<Food> _items = [];

  // Load the foods from the database
  void _loadFoods() {
    foods().then((value) => {
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
    _loadFoods();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Base de données de nourriture')
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            tileColor: Theme.of(context).colorScheme.primary,
            title: Text(
              '${_items[index].name} - ${_items[index].barcode}'
            ),
            trailing: IconButton(
              onPressed: () {
                deleteFood(_items[index].id!).then((_) => _loadFoods());
              },
              icon: Icon(Icons.delete)
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
        itemCount: _items.length
      ),
      persistentFooterButtons: [
        IconButton(
          onPressed: () async {
            final result = await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Nettoyage de la base de données"),
                  content: Text('Voulez-vous nettoyer la base de données ?'),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                          Navigator.of(context).pop(true);
                      },
                      child: Text('Oui')
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      child: Text('Non')
                    )
                  ],
                );
              }
            );
            if (result != null && result) {
              await DatabaseHandler.instance.clearDatabase();
              if (mounted) {
                ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(content: Text('Base de données nettoyée')));
                _loadFoods();
              }
            }
          },
          icon: Icon(Icons.clear_all)
        )
      ],
      persistentFooterDecoration: BoxDecoration(
        color: Theme.of(context).colorScheme.inversePrimary,
        border: Border(top: BorderSide())
      ),
    );
  }
}