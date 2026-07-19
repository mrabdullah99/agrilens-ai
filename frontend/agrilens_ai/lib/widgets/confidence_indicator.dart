// // import 'package:flutter/material.dart';
// //
// // class ConfidenceIndicator extends StatelessWidget {
// //   final double confidence;
// //
// //   const ConfidenceIndicator({super.key, required this.confidence});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final double fraction = (confidence / 100).clamp(0.0, 1.0);
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text("Confidence: ${confidence.toStringAsFixed(2)}%"),
// //         const SizedBox(height: 6),
// //         ClipRRect(
// //           borderRadius: BorderRadius.circular(6),
// //           child: LinearProgressIndicator(
// //             value: fraction,
// //             minHeight: 8,
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// // }
// import 'package:flutter/material.dart';
//
// class ConfidenceIndicator extends StatelessWidget {
//   final double confidence;
//
//   const ConfidenceIndicator({super.key, required this.confidence});
//
//   Color get _color {
//     if (confidence >= 90) return const Color(0xFF2E6F40); // leaf green
//     if (confidence >= 70) return const Color(0xFFE8B923); // maize gold
//     return const Color(0xFFD64545); // warning red
//   }
//
//   String get _label {
//     if (confidence >= 90) return "High confidence";
//     if (confidence >= 70) return "Moderate confidence";
//     return "Low confidence — verify manually";
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final double fraction = (confidence / 100).clamp(0.0, 1.0);
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//               decoration: BoxDecoration(
//                 color: _color.withValues(alpha: 0.12),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Text(
//                 "${confidence.toStringAsFixed(1)}%",
//                 style: TextStyle(color: _color, fontWeight: FontWeight.bold),
//               ),
//             ),
//             const SizedBox(width: 8),
//             Text(_label, style: TextStyle(color: _color, fontSize: 13)),
//           ],
//         ),
//         const SizedBox(height: 8),
//         ClipRRect(
//           borderRadius: BorderRadius.circular(6),
//           child: LinearProgressIndicator(
//             value: fraction,
//             minHeight: 8,
//             backgroundColor: _color.withValues(alpha: 0.15),
//             valueColor: AlwaysStoppedAnimation<Color>(_color),
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';

class ConfidenceIndicator extends StatelessWidget {
  final double confidence;

  const ConfidenceIndicator({super.key, required this.confidence});

  Color get _color {
    if (confidence >= 90) return const Color(0xFF2E6F40); // leaf green
    if (confidence >= 70) return const Color(0xFFE8B923); // maize gold
    return const Color(0xFFD64545); // warning red
  }

  String get _label {
    if (confidence >= 90) return "High confidence";
    if (confidence >= 70) return "Moderate confidence";
    return "Low confidence — verify manually";
  }

  @override
  Widget build(BuildContext context) {
    final double fraction = (confidence / 100).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "${confidence.toStringAsFixed(1)}%",
                style: TextStyle(color: _color, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
            // Expanded forces the label to stay within the horizontal bounds of the Row
            Expanded(
              child: Text(
                _label,
                style: TextStyle(
                  color: _color,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis, // Truncates gracefully on smaller devices
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 8,
            backgroundColor: _color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation<Color>(_color),
          ),
        ),
      ],
    );
  }
}