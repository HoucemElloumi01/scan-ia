import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class MLService {
  final textRecognizer = TextRecognizer();

  final languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);

  late OnDeviceTranslator translator;

  // 📸 OCR
  Future<String> extractText(String path) async {
    final inputImage = InputImage.fromFilePath(path);
    final result = await textRecognizer.processImage(inputImage);
    return result.text;
  }

  // 🌍 detect language
  Future<String> detectLanguage(String text) async {
    return await languageIdentifier.identifyLanguage(text);
  }

  // 🔁 translate
  Future<String> translate(
    String text,
    String targetLang,
    String sourceLang,
  ) async {
    translator = OnDeviceTranslator(
      sourceLanguage: _mapSourceLang(sourceLang),
      targetLanguage: _mapLang(targetLang),
    );

    return await translator.translateText(text);
  }

  final FlutterTts tts = FlutterTts();
  Future<void> speak(String text, String lang) async {
    // mapping langue → TTS
    String ttsLang = _mapTTSLang(lang);

    await tts.setLanguage(ttsLang);
    await tts.setSpeechRate(0.5);
    await tts.setPitch(1.0);

    await tts.speak(text);
  }

  Future<void> stop() async {
    await tts.stop();
  }

  String _mapTTSLang(String lang) {
    switch (lang) {
      case "fr":
        return "fr-FR";
      case "ar":
        return "ar-SA";
      case "es":
        return "es-ES";
      case "de":
        return "de-DE";
      default:
        return "en-US";
    }
  }

  // 🎯 target language
  TranslateLanguage _mapLang(String lang) {
    switch (lang) {
      case "fr":
        return TranslateLanguage.french;
      case "ar":
        return TranslateLanguage.arabic;
      case "es":
        return TranslateLanguage.spanish;
      case "de":
        return TranslateLanguage.german;
      default:
        return TranslateLanguage.english;
    }
  }

  // 🎯 source language
  TranslateLanguage _mapSourceLang(String lang) {
    switch (lang) {
      case "fr":
        return TranslateLanguage.french;
      case "ar":
        return TranslateLanguage.arabic;
      case "es":
        return TranslateLanguage.spanish;
      case "de":
        return TranslateLanguage.german;
      default:
        return TranslateLanguage.english;
    }
  }

  void dispose() {
    textRecognizer.close();
    languageIdentifier.close();
    translator.close();
  }
}
