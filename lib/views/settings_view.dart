import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project/widgets/CustomAppBar.dart';
import '../controllers/theme_controller.dart';
import '../services/feedback_service.dart';
import '../services/notification_service.dart';
import '../utils/app_text.dart';

class SettingsView extends StatefulWidget {
  final String selectedLang;
  final Function(String) onChangeLanguage;

  const SettingsView({
    super.key,
    required this.selectedLang,
    required this.onChangeLanguage,
  });

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late String selectedLang;
  bool feedbackEnabled = FeedbackService.isEnabled;

  @override
  void initState() {
    super.initState();
    selectedLang = widget.selectedLang;
    _loadFeedbackState();
  }

  Future<void> _loadFeedbackState() async {
    await FeedbackService.init();
    if (!mounted) return;
    setState(() {
      feedbackEnabled = FeedbackService.isEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[100],

      appBar: CustomAppBar(
        title: AppText.get(selectedLang, "settings_title"),
        icon: Icons.settings,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // 🧠 HEADER CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [Colors.grey.shade900, Colors.grey.shade800]
                        : [Colors.blueAccent, Colors.blue],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(Icons.settings, color: Colors.white, size: 40),
                    const SizedBox(height: 10),
                    Text(
                      AppText.get(selectedLang, "settings_header"),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // 🌙 THEME CARD
              _buildCard(
                context,
                icon: Icons.brightness_6,
                title: AppText.get(selectedLang, "change_theme"),
                child: SwitchListTile(
                  value: Theme.of(context).brightness == Brightness.dark,
                  onChanged: (_) {
                    context.read<ThemeController>().toggleTheme();
                  },
                  title: Text(AppText.get(selectedLang, "dark_mode")),
                ),
              ),

              const SizedBox(height: 15),

              // 🌍 LANGUAGE CARD
              _buildCard(
                context,
                icon: Icons.language,
                title: AppText.get(selectedLang, "language_setting"),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedLang,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                        value: "fr",
                        child: Text("🇫🇷 Français"),
                      ),
                      DropdownMenuItem(
                        value: "en",
                        child: Text("🇬🇧 English"),
                      ),
                      DropdownMenuItem(
                        value: "ar",
                        child: Text("🇸🇦 العربية"),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        selectedLang = value;
                      });

                      widget.onChangeLanguage(value);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 15),

              _buildCard(
                context,
                icon: Icons.volume_up,
                title: AppText.get(selectedLang, "feedback_sound"),
                child: SwitchListTile(
                  value: feedbackEnabled,
                  onChanged: (value) async {
                    await FeedbackService.setEnabled(value);
                    if (!mounted) return;
                    setState(() {
                      feedbackEnabled = value;
                    });
                  },
                  title: Text(AppText.get(selectedLang, "feedback_enabled")),
                ),
              ),

              const SizedBox(height: 15),

              _buildCard(
                context,
                icon: Icons.notifications_active,
                title: AppText.get(selectedLang, "daily_reminder_title"),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await NotificationService.instance.showTestNotification(
                        lang: selectedLang,
                      );
                    },
                    icon: const Icon(Icons.send),
                    label: Text(
                      AppText.get(selectedLang, "test_notification_now"),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🎨 MODERN CARD DESIGN
  Widget _buildCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
