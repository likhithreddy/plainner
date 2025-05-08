import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/plan.dart';

class StorageService {
  static const String _keyPrefix = 'saved_plan_';
  static const String _indexKey = 'saved_plan_index';

  // Save full plan
  static Future<void> savePlan(String planName, List<PlanEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getStringList(_indexKey) ?? [];

    if (!index.contains(planName)) {
      index.add(planName);
      await prefs.setStringList(_indexKey, index);
    }

    final jsonData = entries.map((e) => e.toJson()).toList();
    await prefs.setString('$_keyPrefix$planName', jsonEncode(jsonData));
  }

  // Load all saved plan names
  static Future<List<String>> getPlanNames() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_indexKey) ?? [];
  }

  // Load a specific plan
  static Future<List<PlanEntry>> loadPlan(String planName) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('$_keyPrefix$planName');
    if (data == null) return [];

    final decoded = jsonDecode(data) as List<dynamic>;
    return decoded.map((e) => PlanEntry.fromJson(e)).toList();
  }
}
