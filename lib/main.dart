import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gerenciador de Planetas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PlanetListScreen(),
    );
  }
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('planets.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE planets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        distance REAL NOT NULL,
        size REAL NOT NULL,
        nickname TEXT
      )
    ''');
  }

  Future<int> insertPlanet(Map<String, dynamic> planet) async {
    final db = await instance.database;
    return await db.insert('planets', planet);
  }

  Future<List<Map<String, dynamic>>> getPlanets() async {
    final db = await instance.database;
    return await db.query('planets');
  }

  Future<int> updatePlanet(Map<String, dynamic> planet) async {
    final db = await instance.database;
    return await db.update('planets', planet, where: 'id = ?', whereArgs: [planet['id']]);
  }

  Future<int> deletePlanet(int id) async {
    final db = await instance.database;
    return await db.delete('planets', where: 'id = ?', whereArgs: [id]);
  }
}

class PlanetListScreen extends StatefulWidget {
  const PlanetListScreen({super.key});

  @override
  _PlanetListScreenState createState() => _PlanetListScreenState();
}

class _PlanetListScreenState extends State<PlanetListScreen> {
  List<Map<String, dynamic>> _planets = [];

  @override
  void initState() {
    super.initState();
    _refreshPlanets();
  }

  Future<void> _refreshPlanets() async {
    final data = await DatabaseHelper.instance.getPlanets();
    setState(() {
      _planets = data;
    });
  }

  void _deletePlanet(int id) async {
    await DatabaseHelper.instance.deletePlanet(id);
    _refreshPlanets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Planetas')),
      body: ListView.builder(
        itemCount: _planets.length,
        itemBuilder: (context, index) {
          final planet = _planets[index];
          return ListTile(
            title: Text(planet['name']),
            subtitle: Text(planet['nickname'] ?? 'Sem apelido'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deletePlanet(planet['id']),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          // Adicionar lógica para navegação a tela de cadastro
        },
      ),
    );
  }
}
