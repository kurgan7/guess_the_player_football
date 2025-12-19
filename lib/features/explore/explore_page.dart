import 'package:flutter/material.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explore')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => Card(
          child: ListTile(
            title: Text('Item #$i'),
            subtitle: const Text('A simple list to validate layout.'),
            trailing: const Icon(Icons.chevron_right),
          ),
        ),
      ),
    );
  }
}
