import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app.dart'; // for themeModeNotifier
import '../services/gemini_service.dart';
import '../services/excel_service.dart';
import '../services/storage_service.dart';
import '../models/plan.dart';

class PlanCreationScreen extends StatefulWidget {
  const PlanCreationScreen({super.key});

  @override
  State<PlanCreationScreen> createState() => _PlanCreationScreenState();
}

class _PlanCreationScreenState extends State<PlanCreationScreen> {
  final TextEditingController _promptController = TextEditingController();
  List<PlanEntry> _planEntries = [];
  bool _loading = false;
  String _error = '';

  Future<void> _getPlan() async {
    setState(() {
      _loading = true;
      _planEntries = [];
      _error = '';
    });
    try {
      final raw = await GeminiService.generatePlan(_promptController.text);
      final lines = raw.split('\n').where((line) => line.trim().isNotEmpty);
      final entries =
          lines.map((line) => PlanEntry.fromFormattedString(line)).toList();
      setState(() => _planEntries = entries);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showSavePlanDialog() {
    final TextEditingController _nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Save Plan'),
          content: TextField(
            controller: _nameController,
            decoration: const InputDecoration(hintText: 'Enter plan name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = _nameController.text.trim();
                if (name.isNotEmpty) {
                  await StorageService.savePlan(name, _planEntries);
                  await ExcelService.savePlanAsExcel(name, _planEntries);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Plan saved and downloaded!')),
                  );
                }
              },
              child: const Text('Save Plan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Create a Plan'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.wb_sunny : Icons.nightlight_round),
            tooltip: isDark ? "Switch to Light Mode" : "Switch to Dark Mode",
            onPressed: () {
              themeModeNotifier.value =
                  isDark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/bg_create.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.5)),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Column(
                  children: [
                    TextField(
                      controller: _promptController,
                      enabled: !_loading,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'What do you want a plan for?',
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(),
                      ),
                    ).animate().fade().slideY(begin: 0.1, duration: 500.ms),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _loading ? null : _getPlan,
                      child: const Text('Generate Plan'),
                    ).animate().fade().slideY(begin: 0.2, duration: 500.ms),
                    const SizedBox(height: 10),
                    if (_loading) const CircularProgressIndicator(),
                    if (_error.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(_error,
                            style: const TextStyle(color: Colors.red)),
                      ),
                    const SizedBox(height: 10),
                    if (_planEntries.isNotEmpty)
                      ..._planEntries
                          .map(
                            (entry) => AnimatedContainer(
                              duration: 500.ms,
                              curve: Curves.easeInOut,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                title: Text(
                                  "${entry.date.toLocal().toString().split(' ')[0]} - ${entry.title}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(entry.description),
                              ),
                            ),
                          )
                          .toList(),
                    const SizedBox(height: 20),
                    if (_planEntries.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: _loading ? null : _getPlan,
                            child: const Text('Regenerate'),
                          ),
                          ElevatedButton(
                            onPressed: _loading ? null : _showSavePlanDialog,
                            child: const Text('This plan is okay'),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
