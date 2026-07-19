import '../models/prediction_result.dart';

class HistoryEntry {
  final PredictionResult result;
  final DateTime timestamp;

  HistoryEntry({required this.result, required this.timestamp});
}