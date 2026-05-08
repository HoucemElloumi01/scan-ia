import 'package:flutter/material.dart';
import 'package:project/services/feedback_service.dart';
import 'package:project/services/notification_service.dart';
import 'package:project/widgets/CustomAppBar.dart';
import '../controllers/scan_controller.dart';
import '../models/scan_result.dart';
import '../utils/app_text.dart';

class ScannerView extends StatefulWidget {
  final String language;

  const ScannerView({super.key, required this.language});

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> {
  final ScanController controller = ScanController();
  final FeedbackService feedback = FeedbackService();

  ScanResult? result;
  bool isLoading = false;

  String selectedLang = "fr";
  String translatedText = "";

  bool isPlaying = false;
  double progress = 0.0;

  @override
  void initState() {
    super.initState();
    selectedLang = widget.language;

    controller.mlService.tts.setCompletionHandler(() {
      setState(() {
        isPlaying = false;
        progress = 0.0;
      });
    });
  }

  // 📸 CAMERA
  Future<void> scanCamera() async {
    setState(() => isLoading = true);

    final res = await controller.scanFromCamera();

    setState(() {
      result = res;
      translatedText = "";
      isLoading = false;
    });
  }

  // 🖼️ GALLERY
  Future<void> scanGallery() async {
    setState(() => isLoading = true);

    final res = await controller.scanFromGallery();

    setState(() {
      result = res;
      translatedText = "";
      isLoading = false;
    });
  }

  // 🔁 TRANSLATE
  Future<void> translateText() async {
    if (result == null) return;

    setState(() => isLoading = true);

    final res = await controller.translate(
      result!.text,
      selectedLang,
      result!.language,
    );

    setState(() {
      translatedText = res;
      isLoading = false;
    });

    if (res.trim().isNotEmpty) {
      await feedback.playTranslate();
      if (FeedbackService.isEnabled) {
        await NotificationService.instance.showTranslationSuccess(
          lang: selectedLang,
        );
      }
    }
  }

  Future<void> playAudio() async {
    if (translatedText.isEmpty) return;
    await controller.speak(translatedText, selectedLang);
    setState(() => isPlaying = true);
  }

  Future<void> stopAudio() async {
    await controller.stop();
    setState(() {
      isPlaying = false;
      progress = 0.0;
    });
  }

  // 🎯 MODERN CARD (glass + shadow)
  Widget _modernCard(IconData icon, String title, String content) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: isDark
            ? LinearGradient(colors: [Color(0xFF1E1E1E), Color(0xFF2A2A2A)])
            : LinearGradient(colors: [Colors.white, Colors.grey.shade100]),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blueAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(content),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 📦 EMPTY STATE
  Widget _emptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.document_scanner_outlined,
            size: 90,
            color: isDark ? Colors.blueAccent : Colors.blue,
          ),
          const SizedBox(height: 20),
          Text(
            AppText.get(selectedLang, "start"),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // 📄 RESULT UI
  Widget buildResult() {
    if (result == null) return _emptyState();

    return Column(
      children: [
        _modernCard(Icons.text_snippet, "Texte", result!.text),
        _modernCard(Icons.language, "Langue", result!.language),

        if (translatedText.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Theme.of(context).cardColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "🔁 Traduction",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(translatedText),

                const SizedBox(height: 12),

                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isPlaying ? Icons.stop : Icons.play_arrow,
                        size: 34,
                        color: Colors.blue,
                      ),
                      onPressed: isPlaying ? stopAudio : playAudio,
                    ),
                    Expanded(
                      child: Slider(
                        value: progress,
                        onChanged: (v) => setState(() => progress = v),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[100],

      appBar: CustomAppBar(
        title: AppText.get(selectedLang, "app_name"),
        icon: Icons.document_scanner,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🎯 ACTION BUTTONS (modern)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: scanCamera,
                    icon: const Icon(Icons.camera_alt),
                    label: Text(AppText.get(selectedLang, "camera")),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: scanGallery,
                    icon: const Icon(Icons.photo),
                    label: Text(AppText.get(selectedLang, "gallery")),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // 🌍 LANGUAGE PICKER
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedLang,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: "fr", child: Text("Français")),
                    DropdownMenuItem(value: "en", child: Text("English")),
                    DropdownMenuItem(value: "ar", child: Text("العربية")),
                  ],
                  onChanged: (v) => setState(() => selectedLang = v!),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // 🔁 TRANSLATE BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: translateText,
                icon: const Icon(Icons.translate),
                label: Text(AppText.get(selectedLang, "translate")),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(10),
                child: CircularProgressIndicator(),
              ),

            const SizedBox(height: 10),

            Expanded(child: SingleChildScrollView(child: buildResult())),
          ],
        ),
      ),
    );
  }
}
