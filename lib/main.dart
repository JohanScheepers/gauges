import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

import 'widgets/gauge_card_widget.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Gauges',
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.blueGrey[50],
        fontFamily: 'Roboto',
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.red[800],
          titleTextStyle: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      home: FlutterGaugesPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class FlutterGaugesPage extends StatefulWidget {
  const FlutterGaugesPage({super.key});

  @override
  FlutterGaugesPageState createState() => FlutterGaugesPageState();
}

class FlutterGaugesPageState extends State<FlutterGaugesPage> {
  // --- Set number of gauges in APP ---
  final int numberOfGauges = 12;
  late List<double> _gaugeValues;
  late List<Timer?> _timers;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _gaugeValues = List<double>.generate(
        numberOfGauges, (index) => 700.0 + _random.nextDouble() * 200);
    _timers = List<Timer?>.filled(numberOfGauges, null);

    for (int i = 0; i < numberOfGauges; i++) {
      final initialDelay = Duration(milliseconds: _random.nextInt(500));
      Future.delayed(initialDelay, () {
        if (mounted) {
          _timers[i] = Timer.periodic(const Duration(seconds: 3), (timer) {
            _updateGaugeValue(i);
          });
        }
      });
    }
  }

  void _updateGaugeValue(int index) {
    if (!mounted) return;

    setState(() {
      double change = (_random.nextDouble() - 0.48) * 80;
      double newValue = _gaugeValues[index] + change;

      if (_random.nextDouble() < 0.04) {
        newValue += (_random.nextDouble() - 0.5) * 300;
      }

      newValue = newValue.clamp(0.0, 1800.0);
      _gaugeValues[index] = newValue;
    });
  }

  @override
  void dispose() {
    for (var timer in _timers) {
      timer?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Gauges'),
        elevation: 4.0,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: numberOfGauges,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 1.0,
        ),
        itemBuilder: (context, index) {
          return GaugeCard(
            targetValue: _gaugeValues[index],
            gaugeIndex: index + 1,
          );
        },
      ),
    );
  }
}
