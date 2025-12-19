import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Guess The Player')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Welcome 👋', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: Icon(Icons.bolt, color: cs.primary),
              title: const Text('Quick action'),
              subtitle: const Text('Your first UI card is ready.'),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Today: build UI + navigation.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
