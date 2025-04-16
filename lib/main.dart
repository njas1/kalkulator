import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
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

class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final energySaved = ModalRoute.of(context)!.settings.arguments as double;
    return Scaffold(
      appBar: AppBar(title: const Text("Rezultat uštede"), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Natrag"),
            ),
          ],
        ),
      ),
    );
  }
}
