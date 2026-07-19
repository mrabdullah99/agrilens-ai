import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/history_service.dart';
import '../models/history_entry.dart';
import '../theme/app_theme.dart';
import '../utils/page_transitions.dart';
import 'result_screen.dart';

class _EntryStyle {
  final Color color;
  final IconData icon;

  const _EntryStyle({required this.color, required this.icon});

  static _EntryStyle from(HistoryEntry entry) {
    if (!entry.result.isValid) {
      return const _EntryStyle(color: Colors.orange, icon: Icons.warning_amber_rounded);
    }
    final p = entry.result.prediction.toLowerCase();
    if (p.contains('healthy')) {
      return const _EntryStyle(color: AppTheme.leafGreen, icon: Icons.check_circle_outline);
    }
    if (p.contains('multiple')) {
      return const _EntryStyle(color: Colors.redAccent, icon: Icons.report_problem_rounded);
    }
    return const _EntryStyle(color: AppTheme.maizeGold, icon: Icons.eco_outlined);
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return "Just now";
    if (diff.inHours < 1) return "${diff.inMinutes}m ago";
    if (diff.inDays < 1) return "${diff.inHours}h ago";
    return "${dt.day}/${dt.month}/${dt.year}";
  }

  void _confirmClearAll(BuildContext context, HistoryService service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Clear History?"),
        content: const Text("This will permanently delete all saved scan results."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              service.clearHistory();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text("Clear"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final historyService = Provider.of<HistoryService>(context);
    final List<HistoryEntry> entries = historyService.entries;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan History"),
        actions: [
          if (entries.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: "Clear all",
              onPressed: () => _confirmClearAll(context, historyService),
            ),
        ],
      ),
      body: entries.isEmpty
          ? _EmptyState(theme: theme)
          : ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          final style = _EntryStyle.from(entry);

          Uint8List? thumbBytes;
          if (entry.result.isValid && entry.result.gradcamBase64.isNotEmpty) {
            try {
              thumbBytes = base64Decode(entry.result.gradcamBase64);
            } catch (_) {
              thumbBytes = null;
            }
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(18),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => Navigator.push(
                  context,
                  slideFadeRoute(ResultScreen(result: entry.result)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: style.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: style.color.withValues(alpha: 0.25)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(13),
                          child: (thumbBytes != null)
                              ? Image.memory(
                            thumbBytes,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.broken_image_outlined,
                              color: style.color,
                            ),
                          )
                              : Icon(style.icon, color: style.color, size: 28),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.result.prediction,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                if (entry.result.isValid) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: style.color.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      "${entry.result.confidence.toStringAsFixed(1)}%",
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: style.color,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Icon(Icons.schedule, size: 12, color: Colors.grey[500]),
                                const SizedBox(width: 4),
                                Text(
                                  _formatTimestamp(entry.timestamp),
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.leafGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.history_rounded, size: 56, color: AppTheme.leafGreen),
            ),
            const SizedBox(height: 20),
            Text(
              "No Scans Yet",
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Analyze a maize leaf and it'll show up here so you can track results over time.",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
