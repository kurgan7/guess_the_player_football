import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(radius: 36, child: Icon(Icons.person, size: 36)),
            const SizedBox(height: 12),
            Text('Your Name', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text('Free plan', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: const [
                  ListTile(leading: Icon(Icons.settings), title: Text('Settings')),
                  Divider(height: 1),
                  ListTile(leading: Icon(Icons.logout), title: Text('Logout')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
