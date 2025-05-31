import 'package:flutter/material.dart';

class Ball {
  double x;
  double y;
  final Color color;
  final double radius;
  final double speed;

  Ball({
    required this.x,
    required this.y,
    required this.color,
    this.radius = 20,
    this.speed = 2,
  });
} 