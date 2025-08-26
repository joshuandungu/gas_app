import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _blinkController;
  late final AnimationController _boomController;
  late final Animation<double> _opacityAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Blinking animation (3 blinks in ~2 seconds)
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );

    // Boom effect (scale up + fade out)
    _boomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 6.0).animate(
      CurvedAnimation(parent: _boomController, curve: Curves.easeOut),
    );

    // Sequence: blink 3 times → boom → navigate
    Timer(const Duration(seconds: 2), () async {
      await _blinkController.forward(from: 0);
      _blinkController.stop();
      _boomController.forward();

      // Navigate after boom finishes
      _boomController.addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      });
    });
  }

  @override
  void dispose() {
    _blinkController.dispose();
    _boomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade300, Colors.blue.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([_blinkController, _boomController]),
            builder: (context, child) {
              double opacity = _boomController.isAnimating
                  ? 1.0 - _boomController.value // fade out on boom
                  : _opacityAnimation.value;

              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: opacity,
                  child: const Text(
                    "LA",
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 4,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
