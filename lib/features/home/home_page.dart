// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // MVP mock data
    const streak = 7;

    // Günlük hak modeli (mod başına 1 free)
    const kupaFreeUsed = 0; // 0 ya da 1
    const kariyerFreeUsed = 0; // 0 ya da 1
    const totalDaily = 2;
    final doneToday = kupaFreeUsed + kariyerFreeUsed;
    final progress = doneToday / totalDaily;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Üst mini bilgi barı
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _InfoChip(
              icon: Icons.local_fire_department,
              text: '$streak streak',
            ),
            const _InfoChip(icon: Icons.lock_clock, text: 'Günlük: 1 free/mod'),
            const _InfoChip(
              icon: Icons.ondemand_video,
              text: 'Reklamla +1/mod',
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Hero Card (challenge hissi)
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0F3D2E), // koyu saha yeşili
                cs.primary,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.sports_soccer,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bugünün Challenge',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Streak’i koru!',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Progress
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Bugün',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '$doneToday/$totalDaily',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress.clamp(0, 1),
                  minHeight: 10,
                  backgroundColor: Colors.white.withOpacity(0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),

              const SizedBox(height: 14),

              // CTA
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => context.go('/explore'),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Hızlı Başla'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withOpacity(0.55)),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Yakında: Kurallar / İpuçları'),
                        ),
                      );
                    },
                    child: const Text('Kurallar'),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        Text('Bugünkü Hakların', style: theme.textTheme.titleLarge),
        const SizedBox(height: 10),

        _ModeMiniCard(
          icon: Icons.emoji_events,
          title: 'Kupadan Tahmin',
          subtitle: kupaFreeUsed == 0
              ? '1/1 ücretsiz hazır'
              : 'Ücretsiz hakkın bitti',
          accent: cs.primary,
          onTap: () => context.go('/explore'),
        ),
        const SizedBox(height: 10),
        _ModeMiniCard(
          icon: Icons.timeline,
          title: 'Kariyerden Tahmin',
          subtitle: kariyerFreeUsed == 0
              ? '1/1 ücretsiz hazır'
              : 'Ücretsiz hakkın bitti',
          accent: cs.secondary,
          onTap: () => context.go('/explore'),
        ),

        const SizedBox(height: 16),

        // Mini istatistikler (oyun hissi)
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _StatItem(label: 'Bugün', value: '0/2'),
                _StatItem(label: 'En iyi', value: '12'),
                _StatItem(label: 'Toplam', value: '34'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(text),
      visualDensity: VisualDensity.compact,
      backgroundColor: Colors.white.withOpacity(0.06),
    );
  }
}

class _ModeMiniCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;

  const _ModeMiniCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: accent.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: accent),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
