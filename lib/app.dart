import 'package:flutter/material.dart';

/// Build-time environment, set by the flavor entry points.
enum AppFlavor { dev, prod }

class TuitionTrackerApp extends StatelessWidget {
  const TuitionTrackerApp({required this.flavor, super.key});

  final AppFlavor flavor;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tuition Khata',
      debugShowCheckedModeBanner: flavor == AppFlavor.dev,
      home: const Scaffold(body: Center(child: Text('Tuition Khata'))),
    );
  }
}
