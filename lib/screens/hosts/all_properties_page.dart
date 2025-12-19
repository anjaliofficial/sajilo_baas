import 'package:flutter/material.dart';

class AllPropertiesPage extends StatelessWidget {
  const AllPropertiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Properties')),
      body: const Center(child: Text('List of all properties')),
    );
  }
}
