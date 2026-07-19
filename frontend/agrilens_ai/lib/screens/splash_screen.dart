import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/page_transitions.dart';
import 'main_nav_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  static const Duration _splashDuration = Duration(seconds: 2);

  late final AnimationController _entrance;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _titleFade;
  late final Animation<double> _underlineWidth;
  late final Animation<double> _subtitleFade;

  late final AnimationController _progress;
  late final AnimationController _glow;
  late final AnimationController _float;

  @override
  void initState() {
    super.initState();

    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _entrance, curve: const Interval(0.0, 0.5, curve: Curves.elasticOut)),
    );
    _logoFade = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
    );
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _entrance, curve: const Interval(0.35, 0.7, curve: Curves.easeOutCubic)),
    );
    _titleFade = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.35, 0.7, curve: Curves.easeOut),
    );
    _underlineWidth = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.55, 0.85, curve: Curves.easeOut),
    );
    _subtitleFade = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
    );
    _entrance.forward();

    // fills exactly over the splash duration, so it completes right as we navigate
    _progress = AnimationController(vsync: this, duration: _splashDuration)..forward();

    // slow breathing glow behind the logo badge, loops indefinitely
    _glow = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);

    // slow drifting float for the background leaf particles, loops indefinitely
    _float = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();

    Future.delayed(_splashDuration, () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        slideFadeRoute(const MainNavScreen()),
      );
    });
  }

  @override
  void dispose() {
    _entrance.dispose();
    _progress.dispose();
    _glow.dispose();
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.leafGreen.withValues(alpha: 0.92),
              AppTheme.leafGreen,
              AppTheme.leafGreen.withValues(alpha: 0.78),
            ],
            stops: const [0.0, 0.55, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // decorative depth circles
            Positioned(
              top: -50,
              right: -50,
              child: _decorCircle(160, Colors.white.withValues(alpha: 0.07)),
            ),
            Positioned(
              bottom: -60,
              left: -40,
              child: _decorCircle(180, Colors.white.withValues(alpha: 0.06)),
            ),
            Positioned(
              top: 100,
              left: -30,
              child: _decorCircle(80, Colors.white.withValues(alpha: 0.05)),
            ),

            // slow-drifting leaf particles scattered across the screen
            _FloatingLeaves(controller: _float),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeTransition(
                  opacity: _logoFade,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: SizedBox(
                      width: 140,
                      height: 140,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // breathing radial glow behind the badge
                          AnimatedBuilder(
                            animation: _glow,
                            builder: (context, child) {
                              final scale = 1.0 + (_glow.value * 0.18);
                              return Transform.scale(
                                scale: scale,
                                child: Container(
                                  width: 110,
                                  height: 110,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        Colors.white.withValues(alpha: 0.22 * (1 - _glow.value * 0.4)),
                                        Colors.white.withValues(alpha: 0.0),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              shape: BoxShape.circle,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.12),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.grass, size: 56, color: AppTheme.leafGreen),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                FadeTransition(
                  opacity: _titleFade,
                  child: SlideTransition(
                    position: _titleSlide,
                    child: Text(
                      "AgriLens AI",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                AnimatedBuilder(
                  animation: _underlineWidth,
                  builder: (context, child) {
                    return Container(
                      width: 48 * _underlineWidth.value,
                      height: 3,
                      decoration: BoxDecoration(
                        color: AppTheme.maizeGold,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),
                FadeTransition(
                  opacity: _subtitleFade,
                  child: Text(
                    "Maize Leaf Nutrient Detection",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FadeTransition(
                  opacity: _subtitleFade,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_awesome, size: 13, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          "AI-Powered",
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // progress bar synced to the splash duration
            Positioned(
              bottom: 56,
              child: FadeTransition(
                opacity: _subtitleFade,
                child: AnimatedBuilder(
                  animation: _progress,
                  builder: (context, child) {
                    return Container(
                      width: 140,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: _progress.value.clamp(0.0, 1.0),
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppTheme.maizeGold,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _decorCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/// A handful of small leaf glyphs drifting slowly up and down in the
/// background, for a bit of organic movement behind the main content.
class _FloatingLeaves extends StatelessWidget {
  const _FloatingLeaves({required this.controller});

  final AnimationController controller;

  static const List<_LeafSpec> _leaves = [
    _LeafSpec(alignment: Alignment(-0.75, -0.55), size: 22, phase: 0.0),
    _LeafSpec(alignment: Alignment(0.8, -0.35), size: 16, phase: 1.4),
    _LeafSpec(alignment: Alignment(-0.65, 0.55), size: 18, phase: 2.6),
    _LeafSpec(alignment: Alignment(0.7, 0.6), size: 14, phase: 3.8),
    _LeafSpec(alignment: Alignment(-0.35, -0.8), size: 12, phase: 5.0),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final t = controller.value * 2 * math.pi;
        return Stack(
          children: [
            for (final leaf in _leaves)
              Align(
                alignment: leaf.alignment,
                child: Transform.translate(
                  offset: Offset(0, math.sin(t + leaf.phase) * 10),
                  child: Opacity(
                    opacity: 0.10 + 0.06 * (1 + math.sin(t + leaf.phase)) / 2,
                    child: Icon(Icons.eco, size: leaf.size, color: Colors.white),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _LeafSpec {
  const _LeafSpec({required this.alignment, required this.size, required this.phase});

  final Alignment alignment;
  final double size;
  final double phase;
}