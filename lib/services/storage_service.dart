import 'package:shared_preferences/shared_preferences.dart';
import '../models/scan_result.dart';

class StorageService {
  static const String key = "history";

  Future<void> saveResult(ScanResult result) async {
    final prefs = await SharedPreferences.getInstance();

    List<ScanResult> list = await getResults();

    list.insert(0, result); // ajout en haut

    String data = ScanResult.encode(list);

    await prefs.setString(key, data);
  }

  Future<List<ScanResult>> getResults() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString(key);

    if (data == null) return [];

    return ScanResult.decode(data);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  Future<void> deleteOne(int index) async {
    final prefs = await SharedPreferences.getInstance();

    List<ScanResult> list = await getResults();

    if (index >= 0 && index < list.length) {
      list.removeAt(index); // 🔥 supprime un seul élément
    }

    String data = ScanResult.encode(list);

    await prefs.setString(key, data);
  }
}
