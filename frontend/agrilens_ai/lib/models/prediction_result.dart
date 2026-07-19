// // class PredictionResult {
// //   final bool isValid;
// //   final String prediction;
// //   final double confidence;
// //   final String recommendation;
// //   final String gradcamBase64;
// //   final DateTime timestamp;
// //
// //   PredictionResult({
// //     required this.isValid,
// //     required this.prediction,
// //     required this.confidence,
// //     required this.recommendation,
// //     required this.gradcamBase64,
// //     DateTime? timestamp,
// //   }) : timestamp = timestamp ?? DateTime.now();
// //
// //   Map<String, dynamic> toJson() {
// //     return {
// //       'is_valid': isValid,
// //       'prediction': prediction,
// //       'confidence': confidence,
// //       'recommendation': recommendation,
// //       'gradcam': gradcamBase64,
// //       'timestamp': timestamp.toIso8601String(),
// //     };
// //   }
// //
// //   factory PredictionResult.fromJson(Map<String, dynamic> json) {
// //     return PredictionResult(
// //       isValid: json['is_valid'] as bool? ?? true,
// //       prediction: json['prediction'] as String,
// //       confidence: (json['confidence'] as num).toDouble(),
// //       recommendation: json['recommendation'] as String,
// //       gradcamBase64: json['gradcam'] as String,
// //       timestamp: json['timestamp'] != null
// //           ? DateTime.parse(json['timestamp'])
// //           : DateTime.now(),
// //     );
// //   }
// // }
// class ClassPrediction {
//   final String label;
//   final double confidence; // 0-100
//
//   ClassPrediction({required this.label, required this.confidence});
//
//   factory ClassPrediction.fromJson(Map<String, dynamic> json) {
//     return ClassPrediction(
//       label: json['label'] as String,
//       confidence: (json['confidence'] as num).toDouble(),
//     );
//   }
// }
//
// class PredictionResult {
//   final bool isValid;
//   final String prediction;
//   final double confidence;
//   final String recommendation;
//   final String gradcamBase64;
//   final List<ClassPrediction>? topPredictions;
//   final DateTime timestamp;
//
//   PredictionResult({
//     required this.isValid,
//     required this.prediction,
//     required this.confidence,
//     required this.recommendation,
//     required this.gradcamBase64,
//     this.topPredictions,
//     DateTime? timestamp,
//   }): timestamp = timestamp ?? DateTime.now();
//
//   Map<String, dynamic> toJson() {
//     return {
//       'is_valid': isValid,
//       'prediction': prediction,
//       'confidence': confidence,
//       'recommendation': recommendation,
//       'gradcam': gradcamBase64,
//       'timestamp': timestamp.toIso8601String(),
//     };
//   }
//
//   factory PredictionResult.fromJson(Map<String, dynamic> json) {
//     return PredictionResult(
//       isValid: json['is_valid'] as bool? ?? true,
//       prediction: json['prediction'] as String,
//       confidence: (json['confidence'] as num).toDouble(),
//       recommendation: json['recommendation'] as String,
//       gradcamBase64: json['gradcam'] as String,
//       // Optional — only present once the backend is updated to return it.
//       // Safe to leave unset for now; the UI hides the section if this is null.
//       topPredictions: (json['top_predictions'] as List<dynamic>?)
//           ?.map((e) => ClassPrediction.fromJson(e as Map<String, dynamic>))
//           .toList(),
//       timestamp: json['timestamp'] != null
//           ? DateTime.parse(json['timestamp'] as String)
//           : DateTime.now(),
//     );
//   }
// }

class ClassPrediction {
  final String label;
  final double confidence; // 0-100

  ClassPrediction({required this.label, required this.confidence});

  factory ClassPrediction.fromJson(Map<String, dynamic> json) {
    return ClassPrediction(
      label: json['label'] as String,
      confidence: (json['confidence'] as num).toDouble(),
    );
  }
}

class PredictionResult {
  final bool isValid;
  final String prediction;
  final double confidence;
  final String recommendation;
  final String gradcamBase64;
  final String originalImageBase64;
  final List<ClassPrediction>? topPredictions;
  final DateTime timestamp;

  PredictionResult({
    required this.isValid,
    required this.prediction,
    required this.confidence,
    required this.recommendation,
    required this.gradcamBase64,
    required this.originalImageBase64,
    this.topPredictions,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'is_valid': isValid,
      'prediction': prediction,
      'confidence': confidence,
      'recommendation': recommendation,
      'gradcam': gradcamBase64,
      'original_image': originalImageBase64,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    return PredictionResult(
      isValid: json['is_valid'] as bool? ?? true,
      prediction: json['prediction'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      recommendation: json['recommendation'] as String,
      gradcamBase64: json['gradcam'] as String,
      originalImageBase64: json['original_image'] as String? ?? '',
      // Optional — only present once the backend is updated to return it.
      // Safe to leave unset for now; the UI hides the section if this is null.
      topPredictions: (json['top_predictions'] as List<dynamic>?)
          ?.map((e) => ClassPrediction.fromJson(e as Map<String, dynamic>))
          .toList(),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }
}