import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/level_screen.dart';
import 'screens/game_screen.dart';

void main() {
  runApp(const CricketQuizApp());
}

class CricketQuizApp extends StatelessWidget {
  const CricketQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cricket Quiz 🏏',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.cskTheme,
      initialRoute: '/',
      routes: {
        '/':             (context) => const HomeScreen(),
        '/level':        (context) => const LevelScreen(),
        '/game/easy':    (context) => const GameScreen(difficulty: 'easy'),
        '/game/medium':  (context) => const GameScreen(difficulty: 'medium'),
        '/game/hard':    (context) => const GameScreen(difficulty: 'hard'),
      },
    );
  }
}