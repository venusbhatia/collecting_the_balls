import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'ball.dart';
import 'screens.dart';

class GameScreen extends StatefulWidget {
  final Function(int) onGameOver;

  const GameScreen({
    Key? key,
    required this.onGameOver,
  }) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  final double binWidth = 100;
  final double binHeight = 80;
  double binX = 100;
  double screenWidth = 0;
  double screenHeight = 0;
  int score = 0;
  int missed = 0;
  bool gameOver = false;
  List<Ball> balls = [];
  Timer? gameTimer;
  Random random = Random();
  List<_Star> stars = [];

  // Animation controllers
  late AnimationController scoreController;
  late AnimationController binSquashController;
  late AnimationController backgroundController;
  List<_Particle> particles = [];

  @override
  void initState() {
    super.initState();
    scoreController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      lowerBound: 1.0,
      upperBound: 1.5,
    );
    binSquashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      lowerBound: 1.0,
      upperBound: 1.2,
    );
    backgroundController = AnimationController(
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      screenWidth = MediaQuery.of(context).size.width;
      screenHeight = MediaQuery.of(context).size.height;
      binX = (screenWidth - binWidth) / 2;
      startGame();
    });
  }

  void startGame() {
    setState(() {
      score = 0;
      missed = 0;
      gameOver = false;
      balls.clear();
      particles.clear();
      binX = (screenWidth - binWidth) / 2;
    });
    gameTimer?.cancel();
    gameTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      updateBalls();
      updateParticles();
      updateStars();
      if (random.nextDouble() < 0.01) {
        spawnBall();
      }
    });
  }

  void updateStars() {
    setState(() {
      for (var star in stars) {
        star.y += star.size / 1000;
        if (star.y > 1) {
          star.y = 0;
          star.x = random.nextDouble();
        }
      }
    });
  }

  void spawnBall() {
    double x = random.nextDouble() * (screenWidth - 40) + 20;
    List<Color> ballColors = [
      const Color(0xFFFF6B6B),  // Coral Red
      const Color(0xFF4ECDC4),  // Turquoise
      const Color(0xFFFFBE0B),  // Yellow
      const Color(0xFF7400B8),  // Purple
      const Color(0xFF80ED99),  // Mint Green
    ];
    Color color = ballColors[random.nextInt(ballColors.length)];
    balls.add(Ball(x: x, y: 0, color: color));
  }

  void updateBalls() {
    if (gameOver) return;
    setState(() {
      List<Ball> caught = [];
      List<Ball> missedBalls = [];
      for (var ball in balls) {
        ball.y += ball.speed;
        if (ball.y + ball.radius >= screenHeight - binHeight - 10) {
          if (ball.x > binX - ball.radius && ball.x < binX + binWidth + ball.radius) {
            caught.add(ball);
            score++;
            scoreController.forward(from: 0.0).then((_) => scoreController.reverse());
            binSquashController.forward(from: 0.0).then((_) => binSquashController.reverse());
            spawnParticles(ball.x + ball.radius, ball.y + ball.radius, ball.color);
          } else if (ball.y + ball.radius > screenHeight) {
            missedBalls.add(ball);
            missed++;
            if (missed >= 3) {
              gameOver = true;
              gameTimer?.cancel();
              showGameOverDialog();
            }
          }
        }
      }
      balls.removeWhere((b) => caught.contains(b) || missedBalls.contains(b) || b.y > screenHeight + 40);
    });
  }

  void spawnParticles(double x, double y, Color color) {
    for (int i = 0; i < 20; i++) {
      double angle = (2 * pi * i) / 20;
      particles.add(_Particle(
        x: x,
        y: y,
        dx: cos(angle) * (random.nextDouble() * 3 + 2),
        dy: sin(angle) * (random.nextDouble() * 3 + 2),
        color: color,
        life: 30 + random.nextInt(20),
      ));
    }
  }

  void updateParticles() {
    setState(() {
      for (var p in particles) {
        p.x += p.dx;
        p.y += p.dy;
        p.dy += 0.1; // Add gravity effect
        p.life--;
      }
      particles.removeWhere((p) => p.life <= 0);
    });
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameOverScreen(
        score: score,
        highScore: 0, // This will be handled by the parent widget
        onRestart: () {
          Navigator.of(context).pop();
          startGame();
        },
        onHome: () {
          Navigator.of(context).pop();
          widget.onGameOver(score);
        },
      ),
    );
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    scoreController.dispose();
    binSquashController.dispose();
    backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onHorizontalDragUpdate: (details) {
          setState(() {
            binX += details.delta.dx;
            if (binX < 0) binX = 0;
            if (binX > screenWidth - binWidth) binX = screenWidth - binWidth;
          });
        },
        child: Stack(
          children: [
            // Animated background
            Positioned.fill(
              child: AnimatedBuilder(
                animation: backgroundController,
                builder: (context, child) {
                  return Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF1A1A2E),  // Deep blue-black
                          Color(0xFF16213E),  // Navy blue
                          Color(0xFF0F3460),  // Rich blue
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Stars
            ...stars.map((star) => Positioned(
              left: star.x * screenWidth,
              top: star.y * screenHeight,
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
            // Score and Missed
            Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Color(0xFFFFBE0B), size: 24),
                          const SizedBox(width: 8),
                          AnimatedBuilder(
                            animation: scoreController,
                            builder: (context, child) => Transform.scale(
                              scale: scoreController.value,
                              child: Text(
                                'Score: $score',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(blurRadius: 10, color: Color(0xFFFFBE0B)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.favorite, color: missed >= 3 ? Colors.red : const Color(0xFFFF6B6B), size: 24),
                          const SizedBox(width: 8),
                          Text(
                            '${3 - missed}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Particles
            ...particles.map((p) => Positioned(
              left: p.x,
              top: p.y,
              child: Opacity(
                opacity: p.life / 50.0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        p.color,
                        p.color.withOpacity(0.0),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: p.color.withOpacity(0.5),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            )),
            // Balls
            ...balls.map((ball) => Positioned(
              left: ball.x,
              top: ball.y,
              child: _AnimatedBall(ball: ball),
            )),
            // Bin
            AnimatedBuilder(
              animation: binSquashController,
              builder: (context, child) {
                double scaleY = 1.0 - (binSquashController.value - 1.0) * 0.3;
                double scaleX = 1.0 + (binSquashController.value - 1.0) * 0.4;
                return Positioned(
                  left: binX,
                  top: screenHeight - binHeight - 10,
                  child: Transform(
                    alignment: Alignment.bottomCenter,
                    transform: Matrix4.diagonal3Values(scaleX, scaleY, 1),
                    child: _SexyBin(width: binWidth, height: binHeight),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedBall extends StatefulWidget {
  final Ball ball;
  const _AnimatedBall({required this.ball});

  @override
  State<_AnimatedBall> createState() => _AnimatedBallState();
}

class _AnimatedBallState extends State<_AnimatedBall> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _bounceAnim = Tween<double>(begin: 1.0, end: 1.3)
        .chain(CurveTween(curve: Curves.elasticOut))
        .animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounceAnim,
      builder: (context, child) {
        return Transform.scale(
          scale: _bounceAnim.value,
          child: Container(
            width: widget.ball.radius * 2,
            height: widget.ball.radius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withOpacity(0.9),
                  widget.ball.color.withOpacity(0.9),
                  widget.ball.color,
                ],
                stops: const [0.0, 0.3, 1.0],
                center: const Alignment(-0.3, -0.3),
                radius: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.ball.color.withOpacity(0.6),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: widget.ball.color.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SexyBin extends StatelessWidget {
  final double width;
  final double height;
  const _SexyBin({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4ECDC4),  // Turquoise
            Color(0xFF2BAE9F),  // Darker turquoise
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4ECDC4).withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Glossy effect
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: height * 0.4,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.4),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
            ),
          ),
          // Inner shadow
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Particle {
  double x, y, dx, dy;
  Color color;
  int life;
  _Particle({
    required this.x,
    required this.y,
    required this.dx,
    required this.dy,
    required this.color,
    required this.life,
  });
}

class _Star {
  double x, y;
  double size;
  _Star({required this.x, required this.y, required this.size});
} 