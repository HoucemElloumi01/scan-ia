import 'package:image_picker/image_picker.dart';
import '../models/scan_result.dart';
import '../services/ml_service.dart';
import '../services/storage_service.dart';

class ScanController {
  final MLService mlService = MLService();
  final ImagePicker picker = ImagePicker();
  final StorageService storage = StorageService();

  Future<ScanResult?> scanFromCamera() async {
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) return null;

    final text = await mlService.extractText(image.path);
    final lang = await mlService.detectLanguage(text);

    final result = ScanResult(text: text, language: lang);

    await storage.saveResult(result); // 🔥 SAUVEGARDE

    return result;
  }

  Future<ScanResult?> scanFromGallery() async {
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;

    final text = await mlService.extractText(image.path);
    final lang = await mlService.detectLanguage(text);

    final result = ScanResult(text: text, language: lang);

    await storage.saveResult(result); // 🔥 SAUVEGARDE

    return result;
  }

  Future<String> translate(
    String text,
    String targetLang,
    String sourceLang,
  ) async {
    final translated = await mlService.translate(text, targetLang, sourceLang);
    return translated;
  }

  Future<void> speak(String text, String lang) async {
    await mlService.speak(text, lang);
  }

  Future<void> stop() async {
    await mlService.stop();
  }
}
