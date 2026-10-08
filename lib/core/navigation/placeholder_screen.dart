import 'package:flutter/material.dart';

/// Stand-in body for tabs whose real screens land in later tasks.
class PlaceholderScreen extends StatefulWidget {
  const PlaceholderScreen({required this.title, super.key});

  final String title;

  @override
  State<PlaceholderScreen> createState() => _PlaceholderScreenState();
}

class _PlaceholderScreenState extends State<PlaceholderScreen> {
  // Lets tests (and humans) verify tab state survives switching.
  int _taps = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: FilledButton(
          onPressed: () => setState(() => _taps++),
          child: Text('${widget.title} · $_taps'),
        ),
      ),
    );
  }
}
