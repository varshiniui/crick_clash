import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:math';

import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'level_screen.dart';

class ResultScreen extends StatefulWidget {
  final int score;
  final int total;
  final String difficulty;
  final int bestStreak;

  const ResultScreen({
    super.key,
    required this.score,
    required this.total,
    required this.difficulty,
    required this.bestStreak,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  int _highScore = 0;
  bool _isNewHighScore = false;
  late TabController _tabController;

  // Leaderboard data per difficulty
  List<_LeaderEntry> _leaderboard = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _handleHighScore();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String get _prefKey => 'highscore_${widget.difficulty}';
  String get _leaderKey => 'leaderboard_${widget.difficulty}';

  Future<void> _handleHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt(_prefKey) ?? 0;

    // Load leaderboard
    final rawList = prefs.getStringList(_leaderKey) ?? [];
    List<_LeaderEntry> entries = rawList.map((e) {
      final parts = e.split(':');
      return _LeaderEntry(
        score: int.tryParse(parts[0]) ?? 0,
        streak: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
        label: parts.length > 2 ? parts[2] : 'Player',
      );
    }).toList();

    // Add current run
    entries.add(_LeaderEntry(
      score: widget.score,
      streak: widget.bestStreak,
      label: 'You (this run)',
    ));

    // Sort descending, keep top 5
    entries.sort((a, b) => b.score.compareTo(a.score));
    if (entries.length > 5) entries = entries.sublist(0, 5);

    // Save back
    await prefs.setStringList(
      _leaderKey,
      entries.map((e) => '${e.score}:${e.streak}:${e.label}').toList(),
    );

    if (widget.score > saved) {
      await prefs.setInt(_prefKey, widget.score);
      setState(() {
        _highScore = widget.score;
        _isNewHighScore = true;
        _leaderboard = entries;
      });
    } else {
      setState(() {
        _highScore = saved;
        _isNewHighScore = false;
        _leaderboard = entries;
      });
    }
  }

  String get _resultEmoji {
    final ratio = widget.score / widget.total;
    if (ratio == 1.0) return '🏆';
    if (ratio >= 0.6) return '👏';
    return '😅';
  }

  String get _resultTitle {
    final ratio = widget.score / widget.total;
    if (ratio == 1.0) return 'Perfect Score!';
    if (ratio >= 0.6) return 'Well Played!';
    return 'Keep Practising!';
  }

  String get _resultSubtitle {
    final ratio = widget.score / widget.total;
    if (ratio == 1.0) return 'You\'re a cricket genius 🌟';
    if (ratio >= 0.6) return 'Solid performance, legend!';
    return 'You\'ll get them next time!';
  }

  Color get _difficultyColor {
    switch (widget.difficulty.toLowerCase()) {
      case 'easy':
        return const Color(0xFF4CAF50);
      case 'medium':
        return AppTheme.cskYellow;
      case 'hard':
        return const Color(0xFFFF5252);
      default:
        return AppTheme.cskYellow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Stack(
        children: [
          // Background gradient
          Container(
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

          // Decorative glow circles
          Positioned(
            top: -size.width * 0.2,
            right: -size.width * 0.2,
            child: _glowCircle(size.width * 0.6, AppTheme.cskYellow, 0.05),
          ),
          Positioned(
            bottom: -size.width * 0.3,
            left: -size.width * 0.2,
            child: _glowCircle(size.width * 0.7, AppTheme.cskLightBlue, 0.07),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),

                // ── Score Hero ──────────────────────────────
                _buildScoreHero(),

                const SizedBox(height: 20),

                // ── Tab bar ─────────────────────────────────
                _buildTabBar(),

                // ── Tab views ───────────────────────────────
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildStatsTab(),
                      _buildLeaderboardTab(),
                    ],
                  ),
                ),

                // ── Action buttons ──────────────────────────
                _buildActions(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Score Hero ──────────────────────────────────────────────

  Widget _buildScoreHero() {
    return FadeInDown(
      duration: const Duration(milliseconds: 700),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: AppTheme.cardBg,
            border: Border.all(
              color: _difficultyColor.withAlpha(120),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _difficultyColor.withAlpha(50),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              // Emoji + title
              Text(
                _resultEmoji,
                style: const TextStyle(fontSize: 52),
              ),
              const SizedBox(height: 8),
              Text(
                _resultTitle,
                style: TextStyle(
                  color: _difficultyColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                _resultSubtitle,
                style: const TextStyle(
                  color: AppTheme.textGrey,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),

              // Big score
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${widget.score}',
                    style: TextStyle(
                      color: _difficultyColor,
                      fontSize: 64,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      ' / ${widget.total}',
                      style: const TextStyle(
                        color: AppTheme.textGrey,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              // Difficulty pill
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: _difficultyColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: _difficultyColor.withAlpha(150)),
                ),
                child: Text(
                  widget.difficulty.toUpperCase(),
                  style: TextStyle(
                    color: _difficultyColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),

              if (_isNewHighScore) ...[
                const SizedBox(height: 12),
                ZoomIn(
                  duration: const Duration(milliseconds: 400),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.correctGreen.withAlpha(30),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppTheme.correctGreen, width: 1.5),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: AppTheme.correctGreen, size: 16),
                        SizedBox(width: 6),
                        Text(
                          '🎉 NEW HIGH SCORE!',
                          style: TextStyle(
                            color: AppTheme.correctGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Tab bar ─────────────────────────────────────────────────

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: TabBar(
          controller: _tabController,
          labelColor: AppTheme.cskBlue,
          unselectedLabelColor: AppTheme.textGrey,
          indicator: BoxDecoration(
            color: AppTheme.cskYellow,
            borderRadius: BorderRadius.circular(12),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            letterSpacing: 0.5,
          ),
          tabs: const [
            Tab(text: '📊  Stats'),
            Tab(text: '🏅  Leaderboard'),
          ],
        ),
      ),
    );
  }

  // ── Stats tab ───────────────────────────────────────────────

  Widget _buildStatsTab() {
    return FadeIn(
      duration: const Duration(milliseconds: 400),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        child: Column(
          children: [
            // Stat cards row
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    icon: Icons.star_rounded,
                    label: 'Best Score',
                    value: '$_highScore / ${widget.total}',
                    color: AppTheme.cskYellow,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statCard(
                    icon: Icons.local_fire_department,
                    label: 'Best Streak',
                    value: widget.bestStreak > 0
                        ? '🔥 ${widget.bestStreak}'
                        : '—',
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Accuracy bar
            _accuracyCard(),
          ],
        ),
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textGrey,
              fontSize: 11,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _accuracyCard() {
    final accuracy = widget.score / widget.total;
    final pct = (accuracy * 100).toStringAsFixed(0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Accuracy',
                style: TextStyle(
                  color: AppTheme.textGrey,
                  fontSize: 13,
                  letterSpacing: 1,
                ),
              ),
              Text(
                '$pct%',
                style: TextStyle(
                  color: _difficultyColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: accuracy,
              minHeight: 10,
              backgroundColor: AppTheme.darkBg,
              valueColor:
                  AlwaysStoppedAnimation<Color>(_difficultyColor),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${widget.score} correct out of ${widget.total} questions',
            style: const TextStyle(
              color: AppTheme.textGrey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ── Leaderboard tab ─────────────────────────────────────────

  Widget _buildLeaderboardTab() {
    return FadeIn(
      duration: const Duration(milliseconds: 400),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Text(
                  'Top Scores',
                  style: TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _difficultyColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: _difficultyColor.withAlpha(120)),
                  ),
                  child: Text(
                    widget.difficulty.toUpperCase(),
                    style: TextStyle(
                      color: _difficultyColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Leaderboard entries
            Expanded(
              child: _leaderboard.isEmpty
                  ? const Center(
                      child: Text(
                        'No scores yet!\nBe the first legend 🏏',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppTheme.textGrey, fontSize: 15),
                      ),
                    )
                  : ListView.separated(
                      itemCount: _leaderboard.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final entry = _leaderboard[i];
                        final isCurrentRun =
                            entry.label == 'You (this run)';
                        return _leaderboardRow(
                          rank: i + 1,
                          entry: entry,
                          isCurrentRun: isCurrentRun,
                          total: widget.total,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _leaderboardRow({
    required int rank,
    required _LeaderEntry entry,
    required bool isCurrentRun,
    required int total,
  }) {
    final rankEmoji = rank == 1
        ? '🥇'
        : rank == 2
            ? '🥈'
            : rank == 3
                ? '🥉'
                : '  $rank';

    final rankColor = rank == 1
        ? const Color(0xFFFFD700)
        : rank == 2
            ? const Color(0xFFC0C0C0)
            : rank == 3
                ? const Color(0xFFCD7F32)
                : AppTheme.textGrey;

    return AnimatedScale(
      scale: 1.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isCurrentRun
              ? AppTheme.cskYellow.withAlpha(20)
              : AppTheme.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCurrentRun
                ? AppTheme.cskYellow.withAlpha(120)
                : AppTheme.cardBorder,
            width: isCurrentRun ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Rank
            SizedBox(
              width: 36,
              child: Text(
                rankEmoji,
                style: TextStyle(
                  fontSize: rank <= 3 ? 22 : 14,
                  color: rankColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Label + streak
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isCurrentRun ? 'You (this run) ✨' : entry.label,
                    style: TextStyle(
                      color: isCurrentRun
                          ? AppTheme.cskYellow
                          : AppTheme.textLight,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (entry.streak > 1) ...[
                    const SizedBox(height: 2),
                    Text(
                      '🔥 ${entry.streak} streak',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Score
            Text(
              '${entry.score}/$total',
              style: TextStyle(
                color: rank == 1 ? const Color(0xFFFFD700) : AppTheme.cskYellow,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Action buttons ──────────────────────────────────────────

  Widget _buildActions() {
    return FadeInUp(
      delay: const Duration(milliseconds: 500),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        child: Column(
          children: [
            // Play again (primary)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.replay, color: AppTheme.cskBlue),
                label: const Text(
                  'PLAY AGAIN',
                  style: TextStyle(
                    color: AppTheme.cskBlue,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.cskYellow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const LevelScreen()),
                    (route) => false,
                  );
                },
              ),
            ),
            const SizedBox(height: 10),

            // Home (secondary)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.home_outlined,
                    color: AppTheme.textGrey),
                label: const Text(
                  'Home',
                  style: TextStyle(color: AppTheme.textGrey),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                      color: AppTheme.textGrey.withAlpha(80)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const HomeScreen()),
                    (route) => false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────

  Widget _glowCircle(double size, Color color, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withAlpha((opacity * 255).toInt()),
      ),
    );
  }
}

// ── Leaderboard entry model ──────────────────────────────────

class _LeaderEntry {
  final int score;
  final int streak;
  final String label;

  const _LeaderEntry({
    required this.score,
    required this.streak,
    required this.label,
  });
}