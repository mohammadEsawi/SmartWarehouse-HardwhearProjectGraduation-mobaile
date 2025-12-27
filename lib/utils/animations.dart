import 'dart:math';

import 'package:flutter/material.dart';

class AppAnimations {
  static BuildContext? get context => null;

  // Fade in animation
  static Widget fadeIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeIn,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: child,
    );
  }

  // Slide in animation
  static Widget slideIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOut,
    Offset begin = const Offset(0, 0.1),
    Offset end = Offset.zero,
  }) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween<Offset>(begin: begin, end: end),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: value,
          child: child,
        );
      },
      child: child,
    );
  }

  // Scale animation
  static Widget scaleIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.elasticOut,
    double begin = 0.8,
    double end = 1.0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: begin, end: end),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }

  // Rotation animation
  static Widget rotate({
    required Widget child,
    Duration duration = const Duration(seconds: 1),
    bool infinite = false,
    double turns = 1.0,
  }) {
    return RotationTransition(
      turns: infinite
          ? const AlwaysStoppedAnimation(360 / 360)
          : Tween<double>(begin: 0, end: turns).animate(
              CurvedAnimation(
                parent: ModalRoute.of(context!)!.animation!,
                curve: Curves.linear,
              ),
            ),
      child: child,
    );
  }

  // Pulse animation
  static Widget pulse({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1000),
    bool infinite = true,
    double minScale = 0.95,
    double maxScale = 1.05,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: minScale, end: maxScale),
      duration: duration,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }

  // Shake animation
  static Widget shake({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
    double intensity = 10.0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: duration,
      builder: (context, value, child) {
        final shake = sin(value * 2 * pi) * intensity * (1 - value);
        return Transform.translate(
          offset: Offset(shake, 0),
          child: child,
        );
      },
      child: child,
    );
  }

  // Bounce animation
  static Widget bounce({
    required Widget child,
    Duration duration = const Duration(milliseconds: 800),
    double height = 20.0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: duration,
      builder: (context, value, child) {
        final bounce = sin(value * 2 * pi) * height * (1 - value);
        return Transform.translate(
          offset: Offset(0, -bounce),
          child: child,
        );
      },
      child: child,
    );
  }

  // Staggered list animation
  static Widget staggeredList({
    required List<Widget> children,
    Duration delay = const Duration(milliseconds: 100),
    Curve curve = Curves.easeOut,
  }) {
    return Column(
      children: [
        for (int i = 0; i < children.length; i++)
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 300 + (i * delay.inMilliseconds)),
            curve: curve,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: children[i],
          ),
      ],
    );
  }

  // Animated container with border
  static Widget animatedContainer({
    required Widget child,
    required bool isActive,
    Color activeColor = Colors.green,
    Color inactiveColor = Colors.grey,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return AnimatedContainer(
      duration: duration,
      decoration: BoxDecoration(
        border: Border.all(
          color: isActive ? activeColor : inactiveColor,
          width: isActive ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  // Conveyor movement animation
  static Widget conveyorMovement({
    required Widget child,
    required bool isMoving,
    Duration duration = const Duration(milliseconds: 1000),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: isMoving ? 1.0 : 0.0),
      duration: duration,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(value * 100, 0),
          child: child,
        );
      },
      child: child,
    );
  }

  // Sensor pulse animation
  static Widget sensorPulse({
    required Widget child,
    required bool isActive,
    Color activeColor = Colors.green,
    Duration duration = const Duration(milliseconds: 1000),
  }) {
    return AnimatedContainer(
      duration: duration,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? activeColor.withOpacity(0.3) : Colors.transparent,
        border: Border.all(
          color: isActive ? activeColor : Colors.grey,
          width: isActive ? 2 : 1,
        ),
      ),
      child: child,
    );
  }

  // Loading shimmer effect
  static Widget shimmer({
    required Widget child,
    bool isLoading = true,
    Color baseColor = const Color(0xFF334155),
    Color highlightColor = const Color(0xFF475569),
  }) {
    if (!isLoading) return child;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: child,
    );
  }
}

class Shimmer extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;

  const Shimmer({
    super.key,
    required this.child,
    required this.baseColor,
    required this.highlightColor,
  });

  @override
  State<Shimmer> createState() => _ShimmerState();

  static Widget fromColors({
    required Widget child,
    required Color baseColor,
    required Color highlightColor,
  }) {
    return Shimmer(
      child: child,
      baseColor: baseColor,
      highlightColor: highlightColor,
    );
  }
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _ShimmerPainter(
            progress: _controller.value,
            baseColor: widget.baseColor,
            highlightColor: widget.highlightColor,
          ),
          child: widget.child,
        );
      },
    );
  }
}

class _ShimmerPainter extends CustomPainter {
  final double progress;
  final Color baseColor;
  final Color highlightColor;

  _ShimmerPainter({
    required this.progress,
    required this.baseColor,
    required this.highlightColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gradient = LinearGradient(
      colors: [baseColor, highlightColor, baseColor],
      stops: const [0.0, 0.5, 1.0],
      begin: const Alignment(-1.0, 0.0),
      end: const Alignment(1.0, 0.0),
    );

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(-size.width * progress, 0, size.width * 3, size.height),
      );

    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}