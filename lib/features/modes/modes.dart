import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // ✅ değişkenler children içine değil, burada tanımlanır
    final w = MediaQuery.of(context).size.width;
    final crossAxisCount = w >= 520 ? 3 : 2;
    final aspectRatio = w >= 520 ? 0.95 : 0.78;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Mod Seç', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(
          'Her modda günde 1 ücretsiz. Reklamla +1 daha.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: aspectRatio,
          ),
          itemCount: 2,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _ModeGridCard(
                icon: Icons.emoji_events,
                title: 'Kupadan',
                subtitle: 'Kupa tahmini',
                badgeTop: 'FREE 1/1',
                badgeBottom: 'AD 1/1',
                freeRemaining: 1,
                adRemaining: 1,
                onStart: () {},
                onWatchAd: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reklam akışı (MVP stub)')),
                  );
                },
              );
            }

            return _ModeGridCard(
              icon: Icons.timeline,
              title: 'Kariyer',
              subtitle: 'Takım/sezon',
              badgeTop: 'FREE 1/1',
              badgeBottom: 'AD 1/1',
              freeRemaining: 1,
              adRemaining: 1,
              onStart: () {},
              onWatchAd: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reklam akışı (MVP stub)')),
                );
              },
            );
          },
        ),

        const SizedBox(height: 14),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: const [
                Icon(Icons.tips_and_updates_outlined),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'İpucu: Streak’i korumak için her gün en az 1 mod oyna.',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ModeGridCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String badgeTop;
  final String badgeBottom;
  final int freeRemaining;
  final int adRemaining;
  final VoidCallback onStart;
  final VoidCallback onWatchAd;

  const _ModeGridCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badgeTop,
    required this.badgeBottom,
    required this.freeRemaining,
    required this.adRemaining,
    required this.onStart,
    required this.onWatchAd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final canPlayFree = freeRemaining > 0;
    final canWatchAd = adRemaining > 0;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: canPlayFree ? onStart : null,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // top badges
              Row(
                children: [
                  _Badge(text: badgeTop),
                  const SizedBox(width: 6),
                  _Badge(text: badgeBottom, subtle: true),
                ],
              ),
              const SizedBox(height: 12),

              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.22),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: cs.primary),
              ),

              const SizedBox(height: 12),

              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(subtitle),

              const Spacer(),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onPressed: canPlayFree ? onStart : null,
                      child: Text(canPlayFree ? 'Başla' : 'Bitti'),
                    ),
                  ),

                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: (!canPlayFree && canWatchAd) ? onWatchAd : null,
                    icon: const Icon(Icons.ondemand_video),
                    tooltip: 'Reklamla +1',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final bool subtle;
  const _Badge({required this.text, this.subtle = false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: subtle
            ? cs.secondaryContainer.withOpacity(0.55)
            : cs.primaryContainer.withOpacity(0.65),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: subtle ? cs.onSecondaryContainer : cs.onPrimaryContainer,
        ),
      ),
    );
  }
}
