// import 'package:flutter/material.dart';
//
// class LoadingScreen extends StatelessWidget {
//   const LoadingScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             CircularProgressIndicator(),
//             SizedBox(height: 16),
//             Text("Analyzing leaf image..."),
//           ],
//         ),
//       ),
//     );
//   }
// }



import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LoadingScreen extends StatefulWidget {
  final File imageFile;

  const LoadingScreen({super.key, required this.imageFile});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Hero(
                  tag: "leaf_image",
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(widget.imageFile, width: 220, height: 220, fit: BoxFit.cover),
                  ),
                ),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Positioned(
                      top: 220 * _controller.value,
                      child: Container(
                        width: 220,
                        height: 3,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.maizeGold.withValues(alpha: 0.0),
                              AppTheme.maizeGold,
                              AppTheme.maizeGold.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text("Analyzing leaf image...", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text("Running Grad-CAM diagnosis"),
          ],
        ),
      ),
    );
  }
}