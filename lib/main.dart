import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;

void main() {
  if (!kIsWeb) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  runApp(const MyApp());
}

class EnergyCalculation {
  final int? id;
  final DateTime date;
  final double savings;

  EnergyCalculation({this.id, required this.date, required this.savings});

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date.millisecondsSinceEpoch,
        'savings': savings,
      };

  factory EnergyCalculation.fromMap(Map<String, dynamic> map) =>
      EnergyCalculation(
        id: map['id'],
        date: DateTime.fromMillisecondsSinceEpoch(map['date']),
        savings: map['savings'],
      );
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'energy_savings.db');
    return _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) => db.execute('''
          CREATE TABLE energy_savings(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date INTEGER NOT NULL,
            savings REAL NOT NULL
          )
        '''),
    );
  }

  Future<int> insert(EnergyCalculation calc) async {
    final db = await database;
    return await db.insert('energy_savings', calc.toMap());
  }

  Future<List<EnergyCalculation>> getAll() async {
    final db = await database;
    final result = await db.query('energy_savings', orderBy: 'date DESC');
    return result.map((map) => EnergyCalculation.fromMap(map)).toList();
  }

  Future<int> delete(int id) async {
    final db = await database;
    return await db.delete('energy_savings', where: 'id = ?', whereArgs: [id]);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Kalkulator uštede energije",
      initialRoute: "/",
      routes: {
        "/": (context) => const HomePage(),
        "/result": (context) => const ResultPage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  final _controllers = List.generate(3, (_) => TextEditingController());

  String? _validateInput(int index, String? value) {
    if (value != null && value.isNotEmpty) {
      final int? intValue = int.tryParse(value);
      if (intValue == null || intValue < 0) {
        return "Unesite pozitivan broj";
      }
      return null;
    } else {
      if (_controllers.every((controller) => controller.text.isEmpty)) {
        return "Molimo unesite broj";
      }
      return null;
    }
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final values = _controllers
        .map((controller) => int.tryParse(controller.text) ?? 0)
        .toList();

    final energySaved = _calculateSavings(values);
    Navigator.pushNamed(context, "/result", arguments: energySaved);
  }

  double _calculateSavings(List<int> values) {
    int energyClassic = values[0] * 100 + values[1] * 60 + values[2] * 40;
    int energyLed = values[0] * 20 + values[1] * 15 + values[2] * 8;
    return (energyClassic - energyLed) / 1000;
  }

  @override
  Widget build(BuildContext context) {
    final wattValues = [100, 60, 40];
    return Scaffold(
      appBar: AppBar(
          title: const Text("Izračun uštede energije"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < 3; i++) ...[
                TextFormField(
                  controller: _controllers[i],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Broj ${wattValues[i]}W žarulja',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lightbulb_outline),
                  ),
                  validator: (value) => _validateInput(i, value),
                ),
                const SizedBox(height: 16),
              ],
              ElevatedButton(
                onPressed: _onSubmit,
                child: const Text("Izračunaj"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ResultPage extends StatefulWidget {
  const ResultPage({super.key});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final db = DatabaseHelper.instance;
  List<EnergyCalculation> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final data = await db.getAll();
    setState(() {
      _history = data;
    });
  }

  Future<void> _saveCalculation(double savings) async {
    await db.insert(EnergyCalculation(date: DateTime.now(), savings: savings));
    await _loadHistory();
  }

  Future<void> _deleteCalculation(int id) async {
    await db.delete(id);
    await _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    final energySaved = ModalRoute.of(context)!.settings.arguments as double;
    return Scaffold(
      appBar: AppBar(title: const Text("Rezultat uštede"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Ušteda energije:",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                )),
            const SizedBox(height: 10),
            Text("${energySaved.toStringAsFixed(2)} kWh",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                )),
            const SizedBox(height: 10),
            ElevatedButton(
                onPressed: () => _saveCalculation(energySaved),
                child: const Text("Spremi")),
            const Divider(height: 30),
            const Text("Povijest ušteda:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: _history.length,
                itemBuilder: (ctx, i) => ListTile(
                  title: Text("${_history[i].savings.toStringAsFixed(2)} kWh"),
                  subtitle: Text(DateFormat.yMMMd().format(_history[i].date)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteCalculation(_history[i].id!),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
