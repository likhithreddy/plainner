import 'package:flutter/material.dart';
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
                    const SnackBar(
                      content: Text('Plan saved and downloaded!'),
                    ),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Create a Plan')),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextField(
                    controller: _promptController,
                    enabled: !_loading,
                    decoration: const InputDecoration(
                      labelText: 'What do you want a plan for?',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _loading ? null : _getPlan,
                    child: const Text('Generate Plan'),
                  ),
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
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _planEntries.length,
                      itemBuilder: (context, index) {
                        final entry = _planEntries[index];
                        return ListTile(
                          title: Text(
                            "${entry.date.toLocal().toString().split(' ')[0]} - ${entry.title}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(entry.description),
                        );
                      },
                    ),
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
      ),
    );
  }
}
