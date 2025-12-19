import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/home/home_page.dart';
import '../features/explore/explore_page.dart';
import '../features/profile/profile_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/home',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(
            location: state.uri.toString(),
            child: child,
            
          );
        },
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomePage()),
          ),
          GoRoute(
            path: '/explore',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ExplorePage()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProfilePage()),
          ),
        ],
      ),
    ],
  );
}

class AppShell extends StatelessWidget {
  final String location;
  final Widget child;


  const AppShell({super.key, required this.location, required this.child});

  int _indexFromLocation(String location) {
    if (location.startsWith('/explore')) return 1;
    if (location.startsWith('/profile')) return 2;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/explore');
        break;
      case 2:
        context.go('/profile');
        break;
    }
  }

@override
Widget build(BuildContext context) {
  final currentIndex = _indexFromLocation(location);

  return Scaffold(
    body: child,
    bottomNavigationBar: NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (i) => _onTap(context, i),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.explore_outlined), label: 'Explore'),
        NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
    ),
  );
}

}
