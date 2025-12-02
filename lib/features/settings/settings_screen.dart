
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/blocklist_provider.dart';
import '../../core/services/platform_services.dart';
import '../../core/services/gate_task_manager.dart';
import '../../widgets/neumorphic/neu_card.dart';
import '../../widgets/neumorphic/neu_toggle.dart';
import '../../widgets/service_status_banner.dart';
import '../../widgets/neumorphic/neu_background.dart';
import '../../widgets/neumorphic/neu_button.dart';


// Simple task model for Productivity Gate
class _GateTask {
  final String text;
  bool completed;
  _GateTask(this.text, {this.completed = false});
}

// --- Neumorphic Inset Input Widget ---
class _NeuInput extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final Color accentColor;
  final Color textColor;
  final void Function(String)? onSubmitted;
  const _NeuInput({
    required this.controller,
    required this.hintText,
    required this.accentColor,
    required this.textColor,
    this.onSubmitted,
  });
  @override
  State<_NeuInput> createState() => _NeuInputState();
}

class _NeuInputState extends State<_NeuInput> {
  bool _focused = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _focused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // True neumorphic inset: both shadows are 'inset' (simulated in Flutter by stacking containers)
    // Neumorphic inset style matching the reference images
    final Color bgColor = Theme.of(context).colorScheme.surface.withOpacity(0.97);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          // Light shadow (top-left, inset)
          BoxShadow(
            color: Colors.white.withOpacity(0.7),
            offset: const Offset(-4, -4),
            blurRadius: 8,
          ),
          // Dark shadow (bottom-right, inset)
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(4, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: widget.textColor.withOpacity(0.25),
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          isDense: true,
          filled: true,
          fillColor: Colors.transparent,
        ),
        style: TextStyle(
          color: _focused ? widget.accentColor : widget.textColor,
          fontSize: 18,
          fontWeight: FontWeight.w400,
        ),
        cursorColor: widget.accentColor,
        onSubmitted: widget.onSubmitted,
      ),
    );
  }
}

