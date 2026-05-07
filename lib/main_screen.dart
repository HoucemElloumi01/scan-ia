import 'package:flutter/material.dart';
import 'views/home_view.dart';
import 'views/scanner_view.dart';
import 'views/history_view.dart';
import 'views/settings_view.dart';
import 'widgets/bottom_nav_bar.dart';

class MainScreen extends StatefulWidget {
  final Function(String)? onChangeLanguage;

  const MainScreen({super.key, this.onChangeLanguage});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  String currentLang = "fr";

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeView(language: currentLang),
      ScannerView(language: currentLang),
      HistoryView(language: currentLang),
      SettingsView(
        selectedLang: currentLang,
        onChangeLanguage: (lang) {
          setState(() {
            currentLang = lang;
          });

          if (widget.onChangeLanguage != null) {
            widget.onChangeLanguage!(lang);
          }
        },
      ),
    ];

    return Scaffold(
      body: pages[currentIndex],

      bottomNavigationBar: BottomNavBar(
        currentIndex: currentIndex,
        language: currentLang,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}
