import 'package:flutter/material.dart';
import 'dart:math';

class WelcomeScreen extends StatefulWidget {
  final Function() onPlay;
  final Function() onHighScores;
  final int highScore;

  const WelcomeScreen({
    Key? key,
    required this.onPlay,
    required this.onHighScores,
    required this.highScore,
  }) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<_Star> stars = [];
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Initialize stars
    for (int i = 0; i < 50; i++) {
      stars.add(_Star(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 3 + 1,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with stars
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF1A1A2E),
                    Color(0xFF16213E),
                    Color(0xFF0F3460),
                  ],
                ),
              ),
            ),
          ),
          // Animated stars
          ...stars.map((star) => Positioned(
            left: star.x * MediaQuery.of(context).size.width,
            top: star.y * MediaQuery.of(context).size.height,
            child: Container(
              width: star.size,
              height: star.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.5),
                    blurRadius: star.size,
                  ),
                ],
              ),
            ),
          )),
          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF4ECDC4), Color(0xFFFFBE0B)],
                  ).createShader(bounds),
                  child: const Text(
                    'Ball Catcher',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'High Score: ${widget.highScore}',
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 50),
                // Play button
                _GlowingButton(
                  onPressed: widget.onPlay,
                  text: 'Play',
                  color: const Color(0xFF4ECDC4),
                ),
                const SizedBox(height: 20),
                // High scores button
                _GlowingButton(
                  onPressed: widget.onHighScores,
                  text: 'High Scores',
                  color: const Color(0xFFFFBE0B),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HighScoreScreen extends StatelessWidget {
  final List<int> scores;
  final Function() onBack;

  const HighScoreScreen({
    Key? key,
    required this.scores,
    required this.onBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F3460),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: onBack,
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    ),
                    const Expanded(
                      child: Text(
                        'High Scores',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 40), // For symmetry
                  ],
                ),
              ),
              // Scores list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: scores.length,
                  itemBuilder: (context, index) {
                    final score = scores[index];
                    final isTop3 = index < 3;
                    final colors = [
                      const Color(0xFFFFD700), // Gold
                      const Color(0xFFC0C0C0), // Silver
                      const Color(0xFFCD7F32), // Bronze
                    ];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: isTop3 ? colors[index].withOpacity(0.5) : Colors.white24,
                        ),
                      ),
                      child: Row(
                        children: [
                          if (isTop3) ...[
                            Icon(
                              Icons.emoji_events,
                              color: colors[index],
                              size: 30,
                            ),
                            const SizedBox(width: 15),
                          ],
                          Text(
                            '#${index + 1}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isTop3 ? colors[index] : Colors.white70,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Text(
                            score.toString(),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isTop3 ? colors[index] : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GameOverScreen extends StatelessWidget {
  final int score;
  final int highScore;
  final Function() onRestart;
  final Function() onHome;

  const GameOverScreen({
    Key? key,
    required this.score,
    required this.highScore,
    required this.onRestart,
    required this.onHome,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isNewHighScore = score > highScore;

    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isNewHighScore) ...[
                const Icon(
                  Icons.emoji_events,
                  color: Color(0xFFFFD700),
                  size: 50,
                ),
                const SizedBox(height: 10),
                const Text(
                  'New High Score!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFD700),
                  ),
                ),
              ] else
                const Text(
                  'Game Over',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              const SizedBox(height: 20),
              Text(
                'Score: $score',
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              _GlowingButton(
                onPressed: onRestart,
                text: 'Play Again',
                color: const Color(0xFF4ECDC4),
              ),
              const SizedBox(height: 15),
              _GlowingButton(
                onPressed: onHome,
                text: 'Home',
                color: const Color(0xFFFFBE0B),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlowingButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color color;

  const _GlowingButton({
    required this.onPressed,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _Star {
  double x, y;
  double size;
  _Star({required this.x, required this.y, required this.size});
} 