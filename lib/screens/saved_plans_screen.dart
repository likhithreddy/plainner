import 'package:flutter/material.dart';
import '../models/plan.dart';
import '../services/excel_service.dart';
import '../services/storage_service.dart';

class SavedPlansScreen extends StatefulWidget {
  const SavedPlansScreen({super.key});

  @override
  State<SavedPlansScreen> createState() => _SavedPlansScreenState();
}

class _SavedPlansScreenState extends State<SavedPlansScreen> {
  Map<String, List<PlanEntry>> savedPlans = {};

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    final names = await StorageService.getPlanNames();
    final Map<String, List<PlanEntry>> plans = {};
    for (final name in names) {
      plans[name] = await StorageService.loadPlan(name);
    }
    setState(() => savedPlans = plans);
  }

  void _viewPlan(String name, List<PlanEntry> entries) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(name),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 400,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: entries.length,
                  itemBuilder: (ctx, idx) {
                    final e = entries[idx];
                    return ListTile(
                      title: Text(
                        "${e.date.toLocal().toString().split(' ')[0]} - ${e.title}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(e.description),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Plans')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: savedPlans.isEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.insert_drive_file, size: 60, color: Colors.grey),
                    SizedBox(height: 10),
                    Text("No saved plans yet."),
                  ],
                )
              : ListView.builder(
                  itemCount: savedPlans.length,
                  itemBuilder: (context, index) {
                    final name = savedPlans.keys.elementAt(index);
                    final entries = savedPlans[name]!;
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      child: ListTile(
                        title: Text(name,
                            style:
                                const TextStyle(fontWeight: FontWeight.w500)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: "View",
                              icon: const Icon(Icons.visibility),
                              onPressed: () => _viewPlan(name, entries),
                            ),
                            IconButton(
                              tooltip: "Download",
                              icon: const Icon(Icons.download),
                              onPressed: () =>
                                  ExcelService.savePlanAsExcel(name, entries),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
