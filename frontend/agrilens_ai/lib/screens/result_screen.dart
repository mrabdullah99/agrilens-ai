import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/prediction_result.dart';
import '../widgets/image_preview_card.dart';
import '../widgets/confidence_indicator.dart';
import '../theme/app_theme.dart';

import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

/// Visual treatment (color + icon) for each diagnosis, derived from the
/// class set trained in the notebook: Healthy, Nitrogen, Phosphorus,
/// Potassium, Zinc, and Multiple Deficiencies.
class _DiagnosisStyle {
  final Color color;
  final IconData icon;
  final String severityLabel;

  const _DiagnosisStyle({required this.color, required this.icon, required this.severityLabel});

  static _DiagnosisStyle from(String prediction) {
    final p = prediction.toLowerCase();
    if (p.contains('healthy')) {
      return const _DiagnosisStyle(
        color: AppTheme.leafGreen,
        icon: Icons.check_circle,
        severityLabel: "Healthy",
      );
    }
    if (p.contains('multiple')) {
      return const _DiagnosisStyle(
        color: Colors.redAccent,
        icon: Icons.report_problem_rounded,
        severityLabel: "Multiple Deficiencies",
      );
    }
    if (p.contains('nitrogen')) {
      return const _DiagnosisStyle(
        color: AppTheme.maizeGold,
        icon: Icons.grass_rounded,
        severityLabel: "Nutrient Deficiency",
      );
    }
    if (p.contains('phosphorus')) {
      return const _DiagnosisStyle(
        color: AppTheme.maizeGold,
        icon: Icons.science_outlined,
        severityLabel: "Nutrient Deficiency",
      );
    }
    if (p.contains('potassium')) {
      return const _DiagnosisStyle(
        color: AppTheme.maizeGold,
        icon: Icons.bolt_rounded,
        severityLabel: "Nutrient Deficiency",
      );
    }
    if (p.contains('zinc')) {
      return const _DiagnosisStyle(
        color: AppTheme.maizeGold,
        icon: Icons.grain_rounded,
        severityLabel: "Nutrient Deficiency",
      );
    }
    return const _DiagnosisStyle(
      color: AppTheme.maizeGold,
      icon: Icons.warning_rounded,
      severityLabel: "Nutrient Deficiency",
    );
  }
}

class ResultScreen extends StatelessWidget {
  final PredictionResult result;

  const ResultScreen({super.key, required this.result});

  void _showGradcamInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: AppTheme.leafGreen),
                  const SizedBox(width: 12),
                  Text(
                    "Visual Explanation",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                "This is a Grad-CAM visualization. It highlights the specific areas of the leaf "
                    "that the AI model analyzed to reach this diagnosis.",
                style: TextStyle(fontSize: 15, height: 1.5),
              ),
              const SizedBox(height: 12),
              const Text(
                "• Red/Yellow: High influence on prediction\n"
                    "• Blue/Green: Low influence on prediction",
                style: TextStyle(fontSize: 15, height: 1.6, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.leafGreen.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_outlined, color: AppTheme.leafGreen, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Model validated at ~96% test accuracy across 6 leaf conditions.",
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormattedRecommendation(String text, Color color) {
    final paragraphs = text.split("\n\n");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < paragraphs.length; i++) ...[
          if (i > 0) const SizedBox(height: 16),
          _buildParagraph(paragraphs[i], color),
        ],
      ],
    );
  }

  Widget _buildParagraph(String paragraph, Color color) {
    final lines = paragraph.split("\n");
    final isHeaderParagraph = lines.first.trim().endsWith(":");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < lines.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          if (i == 0 && isHeaderParagraph)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                lines[i],
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14.5,
                  color: color,
                  letterSpacing: 0.1,
                ),
              ),
            )
          else if (lines[i].trim().startsWith("•"))
            _buildBulletLine(lines[i].trim().substring(1).trim(), color)
          else
            Text(
              lines[i],
              style: const TextStyle(height: 1.55, fontSize: 15),
            ),
        ],
      ],
    );
  }

  Widget _buildBulletLine(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 7),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(height: 1.5, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!result.isValid) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Analysis Result"),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.warning_amber_rounded, size: 80, color: Colors.orange),
                ),
                const SizedBox(height: 24),
                Text(
                  "Inconclusive Result",
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  result.prediction,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                    child: const Text("Try Another Image"),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final settings = Provider.of<SettingsProvider>(context);
    final showGradcam = settings.showGradcam;
    final displayedBase64 = showGradcam || result.originalImageBase64.isEmpty
        ? result.gradcamBase64
        : result.originalImageBase64;
    final Uint8List gradcamBytes = base64Decode(displayedBase64);
    final style = _DiagnosisStyle.from(result.prediction);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Analysis Result"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Sharing feature coming soon!")),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Section
            Stack(
              children: [
                Hero(
                  tag: "result_image",
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: ImagePreviewCard(imageBytes: gradcamBytes, height: 320),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.info_outline, color: Colors.white, size: 22),
                      onPressed: () => _showGradcamInfo(context),
                      tooltip: "Visual explanation",
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(showGradcam ? Icons.visibility : Icons.photo, color: Colors.white, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          showGradcam ? "AI Heatmap" : "Original Photo",
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Prediction Title & Status
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Diagnosis",
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        result.prediction,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: style.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(style.icon, color: style.color, size: 28),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Confidence Indicator
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor.withValues(alpha: 0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "AI Confidence Score",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.leafGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "~96% validated accuracy",
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.leafGreen),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ConfidenceIndicator(confidence: result.confidence),
                ],
              ),
            ),

            // Top predictions breakdown — only renders once the backend
            // sends `top_predictions`; otherwise this section is skipped.
            if (result.topPredictions != null && result.topPredictions!.isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.dividerColor.withValues(alpha: 0.05)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Other Possibilities",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 14),
                    for (final cp in result.topPredictions!)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _TopPredictionRow(prediction: cp),
                      ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Recommendation Section
            // Recommendation Section
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: style.color.withValues(alpha: 0.15)),
                boxShadow: [
                  BoxShadow(
                    color: style.color.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Left accent bar for quick color identification
                    Container(
                      width: 5,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [style.color, style.color.withValues(alpha: 0.5)],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 20, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: style.color.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(Icons.lightbulb_rounded, color: style.color, size: 20),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    "Recommendation",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      letterSpacing: 0.2,
                                      color: style.color,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: style.color.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      style.severityLabel,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: style.color,
                                        letterSpacing: 0.3,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Divider(color: style.color.withValues(alpha: 0.12), height: 1),
                            const SizedBox(height: 16),
                            _buildFormattedRecommendation(result.recommendation, style.color),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Action Button
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text("ANALYZE ANOTHER LEAF"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                textStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _TopPredictionRow extends StatelessWidget {
  const _TopPredictionRow({required this.prediction});

  final ClassPrediction prediction;

  @override
  Widget build(BuildContext context) {
    final style = _DiagnosisStyle.from(prediction.label);
    final pct = prediction.confidence.clamp(0, 100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(style.icon, size: 14, color: style.color),
                const SizedBox(width: 6),
                Text(prediction.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
            Text(
              "${pct.toStringAsFixed(1)}%",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: style.color),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: pct / 100,
            minHeight: 6,
            backgroundColor: style.color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(style.color),
          ),
        ),
      ],
    );
  }
}