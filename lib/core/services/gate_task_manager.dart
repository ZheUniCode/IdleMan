import 'package:hive_flutter/hive_flutter.dart';

class GateTaskManager {
  static const String _boxName = 'gateTasksBox';
  static const String _tasksKey = 'pendingTasks';

  /// Get pending tasks (for today, or all if not filtered)
  static Future<List<String>> getPendingTasks() async {
    final box = await Hive.openBox(_boxName);
    return (box.get(_tasksKey, defaultValue: <String>[]) as List).cast<String>();
  }

  /// Add new tasks (e.g., from forced planning)
  static Future<void> addTasks(List<String> tasks) async {
    final box = await Hive.openBox(_boxName);
    final List<String> current = (box.get(_tasksKey, defaultValue: <String>[]) as List).cast<String>();
    await box.put(_tasksKey, [...current, ...tasks]);
  }

  /// Mark all tasks as complete (clear list)
  static Future<void> completeAllTasks() async {
    final box = await Hive.openBox(_boxName);
    await box.put(_tasksKey, <String>[]);
  }
}
