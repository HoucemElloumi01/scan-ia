import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'controllers/theme_controller.dart';
import 'services/feedback_service.dart';
import 'services/notification_service.dart';
import 'main_screen.dart';
import 'views/auth_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FeedbackService.init();
  await NotificationService.instance.init();
  await NotificationService.instance.scheduleDailyReminder(lang: 'fr');

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeController(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('fr');
  final Stream<User?> _authStream = FirebaseAuth.instance.authStateChanges();

  void changeLanguage(String lang) {
    setState(() {
      _locale = Locale(lang);
    });

    NotificationService.instance.scheduleDailyReminder(lang: lang);
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      locale: _locale,

      supportedLocales: const [Locale('fr'), Locale('en'), Locale('ar')],

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      themeMode: themeController.themeMode,

      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),

      home: StreamBuilder<User?>(
        stream: _authStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData) {
            return MainScreen(onChangeLanguage: changeLanguage);
          }

          return AuthView(language: _locale.languageCode);
        },
      ),
    );
  }
}
