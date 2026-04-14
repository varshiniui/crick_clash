import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {

  // ── Animation controllers ─────────────────────────────────
  late AnimationController _controller;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;

  // Button press scale state
  bool _btnPressed = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 900),
    );

    // Logo + title fade in
    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve:  Curves.easeIn,
    );

    // Title slides up from below
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end:   Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve:  Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ── Navigate to level selection ───────────────────────────
  void _startGame() {
    Navigator.pushNamed(context, '/level');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // ── 1. Background gradient ──────────────────────
          _buildBackground(size),

          // ── 2. Decorative cricket-ball circles ──────────
          _buildDecorativeCircles(size),

          // ── 3. Main content ─────────────────────────────
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),

                        // Cricket bat + ball emoji badge
                        _buildEmojiBadge(),

                        const SizedBox(height: 28),

                        // App title
                        _buildTitle(),

                        const SizedBox(height: 12),

                        // Subtitle
                        _buildSubtitle(),

                        const SizedBox(height: 56),

                        // Animated Start button
                        _buildStartButton(),

                        const SizedBox(height: 32),

                        // Bottom flavour text
                        _buildFooterText(),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Widgets ────────────────────────────────────────────────

  Widget _buildBackground(Size size) {
    return Container(
      width:  size.width,
      height: size.height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0D0D1A), // darkBg
            Color(0xFF1A237E), // cskBlue
            Color(0xFF0D0D1A),
          ],
          begin: Alignment.topLeft,
          end:   Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _buildDecorativeCircles(Size size) {
    return Stack(
      children: [
        // Top-right large circle
        Positioned(
          top:   -size.width * 0.2,
          right: -size.width * 0.2,
          child: _glowCircle(size.width * 0.7, AppTheme.cskYellow, 0.07),
        ),
        // Bottom-left circle
        Positioned(
          bottom: -size.width * 0.25,
          left:   -size.width * 0.15,
          child: _glowCircle(size.width * 0.65, AppTheme.cskLightBlue, 0.10),
        ),
      ],
    );
  }

  Widget _glowCircle(double size, Color color, double opacity) {
    return Container(
      width:  size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withAlpha((opacity * 255).toInt()),
      ),
    );
  }

  Widget _buildEmojiBadge() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.cardBg,
        border: Border.all(color: AppTheme.cskYellow, width: 2.5),
        boxShadow: [
          BoxShadow(
            color:      AppTheme.cskYellow.withAlpha(60),
            blurRadius: 30,
            spreadRadius: 4,
          ),
        ],
      ),
      child: const Text(
        '🏏',
        style: TextStyle(fontSize: 64),
      ),
    );
  }

  Widget _buildTitle() {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [AppTheme.cskYellow, Colors.white, AppTheme.cskYellow],
      ).createShader(bounds),
      child: const Text(
        'Cricket\nGuess Game',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize:      42,
          fontWeight:    FontWeight.w900,
          color:         Colors.white,  // masked by shader
          height:        1.1,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    return const Text(
      'How well do you know your\ncricket legends? 🌟',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize:   16,
        color:      AppTheme.textGrey,
        height:     1.5,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildStartButton() {
    return GestureDetector(
      // Scale effect on press
      onTapDown:  (_) => setState(() => _btnPressed = true),
      onTapUp:    (_) => setState(() => _btnPressed = false),
      onTapCancel: () => setState(() => _btnPressed = false),
      onTap:      _startGame,
      child: AnimatedScale(
        scale:    _btnPressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width:   double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD54F), AppTheme.cskYellow, Color(0xFFFFB300)],
            ),
            boxShadow: [
              BoxShadow(
                color:      AppTheme.cskYellow.withAlpha(100),
                blurRadius: 20,
                spreadRadius: 2,
                offset:     const Offset(0, 6),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sports_cricket, color: AppTheme.cskBlue, size: 24),
              SizedBox(width: 10),
              Text(
                'START GAME',
                style: TextStyle(
                  color:      AppTheme.cskBlue,
                  fontSize:   20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: 40, height: 1, color: AppTheme.textGrey.withAlpha(80)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Powered by cricket spirit',
            style: TextStyle(color: AppTheme.textGrey, fontSize: 13),
          ),
        ),
        Container(width: 40, height: 1, color: AppTheme.textGrey.withAlpha(80)),
      ],
    );
  }
}