import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ušteda energije',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int bulb100W = 0;
  int bulb60W = 0;
  int bulb40W = 0;

  void _updateBulbValues(int b100W, int b60W, int b40W) {
    setState(() {
      bulb100W = b100W;
      bulb60W = b60W;
      bulb40W = b40W;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Izračun uštede energije'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          InputBulbs(onBulbValuesChanged: _updateBulbValues),
          SizedBox(height: 20),
          ResultDisplay(
            bulb100W: bulb100W,
            bulb60W: bulb60W,
            bulb40W: bulb40W,
          ),
        ],
      ),
    );
  }
}

class InputBulbs extends StatefulWidget {
  final Function(int, int, int) onBulbValuesChanged;

  InputBulbs({required this.onBulbValuesChanged});

  @override
  _InputBulbsState createState() => _InputBulbsState();
}

class _InputBulbsState extends State<InputBulbs> {
  final TextEditingController _controller100W = TextEditingController();
  final TextEditingController _controller60W = TextEditingController();
  final TextEditingController _controller40W = TextEditingController();

  void _onSubmit() {
    final int b100W = int.tryParse(_controller100W.text) ?? 0;
    final int b60W = int.tryParse(_controller60W.text) ?? 0;
    final int b40W = int.tryParse(_controller40W.text) ?? 0;

    widget.onBulbValuesChanged(b100W, b60W, b40W);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          TextField(
            controller: _controller100W,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Broj 100W žarulja'),
          ),
          TextField(
            controller: _controller60W,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Broj 60W žarulja'),
          ),
          TextField(
            controller: _controller40W,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Broj 40W žarulja'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _onSubmit,
            child: Text('Izračunaj'),
          ),
        ],
      ),
    );
  }
}

class ResultDisplay extends StatelessWidget {
  final int bulb100W;
  final int bulb60W;
  final int bulb40W;

  ResultDisplay({
    required this.bulb100W,
    required this.bulb60W,
    required this.bulb40W,
  });

  double _calculateEnergySavedPerDay() {
    final int energyClassic100W = bulb100W * 100;
    final int energyClassic60W = bulb60W * 60;
    final int energyClassic40W = bulb40W * 40;

    final int energyLed100W = bulb100W * 20;
    final int energyLed60W = bulb60W * 15;
    final int energyLed40W = bulb40W * 8;

    final int energyClassicTotal = energyClassic100W + energyClassic60W + energyClassic40W;
    final int energyLedTotal = energyLed100W + energyLed60W + energyLed40W;

    return (energyClassicTotal - energyLedTotal) / 1000; // u kWh
  }

  @override
  Widget build(BuildContext context) {
    final double energySaved = _calculateEnergySavedPerDay();
    return Column(
      children: <Widget>[
        Text('Ušteda energije dnevno:'),
        SizedBox(height: 10),
        Text(
          '${energySaved.toStringAsFixed(2)} kWh',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}