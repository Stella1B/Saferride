import 'package:flutter/material.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Page'),
      ),
      body: const Center(
        child: Text('This is the Activity Page'),
      ),
    );
  }
}
