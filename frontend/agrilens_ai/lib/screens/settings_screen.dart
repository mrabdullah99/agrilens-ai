// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../providers/settings_provider.dart';
// import '../services/history_service.dart';
//
// class SettingsScreen extends StatelessWidget {
//   const SettingsScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final settings = Provider.of<SettingsProvider>(context);
//
//     return Scaffold(
//       appBar: AppBar(title: const Text("Settings")),
//
//       body: ListView(
//         children: [
//           SwitchListTile(
//             title: const Text("Dark Mode"),
//             subtitle: const Text("Use dark theme across the app"),
//             value: settings.darkMode,
//             onChanged: (value) => settings.toggleDarkMode(value),
//           ),
//           SwitchListTile(
//             title: const Text("Save Predictions to History"),
//             subtitle: const Text("Automatically log each scan result"),
//             value: settings.saveToHistory,
//             onChanged: (value) => settings.toggleSaveToHistory(value),
//           ),
//           const Divider(),
//           ListTile(
//             leading: const Icon(Icons.info_outline),
//             title: const Text("About"),
//             subtitle: const Text("MaizeVision-AI v1.0.0"),
//             onTap: () {
//               showAboutDialog(
//                 context: context,
//                 applicationName: "MaizeVision-AI",
//                 applicationVersion: "1.0.0",
//                 children: const [
//                   Text("On-device maize leaf nutrient deficiency detection."),
//                 ],
//               );
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.delete_outline),
//             title: const Text("Clear History"),
//             onTap: () {
//               showDialog(
//                 context: context,
//                 builder: (context) => AlertDialog(
//                   title: const Text("Clear History?"),
//                   content: const Text(
//                     "This will permanently delete all saved predictions.",
//                   ),
//                   actions: [
//                     TextButton(
//                       onPressed: () => Navigator.pop(context),
//                       child: const Text("Cancel"),
//                     ),
//                     TextButton(
//                       onPressed: () async {
//                         await HistoryService.instance.clearHistory();
//                         if (context.mounted) {
//                           Navigator.pop(context);
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(content: Text("History cleared")),
//                           );
//                         }
//                       },
//                       child: const Text("Clear"),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../services/history_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          /// HEADER
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF2E7D32),
                  Color(0xFF43A047),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [

                const CircleAvatar(
                  radius: 38,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.eco,
                    size: 42,
                    color: Colors.green,
                  ),
                ),

                const SizedBox(height: 14),

                const Text(
                  "AgriLens AI",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  "AI-Powered Maize Leaf Analysis",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Version 1.0.0",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),

          const SizedBox(height: 25),

          /// APPEARANCE
          _sectionTitle("Appearance"),

          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [

                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode),
                  title: const Text("Dark Mode"),
                  subtitle: const Text(
                    "Use dark theme throughout the app",
                  ),
                  value: settings.darkMode,
                  onChanged: settings.toggleDarkMode,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// PREDICTION
          _sectionTitle("Prediction"),

          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [

                SwitchListTile(
                  secondary: const Icon(Icons.history),
                  title: const Text("Save Scan History"),
                  subtitle: const Text(
                    "Automatically save prediction results",
                  ),
                  value: settings.saveToHistory,
                  onChanged: settings.toggleSaveToHistory,
                ),

                const Divider(height: 1),

                const Divider(height: 1),

                SwitchListTile(
                  secondary: const Icon(Icons.visibility),
                  title: const Text("Show Grad-CAM Overlay"),
                  subtitle: const Text(
                    "Display AI attention heatmap",
                  ),
                  value: settings.showGradcam,
                  onChanged: settings.toggleShowGradcam,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// DATA
          _sectionTitle("Data"),

          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.red,
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.white,
                ),
              ),
              title: const Text("Clear Scan History"),
              subtitle: const Text(
                "Delete all saved scan results",
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {

                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(

                    title: const Text("Clear History"),

                    content: const Text(
                      "This will permanently delete all saved scan history.\n\nThis action cannot be undone.",
                    ),

                    actions: [

                      TextButton(
                        onPressed: (){
                          Navigator.pop(context);
                        },
                        child: const Text("Cancel"),
                      ),

                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () async {

                          await HistoryService.instance.clearHistory();

                          if(context.mounted){

                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(

                              const SnackBar(
                                content: Text("History cleared successfully."),
                              ),

                            );

                          }

                        },
                        child: const Text("Clear"),
                      )

                    ],
                  ),
                );

              },
            ),
          ),

          const SizedBox(height: 20),

          /// ABOUT
          _sectionTitle("About"),

          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [

                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text("About AgriLens AI"),
                  subtitle: const Text("Learn more about this application"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {

                    showAboutDialog(

                      context: context,

                      applicationName: "AgriLens AI",

                      applicationVersion: "1.0.0",

                      applicationIcon: const Icon(
                        Icons.eco,
                        color: Colors.green,
                        size: 40,
                      ),

                      children: const [

                        SizedBox(height: 12),

                        Text(
                          "AgriLens AI is a Deep Learning powered mobile application "
                              "that detects nutrient deficiencies in maize leaves "
                              "using EfficientNetB0 and Grad-CAM Explainable AI.",
                        ),

                        SizedBox(height: 16),

                        Text(
                          "Technology Stack",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 8),

                        Text("• Flutter"),
                        Text("• FastAPI"),
                        Text("• TensorFlow"),
                        Text("• EfficientNetB0"),
                        Text("• Grad-CAM"),

                      ],

                    );

                  },
                ),

                const Divider(height: 1),

                const ListTile(
                  leading: Icon(Icons.code),
                  title: Text("Technology"),
                  subtitle: Text("Flutter • FastAPI • TensorFlow"),
                ),

                const Divider(height: 1),

                const ListTile(
                  leading: Icon(Icons.psychology),
                  title: Text("AI Model"),
                  subtitle: Text("EfficientNetB0 + Grad-CAM"),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          Center(
            child: Column(
              children: [

                Icon(
                  Icons.favorite,
                  color: Colors.red.shade400,
                ),

                const SizedBox(height: 8),

                const Text(
                  "Made for smarter agriculture",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "AgriLens AI • Version 1.0.0",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 4,
        bottom: 10,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}