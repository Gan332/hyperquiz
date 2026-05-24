import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'screens/home_screen.dart';
import 'widgets/hyperos_theme.dart';

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();

    return AnimatedTheme(
      data: app.darkMode
          ? HyperOSTheme.dark(app.themeColor)
          : HyperOSTheme.light(app.themeColor),
      duration: const Duration(milliseconds: 400),
      child: MaterialApp(
        title: 'QuizMaster',
        debugShowCheckedModeBanner: false,
        theme: HyperOSTheme.light(app.themeColor),
        darkTheme: HyperOSTheme.dark(app.themeColor),
        themeMode: app.darkMode ? ThemeMode.dark : ThemeMode.light,
        home: const HomeScreen(),
      ),
    );
  }
}
