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
  final TextEditingController _controller100W = TextEditingController();
  final TextEditingController _controller60W = TextEditingController();
  final TextEditingController _controller40W = TextEditingController();

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      final int b100W = _parseInput(_controller100W.text);
      final int b60W = _parseInput(_controller60W.text);
      final int b40W = _parseInput(_controller40W.text);

      final double energySaved = _calculateSavings(b100W, b60W, b40W);

      Navigator.pushNamed(
        context,
        "/result",
        arguments: energySaved,
      );
    }
  }

  int _parseInput(String? value) {
    if (value == null || value.isEmpty) {
      return 0;
    }
    final int? intValue = int.tryParse(value);
    return (intValue != null && intValue >= 0) ? intValue : 0;
  }

  String? _validateInput(String? value) {
    if (value != null && value.isNotEmpty) {
      final int? intValue = int.tryParse(value);
      if (intValue == null || intValue < 0) {
        return "Unesite ispravan pozitivan broj";
      }
    }
    return null;
  }

  double _calculateSavings(int b100W, int b60W, int b40W) {
    final int energyClassic = (b100W * 100) + (b60W * 60) + (b40W * 40);
    final int energyLed = (b100W * 20) + (b60W * 15) + (b40W * 8);
    return (energyClassic - energyLed) / 1000;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Izračun uštede energije'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: _controller100W,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Broj 100W žarulja',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lightbulb_outline),
                ),
                validator: _validateInput,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _controller60W,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Broj 60W žarulja',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lightbulb_outline),
                ),
                validator: _validateInput,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _controller40W,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Broj 40W žarulja',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lightbulb_outline),
                ),
                validator: _validateInput,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _onSubmit,
                child: const Text('Izračunaj'),
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
    final double energySaved = ModalRoute.of(context)!.settings.arguments as double;
    return Scaffold(
      appBar: AppBar(title: const Text("Rezultat uštede"), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Ušteda energije:',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 10),
            Text(
              '${energySaved.toStringAsFixed(2)} kWh',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.green.shade800),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Natrag'),
            ),
          ],
        ),
      ),
    );
  }
}
