import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class FeedbackService {
  static const String _feedbackEnabledKey = 'feedback_enabled';
  static bool _isEnabled = true;

  static bool get isEnabled => _isEnabled;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isEnabled = prefs.getBool(_feedbackEnabledKey) ?? true;
  }

  static Future<void> setEnabled(bool enabled) async {
    _isEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_feedbackEnabledKey, enabled);
  }

  // 🔁 Traduction (petit click système)
  Future<void> playTranslate() async {
    if (!_isEnabled) return;
    await SystemSound.play(SystemSoundType.click);
    await vibrateLight();
  }

  // 🗑 Suppression (alerte plus forte)
  Future<void> playDelete() async {
    if (!_isEnabled) return;
    await SystemSound.play(SystemSoundType.alert);
    await vibrateStrong();
  }

  // 📳 vibration légère
  Future<void> vibrateLight() async {
    if (!_isEnabled) return;
    if (await Vibration.hasVibrator()) {
      // ✅ corrigé
      Vibration.vibrate(duration: 40);
    }
  }

  // 📳 vibration forte
  Future<void> vibrateStrong() async {
    if (!_isEnabled) return;
    if (await Vibration.hasVibrator()) {
      // ✅ corrigé
      Vibration.vibrate(duration: 120);
    }
  }
}
