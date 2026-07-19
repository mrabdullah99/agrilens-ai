import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/prediction_result.dart';
import '../theme/app_theme.dart';
import 'loading_screen.dart';
import 'result_screen.dart';
import '../widgets/image_preview_card.dart';
import '../utils/page_transitions.dart';
import '../services/history_service.dart';
import '../providers/settings_provider.dart';

class ImagePreviewScreen extends StatelessWidget {
  final File imageFile;

  ImagePreviewScreen({super.key, required this.imageFile});

  final ApiService _apiService = ApiService();

  Future<void> _analyze(BuildContext context) async {
    final settings = Provider.of<SettingsProvider>(context, listen: false);

    Navigator.push(
      context,
      slideFadeRoute(LoadingScreen(imageFile: imageFile)),
    );

    try {
      final PredictionResult result = await _apiService.predict(imageFile);

      if (settings.saveToHistory) {
        await HistoryService.instance.savePrediction(result);
      }

      if (!context.mounted) return;
      Navigator.pop(context); // Pop loading screen
      Navigator.push(
        context,
        slideFadeRoute(ResultScreen(result: result)),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Preview"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Hero(
                  tag: "leaf_image",
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: ImagePreviewCard(imageFile: imageFile, height: double.infinity),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.leafGreen.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline, size: 18, color: AppTheme.leafGreen),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Make sure the leaf fills the frame and is clearly lit for the best result.",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.75),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.refresh),
                      label: const Text("Retake"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: AppTheme.leafGreen.withValues(alpha: 0.4)),
                        foregroundColor: AppTheme.leafGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(
                          colors: [AppTheme.leafGreen, AppTheme.leafGreen.withValues(alpha: 0.8)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.leafGreen.withValues(alpha: 0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () => _analyze(context),
                        icon: const Icon(Icons.auto_awesome, size: 20),
                        label: const Text("Analyze"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}