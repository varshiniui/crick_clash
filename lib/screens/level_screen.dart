import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LevelScreen extends StatelessWidget {
  const LevelScreen({super.key});

  final List<Map<String, dynamic>> _levels = const [
    {
      'title': 'Rookie',
      'subtitle': 'Basic cricket facts',
      'emoji': '🟢',
      'route': '/game/easy',
      'color': Color(0xFF4CAF50),
    },
    {
      'title': 'Pro',
      'subtitle': 'Stats & player legends',
      'emoji': '🟡',
      'route': '/game/medium',
      'color': Color(0xFFFFD54F),
    },
    {
      'title': 'Legend',
      'subtitle': 'Master-level cricket trivia',
      'emoji': '🔴',
      'route': '/game/hard',
      'color': Color(0xFFFF5252),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            width: size.width,
            height: size.height,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0D0D1A),
                  Color(0xFF1A237E),
                  Color(0xFF0D0D1A),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppTheme.cskYellow.withAlpha(80)),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: AppTheme.cskYellow, size: 18),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Header
                  const Text(
                    'Choose Your',
                    style: TextStyle(
                      color: AppTheme.textGrey,
                      fontSize: 18,
                      letterSpacing: 0.5,
                    ),
                  ),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        AppTheme.cskYellow,
                        Colors.white,
                        AppTheme.cskYellow
                      ],
                    ).createShader(bounds),
                    child: const Text(
                      'Difficulty',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Pick a level and test your cricket knowledge 🏏',
                    style: TextStyle(
                      color: AppTheme.textGrey,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Level cards
                  Expanded(
                    child: ListView.separated(
                      itemCount: _levels.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final level = _levels[index];
                        return _LevelCard(
                          title: level['title'],
                          subtitle: level['subtitle'],
                          emoji: level['emoji'],
                          accentColor: level['color'],
                          onTap: () =>
                              Navigator.pushNamed(context, level['route']),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Footer
                  Center(
                    child: Text(
                      'Powered by CSK Spirit 💛',
                      style: TextStyle(
                        color: AppTheme.textGrey.withAlpha(150),
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Level Card Widget ──────────────────────────────────────────

class _LevelCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String emoji;
  final Color accentColor;
  final VoidCallback onTap;

  const _LevelCard({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.accentColor,
    required this.onTap,
  });

  @override
  State<_LevelCard> createState() => _LevelCardState();
}

class _LevelCardState extends State<_LevelCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppTheme.cardBg,
            border: Border.all(
              color: widget.accentColor.withAlpha(120),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.accentColor.withAlpha(40),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // Emoji badge
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.accentColor.withAlpha(30),
                  border: Border.all(
                      color: widget.accentColor.withAlpha(150), width: 2),
                ),
                child: Center(
                  child: Text(widget.emoji,
                      style: const TextStyle(fontSize: 28)),
                ),
              ),

              const SizedBox(width: 20),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        color: widget.accentColor,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      style: const TextStyle(
                        color: AppTheme.textGrey,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow
              Icon(Icons.arrow_forward_ios,
                  color: widget.accentColor.withAlpha(180), size: 18),
            ],
          ),
        ),
      ),
    );
  }
}