/// Settings Screen
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _productivityGateEnabled = false;
  String _unlockCondition = 'All Tasks for Today';
  final List<String> _unlockConditions = [
    'All Tasks for Today',
    'Top 3 Priority Tasks',
    'Specific Tag',
  ];
  final TextEditingController _taskController = TextEditingController();
  List<_GateTask> _tasks = [];
  @override
  void initState() {
    super.initState();
    _checkServiceStatus();
    _loadDuration();
    _loadOverlay();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final pending = await GateTaskManager.getPendingTasks();
    setState(() {
      _tasks = pending.map((t) => _GateTask(t)).toList();
    });
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }
  bool _isServiceEnabled = false;
  Duration _duration = const Duration(minutes: AppConstants.defaultBypassDuration);
  OverlayType _selectedOverlay = OverlayType.chase;



  Future<void> _checkServiceStatus() async {
    final isEnabled = await PlatformServices.checkAccessibilityPermission();
    if (mounted) {
      setState(() {
        _isServiceEnabled = isEnabled;
      });
    }
  }

  Future<void> _loadDuration() async {
    final prefs = await SharedPreferences.getInstance();
    final minutes = prefs.getInt('bypass_duration') ?? AppConstants.defaultBypassDuration;
    if (mounted) {
      setState(() {
        _duration = Duration(minutes: minutes);
      });
    }
  }

  Future<void> _loadOverlay() async {
    _selectedOverlay = OverlayType.chase;
  }

  void _showDurationPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext builder) {
        final theme = ref.watch(themeProvider);
        int selectedHour = _duration.inHours;
        int selectedMinute = _duration.inMinutes % 60;
        return Container(
          height: 340,
          decoration: BoxDecoration(
            color: theme.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: theme.getPopOutShadows(distance: 8, blur: 24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Hours wheel
                  Expanded(
                    child: _customWheel(
                      theme: theme,
                      min: 0,
                      max: 12,
                      selected: selectedHour,
                      onChanged: (val) => selectedHour = val,
                      label: 'Hours',
                    ),
                  ),
                  // Minutes wheel
                  Expanded(
                    child: _customWheel(
                      theme: theme,
                      min: 0,
                      max: 59,
                      selected: selectedMinute,
                      onChanged: (val) => selectedMinute = val,
                      label: 'Minutes',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              NeuButton(
                onTap: () {
                  final newDuration = Duration(hours: selectedHour, minutes: selectedMinute);
                  if (newDuration.inMinutes > 0) {
                    setState(() {
                      _duration = newDuration;
                    });
                    SharedPreferences.getInstance().then((prefs) {
                      prefs.setInt('bypass_duration', newDuration.inMinutes);
                    });
                  }
                  Navigator.pop(context);
                },
                child: const Text('Set Duration'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _customWheel({
    required theme,
    required int min,
    required int max,
    required int selected,
    required Function(int) onChanged,
    required String label,
  }) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 16, color: theme.mainText.withOpacity(0.7))),
        SizedBox(
          height: 180,
          child: Stack(
            children: [
              ListWheelScrollView.useDelegate(
                itemExtent: 48,
                diameterRatio: 1.2,
                perspective: 0.003,
                physics: const FixedExtentScrollPhysics(),
                onSelectedItemChanged: (val) => onChanged(val + min),
                childDelegate: ListWheelChildBuilderDelegate(
                  builder: (context, idx) {
                    final value = idx + min;
                    final isSelected = value == selected;
                    return Center(
                      child: Text(
                        value.toString().padLeft(2, '0'),
                        style: TextStyle(
                          fontSize: isSelected ? 28 : 20,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? theme.mainText : theme.mainText.withOpacity(0.5),
                        ),
                      ),
                    );
                  },
                  childCount: max - min + 1,
                ),
                controller: FixedExtentScrollController(initialItem: selected - min),
              ),
              // Top divider
              Positioned(
                top: 66,
                left: 0,
                right: 0,
                child: Divider(
                  thickness: 2,
                  color: theme.mainText.withOpacity(0.12),
                  height: 2,
                ),
              ),
              // Bottom divider
              Positioned(
                bottom: 66,
                left: 0,
                right: 0,
                child: Divider(
                  thickness: 2,
                  color: theme.mainText.withOpacity(0.12),
                  height: 2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return Scaffold(
      backgroundColor: theme.background,
      body: NeuBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: theme.mainText,
                      ),
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                    const SizedBox(width: AppConstants.paddingSmall),
                    Text(
                      AppStrings.settingsTitle,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: theme.mainText,
                      ),
                    ),
                  ],
                ),
              ),
              // Settings list
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingLarge,
                  ),
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: AppConstants.paddingLarge, bottom: AppConstants.paddingMedium),
                      child: NeuCard(
                        child: Padding(
                          padding: const EdgeInsets.all(AppConstants.paddingMedium),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.lock, color: theme.accent, size: 28),
                                  const SizedBox(width: AppConstants.paddingMedium),
                                  Text('Productivity Gate',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: theme.mainText)),
                                  const Spacer(),
                                  NeuToggle(
                                    value: _productivityGateEnabled,
                                    onChanged: (val) {
                                      setState(() => _productivityGateEnabled = val);
                                    },
                                  ),
                                ],
                              ),
                              if (_productivityGateEnabled) ...[
                                const SizedBox(height: AppConstants.paddingMedium),
                                Text('Unlock Condition:', style: TextStyle(fontSize: 16, color: theme.mainText)),
                                const SizedBox(height: 10),
                                Container(
                                  decoration: BoxDecoration(
                                    color: theme.background,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.10),
                                        blurRadius: 8,
                                        offset: const Offset(2, 4),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _unlockCondition,
                                      isExpanded: true,
                                      dropdownColor: theme.background,
                                      style: TextStyle(color: theme.mainText, fontSize: 16),
                                      items: _unlockConditions.map((c) => DropdownMenuItem(
                                        value: c,
                                        child: Text(c, style: TextStyle(color: theme.mainText)),
                                      )).toList(),
                                      onChanged: (val) {
                                        if (val != null) setState(() => _unlockCondition = val);
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppConstants.paddingSmall),
                                // --- Task Manager UI ---
                                Text('Tasks:', style: TextStyle(fontSize: 16, color: theme.mainText)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _NeuInput(
                                        controller: _taskController,
                                        hintText: 'Add a new task',
                                        accentColor: theme.accent,
                                        textColor: theme.mainText,
                                        onSubmitted: (val) async {
                                          if (val.trim().isNotEmpty) {
                                            await GateTaskManager.addTasks([val.trim()]);
                                            _taskController.clear();
                                            _loadTasks();
                                          }
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    NeuButton(
                                      onTap: () async {
                                        final val = _taskController.text.trim();
                                        if (val.isEmpty) return;
                                        if (_tasks.any((t) => t.text == val)) return;
                                        await GateTaskManager.addTasks([val]);
                                        debugPrint('Added task: $val');
                                        _taskController.clear();
                                        await _loadTasks();
                                        setState(() {});
                                      },
                                      child: const Icon(Icons.add),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                if (_tasks.isEmpty)
                                  Text('No tasks yet.', style: TextStyle(color: theme.mainText.withOpacity(0.6))),
                                if (_tasks.isNotEmpty)
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: _tasks.length,
                                    itemBuilder: (context, idx) {
                                      final task = _tasks[idx];
                                      return ListTile(
                                        leading: Checkbox(
                                          value: task.completed,
                                          onChanged: (val) async {
                                            setState(() {
                                              task.completed = val ?? false;
                                            });
                                            // If all tasks are completed, clear them in storage
                                            if (_tasks.every((t) => t.completed)) {
                                              await GateTaskManager.completeAllTasks();
                                              _loadTasks();
                                            }
                                          },
                                        ),
                                        title: Text(
                                          task.text,
                                          style: TextStyle(
                                            color: theme.mainText,
                                            decoration: task.completed ? TextDecoration.lineThrough : null,
                                          ),
                                        ),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () async {
                                            final newTasks = List<_GateTask>.from(_tasks)..removeAt(idx);
                                            await GateTaskManager.completeAllTasks();
                                            if (newTasks.isNotEmpty) {
                                              await GateTaskManager.addTasks(newTasks.map((e) => e.text).toList());
                                            }
                                            _loadTasks();
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                const SizedBox(height: AppConstants.paddingSmall),
                                Text('Blocked apps are managed in the dashboard.', style: TextStyle(fontSize: 13, color: theme.mainText.withOpacity(0.87))),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    // Service status banner
                    if (!_isServiceEnabled)
                      ServiceStatusBanner(isServiceEnabled: _isServiceEnabled),
                    // Theme toggle
                    NeuCard(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                theme.isDark
                                    ? Icons.dark_mode
                                    : Icons.light_mode,
                                color: theme.accent,
                                size: 28,
                              ),
                              const SizedBox(width: AppConstants.paddingMedium),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppStrings.settingsThemeToggle,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: theme.mainText,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    theme.isDark
                                        ? AppStrings.settingsThemeNight
                                        : AppStrings.settingsThemeDay,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: theme.mainText.withOpacity(0.87),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          NeuToggle(
                            value: theme.isDark,
                            onChanged: (_) => themeNotifier.toggleTheme(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),

                    // Access Duration setting
                    NeuCard(
                      child: Padding(
                        padding:
                            const EdgeInsets.all(AppConstants.paddingMedium),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.timer,
                                  color: theme.accent,
                                  size: 28,
                                ),
                                const SizedBox(
                                    width: AppConstants.paddingMedium),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Access Duration',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: theme.mainText,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'How long apps stay unlocked',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: theme.mainText.withOpacity(0.87),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: AppConstants.paddingMedium),
                            GestureDetector(
                              onTap: _showDurationPicker,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${_duration.inMinutes} minutes',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: theme.accent,
                                    ),
                                  ),
                                  NeuIconButton(
                                    icon: Icons.edit,
                                    onTap: _showDurationPicker,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppConstants.paddingSmall),
                            Text(
                              'After completing a challenge, you\'ll have ${_duration.inMinutes} minutes of access.',
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.mainText.withOpacity(0.87),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),

                    // Overlay Type setting
                    NeuCard(
                      child: Padding(
                        padding:
                            const EdgeInsets.all(AppConstants.paddingMedium),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.layers,
                                  color: theme.accent,
                                  size: 28,
                                ),
                                const SizedBox(
                                    width: AppConstants.paddingMedium),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Overlay Type',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: theme.mainText,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Choose your challenge',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: theme.mainText.withOpacity(0.87),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: AppConstants.paddingMedium),
                            Text('Overlay: Chase', style: TextStyle(fontSize: 16, color: theme.mainText)),
                          ],
                        ),
                      ),
                    ),

                    // Permissions section
                    Text(
                      AppStrings.settingsPermissions,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.mainText.withOpacity(0.87),
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    NeuCard(
                      child: Row(
                        children: [
                          Icon(
                            Icons.accessibility,
                            color: theme.accent,
                            size: 28,
                          ),
                          const SizedBox(width: AppConstants.paddingMedium),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Accessibility Service',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: theme.mainText,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Required for app monitoring',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: theme.mainText.withOpacity(0.87),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            _isServiceEnabled
                                ? Icons.check_circle
                                : Icons.error,
                            color:
                                _isServiceEnabled ? Colors.green : Colors.red,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
