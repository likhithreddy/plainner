import 'package:flutter/material.dart';
import 'screens/main_home_screen.dart';
import 'screens/plan_creation_screen.dart';
import 'screens/saved_plans_screen.dart';

final ValueNotifier<ThemeMode> themeModeNotifier =
    ValueNotifier(ThemeMode.system);

class PlannerAIApp extends StatelessWidget {
  const PlannerAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'plAInner',
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.indigo,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.indigo,
            brightness: Brightness.dark,
          ),
          themeMode: mode,
          initialRoute: '/',
          routes: {
            '/': (context) => const MainHomeScreen(),
            '/create': (context) => const PlanCreationScreen(),
            '/saved': (context) => const SavedPlansScreen(),
          },
        );
      },
    );
  }
}
