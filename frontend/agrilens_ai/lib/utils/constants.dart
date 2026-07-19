import 'dart:io' show Platform;

/// Set this if testing on a real physical device (your machine's LAN IP).
const String? kManualApiBaseUrl = "http://192.168.1.4:8000";
// http:// 192.168.1.7:8000
String get kApiBaseUrl {
  if (kManualApiBaseUrl != null && kManualApiBaseUrl!.isNotEmpty) {
    return kManualApiBaseUrl!;
  }
  if (Platform.isAndroid) return "http://10.0.2.2:8000";
  return "http://127.0.0.1:8000";
}

const List<String> kSupportedClasses = [
  "Healthy Leaf",
  "Nitrogen Deficiency",
  "Phosphorus Deficiency",
  "Potassium Deficiency",
  "Zinc Deficiency",
  "Multiple Nutrient Deficiencies",
];