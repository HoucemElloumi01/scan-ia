import 'package:flutter/material.dart';
import '../widgets/CustomAppBar.dart';
import '../utils/app_text.dart';

class HomeView extends StatelessWidget {
  final String language;

  const HomeView({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textColor = isDark ? Colors.white : Colors.black87;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final bgColor = isDark ? const Color(0xFF121212) : Colors.grey[100];

    return Scaffold(
      backgroundColor: bgColor,

      appBar: CustomAppBar(
        title: AppText.get(language, "home"),
        icon: Icons.auto_awesome,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔥 HEADER
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: isDark
                    ? const LinearGradient(
                        colors: [Color(0xFF2C2C2C), Color(0xFF1E1E1E)],
                      )
                    : const LinearGradient(
                        colors: [Colors.blueAccent, Colors.blue],
                      ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/logoo.jpg',
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      AppText.get(language, "home_header_title"),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // 📌 OBJECTIF
            Text(
              "🎯 ${AppText.get(language, "home_objective")}",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              AppText.get(language, "home_description"),
              style: TextStyle(fontSize: 14, color: textColor.withOpacity(0.8)),
            ),

            const SizedBox(height: 25),

            // ⚙️ FEATURES TITLE
            Text(
              "⚙️ ${AppText.get(language, "features_title")}",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),

            const SizedBox(height: 15),

            _buildFeature(
              Icons.image,
              AppText.get(language, "feature_import_image"),
              cardColor,
              textColor,
            ),

            _buildFeature(
              Icons.camera_alt,
              AppText.get(language, "camera"),
              cardColor,
              textColor,
            ),

            _buildFeature(
              Icons.text_fields,
              AppText.get(language, "feature_text_recognition"),
              cardColor,
              textColor,
            ),

            _buildFeature(
              Icons.language,
              AppText.get(language, "feature_language_detection"),
              cardColor,
              textColor,
            ),

            _buildFeature(
              Icons.translate,
              AppText.get(language, "translation"),
              cardColor,
              textColor,
            ),

            _buildFeature(
              Icons.volume_up,
              AppText.get(language, "feature_speech"),
              cardColor,
              textColor,
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildFeature(
    IconData icon,
    String text,
    Color cardColor,
    Color textColor,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent),
          const SizedBox(width: 15),
          Expanded(
            child: Text(text, style: TextStyle(color: textColor)),
          ),
        ],
      ),
    );
  }
}
