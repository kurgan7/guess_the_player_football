import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/home/home_page.dart';
import '../features/modes/modes.dart';
import '../features/profile/profile_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/home',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(location: state.uri.toString(), child: child);
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

  String _titleFromLocation(String location) {
    if (location.startsWith('/explore')) return 'Modlar';
    if (location.startsWith('/profile')) return 'Profil';
    return 'Günlük Challenge';
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
      appBar: AppBar(
        title: Text(_titleFromLocation(location)),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Yakında: Kurallar & ipuçları')),
              );
            },
            icon: const Icon(Icons.help_outline),
          ),
        ],
      ),

      body: Stack(
        children: [
          // Dark pitch base gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0A1411), // üst: koyu yeşil-siyah
                  Color(0xFF070D0B), // alt: daha koyu
                ],
              ),
            ),
          ),

          // Pitch stripes + lines (clean, real pitch feel)
          Positioned.fill(
            child: IgnorePointer(child: CustomPaint(painter: _PitchPainter())),
          ),

          SafeArea(child: child),
        ],
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (i) => _onTap(context, i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            label: 'Modes',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _PitchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // ✅ Çim şeritleri: iki ton koyu yeşil (neon değil)
    final stripePaint = Paint()..style = PaintingStyle.fill;

    final stripeCount = 12;
    final stripeWidth = size.width / stripeCount;

    for (int i = 0; i < stripeCount; i++) {
      stripePaint.color = (i.isEven)
          ? const Color(0xFF0A1814).withOpacity(0.70) // koyu çim
          : const Color(0xFF0E241D).withOpacity(0.70); // açık çim
      // biraz daha açık çim

      canvas.drawRect(
        Rect.fromLTWH(i * stripeWidth, 0, stripeWidth, size.height),
        stripePaint,
      );
    }

    // ✅ Saha çizgileri: çok düşük opaklık (UI kirletmesin)
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFFE7F6EE).withOpacity(0.10);

    // Orta saha çizgisi
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      linePaint,
    );

    // Orta yuvarlak
    final center = Offset(size.width / 2, size.height * 0.35);
    canvas.drawCircle(center, 200, linePaint);

    // Orta nokta
    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFE7F6EE).withOpacity(0.06);

    canvas.drawCircle(center, 4, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
