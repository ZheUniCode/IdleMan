import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/blocklist_provider.dart';
import '../../core/services/platform_services.dart';
import '../../widgets/neumorphic/neu_card.dart';
import '../../widgets/neumorphic/neu_toggle.dart';
import '../../widgets/service_status_banner.dart';
import '../../widgets/neumorphic/neu_background.dart';
import '../../widgets/neumorphic/neu_button.dart';

/// Settings Screen
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isServiceEnabled = false;
  Duration _duration = const Duration(minutes: AppConstants.defaultBypassDuration);
  OverlayType _selectedOverlay = OverlayType.chase;

  @override
  void initState() {
    super.initState();
    _checkServiceStatus();
    _loadDuration();
    _loadOverlay();
  }

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
    final prefs = await SharedPreferences.getInstance();
    final overlayName = prefs.getString('overlay_type') ?? OverlayType.chase.name;
    if (mounted) {
      setState(() {
        _selectedOverlay = OverlayType.values.firstWhere(
          (e) => e.name == overlayName,
          orElse: () => OverlayType.chase,
        );
      });
    }
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
                            DropdownButton<OverlayType>(
                              value: _selectedOverlay,
                              isExpanded: true,
                              underline: Container(
                                height: 2,
                                color: theme.accent,
                              ),
                              onChanged: (OverlayType? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _selectedOverlay = newValue;
                                  });
                                  SharedPreferences.getInstance().then((prefs) {
                                    prefs.setString('overlay_type', newValue.name);
                                  });
                                }
                              },
                              items: [
                                DropdownMenuItem<OverlayType>(
                                  value: OverlayType.chase,
                                  child: Text('Chase'),
                                ),
                                DropdownMenuItem<OverlayType>(
                                  value: OverlayType.random,
                                  child: Text('Random (currently selects Chase)'),
                                ),
                              ],
                            ),
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
