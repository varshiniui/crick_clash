import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:string_similarity/string_similarity.dart';

import '../data/player_data.dart';
import '../models/player.dart';
import '../theme/app_theme.dart';
import 'result_screen.dart';
import 'dart:async';

class GameScreen extends StatefulWidget {
  final String difficulty;
  const GameScreen({super.key, required this.difficulty});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<Player> _players = [];
  int _currentIndex = 0;
  int _score = 0;
  int _streak = 0;
  int _bestStreak = 0;
  bool _isLoading = true;
  bool _answered = false;
  bool _isCorrect = false;
  int _animationKey = 0;

  // --- Timer variables ---
  Timer? _timer;
  int _timeLeft = 15;
  static const int _maxTime = 15;

  static const double _similarityThreshold = 0.75;
  static const int _totalQuestions = 3;

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadPlayers() async {
    try {
      final players = await PlayerData.loadByDifficulty(widget.difficulty);
      print("PLAYERS COUNT: ${players.length}");
      players.shuffle();
      setState(() {
        _players = players.take(_totalQuestions).toList();
        _isLoading = false;
      });
      _startTimer(); // ✅ Fixed: moved outside setState, after players load
    } catch (e) {
      print("ERROR LOADING PLAYERS: $e");
      setState(() {
        _isLoading = false;
        _players = [];
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timeLeft = _maxTime;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft <= 1) {
        timer.cancel();
        if (!_answered) {
          setState(() {
            _answered = true;
            _isCorrect = false;
            _streak = 0;
          });
          _focusNode.unfocus();
        }
      } else {
        setState(() {
          _timeLeft--;
        });
      }
    });
  }

  Player get _currentPlayer => _players[_currentIndex];

  void _checkAnswer() {
    _timer?.cancel();
    final userAnswer = _controller.text.trim().toLowerCase();
    final correctAnswer = _currentPlayer.name.toLowerCase();

    bool correct = userAnswer == correctAnswer;
    if (!correct) {
      for (final alias in _currentPlayer.aliases) {
        if (userAnswer == alias.toLowerCase()) {
          correct = true;
          break;
        }
      }
    }
    if (!correct) {
      final similarity = userAnswer.similarityTo(correctAnswer);
      correct = similarity >= _similarityThreshold;
    }

    setState(() {
      _answered = true;
      _isCorrect = correct;
      if (correct) {
        _score++;
        _streak++;
        if (_streak > _bestStreak) _bestStreak = _streak;
      } else {
        _streak = 0;
      }
    });

    _focusNode.unfocus();
  }

  void _nextQuestion() {
    final isLast = _currentIndex >= _players.length - 1;

    if (isLast) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            score: _score,
            total: _totalQuestions,
            difficulty: widget.difficulty,
            bestStreak: _bestStreak,
          ),
        ),
      );
    } else {
      setState(() {
        _currentIndex++;
        _answered = false;
        _isCorrect = false;
        _animationKey++;
        _controller.clear();
      });
      _startTimer();
      Future.delayed(
        const Duration(milliseconds: 300),
        () => _focusNode.requestFocus(),
      );
    }
  }

  // --- Widget builders ---
  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back button
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textLight),
              onPressed: () => Navigator.pop(context),
            ),

            // Difficulty label (centre)
            Text(
              widget.difficulty.toUpperCase(),
              style: const TextStyle(
                color: AppTheme.textLight,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),

            // Score + streak row
            Row(
              children: [
                // Streak badge — only show if streak > 1
                if (_streak > 1)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orange, width: 1.5),
                    ),
                    child: Text(
                      '🔥 $_streak',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),

                // Score badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.cskYellow,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '⭐ $_score',
                    style: const TextStyle(
                      color: AppTheme.cskBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 8),

        // ✅ Timer bar + countdown (replaces old progress bar)
        Row(
          children: [
            // Countdown number
            Text(
              '$_timeLeft s',
              style: TextStyle(
                color: _timeLeft <= 5 ? AppTheme.wrongRed : AppTheme.textGrey,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),

            // Timer bar
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _timeLeft / _maxTime,
                  minHeight: 6,
                  backgroundColor: AppTheme.cardBg,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _timeLeft <= 5 ? AppTheme.wrongRed : AppTheme.cskYellow,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Question progress
            Text(
              '${_currentIndex + 1}/$_totalQuestions',
              style: const TextStyle(color: AppTheme.textGrey, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlayerImage() {
    print("⚡ Loading image: ${_currentPlayer.imageUrl}");

    return FadeInUp(
      key: ValueKey(_animationKey),
      duration: const Duration(milliseconds: 500),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _answered
                ? (_isCorrect ? AppTheme.correctGreen : AppTheme.wrongRed)
                : AppTheme.cardBorder,
            width: _answered ? 3 : 1.5,
          ),
          color: AppTheme.cardBg,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Image.asset(
            _currentPlayer.imageUrl,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            errorBuilder: (context, error, stackTrace) {
              print("❌ Image load error for '${_currentPlayer.imageUrl}': $error");
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.broken_image,
                        color: AppTheme.textGrey, size: 48),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        _currentPlayer.imageUrl,
                        style: const TextStyle(
                            color: AppTheme.textGrey, fontSize: 11),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackBanner() {
    if (!_answered) return const SizedBox.shrink();

    return FadeIn(
      duration: const Duration(milliseconds: 300),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: _isCorrect
              ? AppTheme.correctGreen.withOpacity(0.15)
              : AppTheme.wrongRed.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _isCorrect ? AppTheme.correctGreen : AppTheme.wrongRed,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Text(
              _isCorrect ? '✅ Correct!' : '❌ Wrong!',
              style: TextStyle(
                color: _isCorrect ? AppTheme.correctGreen : AppTheme.wrongRed,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (!_isCorrect) ...[
              const SizedBox(height: 4),
              Text(
                'Answer: ${_currentPlayer.name}',
                style: const TextStyle(color: AppTheme.textLight, fontSize: 14),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerInput() {
    return Column(
      children: [
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          enabled: !_answered,
          style: const TextStyle(color: AppTheme.textLight, fontSize: 16),
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'Type player name...',
            prefixIcon: Icon(Icons.person, color: AppTheme.cskYellow),
          ),
          onSubmitted: (_) {
            if (!_answered && _controller.text.trim().isNotEmpty) {
              _checkAnswer();
            }
          },
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _answered
                ? _nextQuestion
                : (_controller.text.trim().isEmpty ? null : _checkAnswer),
            child: Text(
              _answered
                  ? (_currentIndex >= _players.length - 1
                      ? 'See Results 🏆'
                      : 'Next Player ➡️')
                  : 'Submit Answer',
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.darkBg,
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.cskYellow),
        ),
      );
    }
    if (_players.isEmpty) {
      return const Scaffold(
        backgroundColor: AppTheme.darkBg,
        body: Center(
          child: Text(
            "No players found 😢",
            style: TextStyle(color: AppTheme.textLight),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),

              // Difficulty badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.cskLightBlue.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.cskLightBlue, width: 1),
                ),
                child: Text(
                  widget.difficulty.toUpperCase(),
                  style: const TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 11,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Expanded(child: _buildPlayerImage()),
              const SizedBox(height: 12),

              _buildFeedbackBanner(),
              if (_answered) const SizedBox(height: 10),

              const Text(
                'Who is this cricket player?',
                style: TextStyle(
                  color: AppTheme.textLight,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              _buildAnswerInput(),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}