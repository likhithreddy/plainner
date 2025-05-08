import 'package:flutter/material.dart';
import 'screens/main_home_screen.dart';
import 'screens/plan_creation_screen.dart';
import 'screens/saved_plans_screen.dart';

class PlannerAIApp extends StatelessWidget {
  const PlannerAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Planner AI',
      theme: ThemeData(primarySwatch: Colors.indigo),
      initialRoute: '/',
      routes: {
        '/': (context) => const MainHomeScreen(),
        '/create': (context) => const PlanCreationScreen(),
        '/saved': (context) => const SavedPlansScreen(),
      },
    );
  }
}
