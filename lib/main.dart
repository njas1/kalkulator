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
        children: <Widget>
          SizedBox(height: 20),
          ),
        ,
      ),
    );
  }
}