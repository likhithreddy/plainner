import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app.dart'; // for themeModeNotifier
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Saved Plans'),
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
              'assets/bg_saved.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.4)),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: savedPlans.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.insert_drive_file,
                            size: 60, color: Colors.white70),
                        SizedBox(height: 10),
                        Text("No saved plans yet.",
                            style: TextStyle(color: Colors.white)),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 40),
                      itemCount: savedPlans.length,
                      itemBuilder: (context, index) {
                        final name = savedPlans.keys.elementAt(index);
                        final entries = savedPlans[name]!;
                        return Card(
                          elevation: 5,
                          color: Colors.white.withOpacity(0.95),
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text(
                              name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
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
                                  onPressed: () => ExcelService.savePlanAsExcel(
                                      name, entries),
                                ),
                              ],
                            ),
                          ),
                        ).animate().fade().slideY(
                              begin: 0.1,
                              duration: 500.ms,
                              delay: (index * 100).ms,
                            );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
