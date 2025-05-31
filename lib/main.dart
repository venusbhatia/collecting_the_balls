import 'package:flutter/material.dart';
import 'game_screen.dart';
import 'screens.dart';
import 'dart:math';

void main() {
  runApp(const BallCatcherGame());
}

class BallCatcherGame extends StatefulWidget {
  const BallCatcherGame({Key? key}) : super(key: key);

  @override
  State<BallCatcherGame> createState() => _BallCatcherGameState();
}

class _BallCatcherGameState extends State<BallCatcherGame> {
  int highScore = 0;
  List<int> highScores = [];
  GameScreen? gameScreen;
  String currentScreen = 'welcome'; // welcome, game, highScores

  void updateHighScore(int score) {
    if (score > highScore) {
      setState(() {
        highScore = score;
      });
    }
    // Update high scores list
    setState(() {
      highScores.add(score);
      highScores.sort((a, b) => b.compareTo(a)); // Sort in descending order
      if (highScores.length > 10) {
        highScores = highScores.sublist(0, 10); // Keep only top 10
      }
    });
  }

  void startGame() {
    setState(() {
      currentScreen = 'game';
      gameScreen = GameScreen(
        onGameOver: (score) {
          updateHighScore(score);
          setState(() {
            currentScreen = 'welcome';
          });
        },
      );
    });
  }

  void showHighScores() {
    setState(() {
      currentScreen = 'highScores';
    });
  }

  void goToWelcome() {
    setState(() {
      currentScreen = 'welcome';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Montserrat',
      ),
      home: Builder(
        builder: (context) {
          switch (currentScreen) {
            case 'game':
              return gameScreen!;
            case 'highScores':
              return HighScoreScreen(
                scores: highScores,
                onBack: goToWelcome,
              );
            default:
              return WelcomeScreen(
                highScore: highScore,
                onPlay: startGame,
                onHighScores: showHighScores,
              );
          }
        },
      ),
    );
  }
}
