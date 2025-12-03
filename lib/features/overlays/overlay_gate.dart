import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// OverlayGateScreen: Shows either a checklist of tasks or forced planning UI
class OverlayGateScreen extends ConsumerWidget {
  final List<String> pendingTasks;
  final bool forcedPlanning;
  final void Function(List<String> newTasks)? onPlanningComplete;
  final void Function(List<String> completedTasks)? onTasksComplete;

  const OverlayGateScreen({
    Key? key,
    required this.pendingTasks,
    this.forcedPlanning = false,
    this.onPlanningComplete,
    this.onTasksComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (forcedPlanning) {
      return _ForcedPlanningOverlay(onComplete: onPlanningComplete);
    } else {
      return _ChecklistOverlay(tasks: pendingTasks, onComplete: onTasksComplete);
    }
  }
}

class _ChecklistOverlay extends StatefulWidget {
  final List<String> tasks;
  final void Function(List<String> completedTasks)? onComplete;
  const _ChecklistOverlay({required this.tasks, this.onComplete});

  @override
  State<_ChecklistOverlay> createState() => _ChecklistOverlayState();
}

class _ChecklistOverlayState extends State<_ChecklistOverlay> {
  late List<bool> checked;

  @override
  void initState() {
    super.initState();
    checked = List.filled(widget.tasks.length, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.85),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔒 Productivity Gate', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                const Text(
                  'This app is blocked until you complete your tasks.\n\nTo unlock, finish the tasks below. You can manage blocked apps in the dashboard.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ...List.generate(widget.tasks.length, (i) => CheckboxListTile(
                  value: checked[i],
                  onChanged: (val) {
                    setState(() => checked[i] = val ?? false);
                  },
                  title: Text(widget.tasks[i]),
                )),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: checked.every((c) => c)
                      ? () => widget.onComplete?.call(widget.tasks)
                      : null,
                  child: const Text('Unlock'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ForcedPlanningOverlay extends StatefulWidget {
  final void Function(List<String> newTasks)? onComplete;
  const _ForcedPlanningOverlay({this.onComplete});

  @override
  State<_ForcedPlanningOverlay> createState() => _ForcedPlanningOverlayState();
}

class _ForcedPlanningOverlayState extends State<_ForcedPlanningOverlay> {
  final List<TextEditingController> controllers = List.generate(3, (_) => TextEditingController());

  bool get allValid => controllers.every((c) => c.text.trim().length >= 3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.85),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔒 Productivity Gate', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                const Text(
                  'This app is blocked until you plan your next steps.\n\nTo unlock, define your next 3 moves. You can manage blocked apps in the dashboard.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ...List.generate(3, (i) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: TextField(
                    controller: controllers[i],
                    decoration: InputDecoration(
                      labelText: 'Task ${i + 1}',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                )),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: allValid
                      ? () => widget.onComplete?.call(controllers.map((c) => c.text.trim()).toList())
                      : null,
                  child: const Text('Save & Unlock'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
