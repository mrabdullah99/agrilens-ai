import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../theme/app_theme.dart';
import 'image_preview_screen.dart';
import '../widgets/action_button.dart';
import '../widgets/supported_classes_card.dart';
import '../utils/page_transitions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final XFile? picked = await ImagePicker().pickImage(source: source);
    if (picked == null || !context.mounted) return;
    Navigator.push(
      context,
      slideFadeRoute(ImagePreviewScreen(imageFile: File(picked.path))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HeroHeader(theme: theme),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SectionHeading(
                        icon: Icons.bolt_rounded,
                        title: "Start Analysis",
                        color: AppTheme.leafGreen,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ActionButton(
                              icon: Icons.photo_library,
                              label: "Gallery",
                              subtitle: "Pick from files",
                              color: AppTheme.leafGreen,
                              onPressed: () => _pickImage(context, ImageSource.gallery),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ActionButton(
                              icon: Icons.camera_alt,
                              label: "Camera",
                              subtitle: "Take a photo",
                              color: AppTheme.maizeGold,
                              onPressed: () => _pickImage(context, ImageSource.camera),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      const _HowItWorks(),
                      const SizedBox(height: 32),
                      _SectionHeading(
                        icon: Icons.spa_outlined,
                        title: "Supported Deficiencies",
                        color: AppTheme.maizeGold,
                      ),
                      const SizedBox(height: 16),
                      const SupportedClassesCard(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Gradient hero banner with wave-shaped bottom edge, glossy diagonal shine,
/// layered decorative circles, and the app title merged into the header.
class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return ClipPath(
      clipper: _WaveClipper(),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(24, topPadding + 20, 24, 64),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.leafGreen.withValues(alpha: 0.92),
              AppTheme.leafGreen,
              AppTheme.leafGreen.withValues(alpha: 0.75),
            ],
            stops: const [0.0, 0.55, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.leafGreen.withValues(alpha: 0.35),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // decorative depth circles
            Positioned(
              top: -30,
              right: -30,
              child: _decorCircle(100, Colors.white.withValues(alpha: 0.08)),
            ),
            Positioned(
              top: 60,
              right: -60,
              child: _decorCircle(70, Colors.white.withValues(alpha: 0.06)),
            ),
            Positioned(
              bottom: -10,
              left: -30,
              child: _decorCircle(130, Colors.white.withValues(alpha: 0.06)),
            ),
            // glossy diagonal shine
            Positioned(
              top: -40,
              left: -60,
              child: Transform.rotate(
                angle: -0.5,
                child: Container(
                  width: 260,
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.14),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.eco, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "AgriLens AI",
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.psychology_outlined, size: 40, color: AppTheme.leafGreen),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Smart Leaf Analysis",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Detect maize nutrient deficiencies instantly using AI technology",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.4,
                  ),
                ),
              ],
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

/// Subtle wave cut along the bottom edge of the hero, instead of a flat
/// rounded rectangle, for a softer transition into the body below.
class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 36);
    path.quadraticBezierTo(size.width * 0.25, size.height, size.width * 0.5, size.height - 18);
    path.quadraticBezierTo(size.width * 0.75, size.height - 36, size.width, size.height - 8);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _WaveClipper oldClipper) => false;
}

/// Small icon + label heading used above each section.
class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.icon, required this.title, required this.color});

  final IconData icon;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 10),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }
}

/// 3-step "Upload → Analyze → Results" strip for a bit of onboarding polish.
class _HowItWorks extends StatelessWidget {
  const _HowItWorks();

  @override
  Widget build(BuildContext context) {
    final steps = [
      (Icons.upload_file_rounded, "Upload"),
      (Icons.auto_awesome, "Analyze"),
      (Icons.fact_check_outlined, "Results"),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (int i = 0; i < steps.length; i++) ...[
            _StepIcon(icon: steps[i].$1, label: steps[i].$2),
            if (i != steps.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _StepIcon extends StatelessWidget {
  const _StepIcon({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.leafGreen.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 22, color: AppTheme.leafGreen),
        ),
        const SizedBox(height: 6),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}