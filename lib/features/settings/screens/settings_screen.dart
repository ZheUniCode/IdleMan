// ============================================================================
// IDLEMAN v16.0 - SETTINGS SCREEN
// ============================================================================
// File: lib/features/settings/screens/settings_screen.dart
// Purpose: User preferences and configuration interface
// Philosophy: Clear, calm controls for mindful boundary management
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idleman/core/theme/therapy_theme.dart';
import 'package:idleman/core/services/native_bridge.dart';
import 'package:idleman/features/settings/providers/settings_provider.dart';

// ============================================================================
// SETTINGS SCREEN
// ============================================================================
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    debugPrint('[SettingsScreen::initState] Initializing settings screen.');
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    debugPrint('[SettingsScreen::_checkPermissions] Checking all permissions...');
    
    final bridge = NativeBridge();
    
    // Check each permission status
    final usageStats = await bridge.hasUsageStatsPermission();
    final accessibility = await bridge.isAccessibilityServiceEnabled();
    final overlay = await bridge.hasOverlayPermission();
    final notification = await bridge.hasNotificationListenerPermission();

    debugPrint('[SettingsScreen::_checkPermissions] Usage: $usageStats, Accessibility: $accessibility, Overlay: $overlay, Notification: $notification');

    // Update provider state
    ref.read(settingsProvider.notifier).updatePermissions(
      usageStats: usageStats,
      accessibility: accessibility,
      overlay: overlay,
      notification: notification,
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[SettingsScreen::build] Building settings UI.');
    
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: TherapyColors.canvas,
      appBar: _buildAppBar(context),
      body: settings.isLoading
          ? _buildLoadingState()
          : _buildSettingsList(context, settings),
    );
  }

  // -------------------------------------------------------------------------
  // APP BAR
  // -------------------------------------------------------------------------
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    debugPrint('[SettingsScreen::_buildAppBar] Building app bar.');

    return AppBar(
      backgroundColor: TherapyColors.canvas,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_rounded,
          color: TherapyColors.ink,
        ),
        onPressed: () {
          debugPrint('[SettingsScreen] Back button tapped.');
          HapticFeedback.lightImpact();
          Navigator.of(context).pop();
        },
      ),
      title: Text(
        'Settings',
        style: TherapyText.heading2(),
      ),
      centerTitle: true,
    );
  }

  // -------------------------------------------------------------------------
  // LOADING STATE
  // -------------------------------------------------------------------------
  Widget _buildLoadingState() {
    debugPrint('[SettingsScreen::_buildLoadingState] Showing loading.');

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(TherapyColors.growth),
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading settings...',
            style: TherapyText.body(),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // SETTINGS LIST
  // -------------------------------------------------------------------------
  Widget _buildSettingsList(BuildContext context, SettingsState settings) {
    debugPrint('[SettingsScreen::_buildSettingsList] Building settings list.');

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Stats Section
        _buildStatsCard(settings),
        const SizedBox(height: 24),

        // Permissions Section
        _buildSectionHeader('Permissions'),
        const SizedBox(height: 12),
        _buildPermissionTile(
          title: 'Usage Stats Access',
          subtitle: 'Required to see app usage data',
          isGranted: settings.hasUsageStatsPermission,
          onTap: () async {
            debugPrint('[SettingsScreen] Usage stats permission tapped.');
            await NativeBridge().requestUsageStatsPermission();
            await _checkPermissions();
          },
        ),
        _buildPermissionTile(
          title: 'Accessibility Service',
          subtitle: 'Required to detect app launches',
          isGranted: settings.hasAccessibilityPermission,
          onTap: () async {
            debugPrint('[SettingsScreen] Accessibility permission tapped.');
            await NativeBridge().openAccessibilitySettings();
            await _checkPermissions();
          },
        ),
        _buildPermissionTile(
          title: 'Display Over Apps',
          subtitle: 'Required for boundary overlays',
          isGranted: settings.hasOverlayPermission,
          onTap: () async {
            debugPrint('[SettingsScreen] Overlay permission tapped.');
            await NativeBridge().requestOverlayPermission();
            await _checkPermissions();
          },
        ),
        _buildPermissionTile(
          title: 'Notification Access',
          subtitle: 'Optional: For notification digest',
          isGranted: settings.hasNotificationPermission,
          onTap: () async {
            debugPrint('[SettingsScreen] Notification permission tapped.');
            await NativeBridge().requestNotificationListenerPermission();
            await _checkPermissions();
          },
        ),
        const SizedBox(height: 24),

        // Boundary Settings Section
        _buildSectionHeader('Boundary Behavior'),
        const SizedBox(height: 12),
        _buildToggleTile(
          title: 'Strict Mode',
          subtitle: 'When enabled, Level 3 boundaries cannot be bypassed',
          value: settings.strictModeEnabled,
          onChanged: (value) {
            debugPrint('[SettingsScreen] Strict mode toggled: $value');
            HapticFeedback.mediumImpact();
            ref.read(settingsProvider.notifier).setStrictMode(value);
          },
          isDestructive: true,
        ),
        _buildToggleTile(
          title: 'Hydra Protocol',
          subtitle: 'Keep monitoring service alive in background',
          value: settings.hydraProtocolEnabled,
          onChanged: (value) {
            debugPrint('[SettingsScreen] Hydra protocol toggled: $value');
            HapticFeedback.lightImpact();
            ref.read(settingsProvider.notifier).setHydraProtocol(value);
          },
        ),
        const SizedBox(height: 24),

        // Notification Digest Section
        _buildSectionHeader('Notification Digest'),
        const SizedBox(height: 12),
        _buildToggleTile(
          title: 'Enable Digest',
          subtitle: 'Batch and sanitize notifications from bounded apps',
          value: settings.digestEnabled,
          onChanged: (value) {
            debugPrint('[SettingsScreen] Digest toggled: $value');
            HapticFeedback.lightImpact();
            ref.read(settingsProvider.notifier).setDigestEnabled(value);
          },
        ),
        if (settings.digestEnabled)
          _buildDigestScheduleCard(settings),
        const SizedBox(height: 24),

        // About Section
        _buildSectionHeader('About'),
        const SizedBox(height: 12),
        _buildInfoTile(
          title: 'Version',
          value: '16.0.0 (Paper Garden)',
        ),
        _buildInfoTile(
          title: 'Philosophy',
          value: 'Compassionate Discipline',
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // STATS CARD
  // -------------------------------------------------------------------------
  Widget _buildStatsCard(SettingsState settings) {
    debugPrint('[SettingsScreen::_buildStatsCard] Building stats display.');

    final hours = settings.timeReclaimedMinutes ~/ 60;
    final minutes = settings.timeReclaimedMinutes % 60;
    final timeDisplay = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: TherapyColors.surface,
        borderRadius: TherapyShapes.cardBorderRadius(),
        boxShadow: TherapyShadows.card(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Journey',
            style: TherapyText.heading3(),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  label: 'Time Reclaimed',
                  value: timeDisplay,
                  icon: Icons.timer_outlined,
                  color: TherapyColors.growth,
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: TherapyColors.graphite.withOpacity(0.2),
              ),
              Expanded(
                child: _buildStatItem(
                  label: 'Current Streak',
                  value: '${settings.currentStreak} days',
                  icon: Icons.local_fire_department_outlined,
                  color: TherapyColors.boundary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Longest streak: ${settings.longestStreak} days',
            style: TherapyText.caption().copyWith(
              color: TherapyColors.graphite,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TherapyText.heading2().copyWith(
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TherapyText.caption(),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // SECTION HEADER
  // -------------------------------------------------------------------------
  Widget _buildSectionHeader(String title) {
    debugPrint('[SettingsScreen::_buildSectionHeader] Section: $title');

    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: TherapyText.caption().copyWith(
          color: TherapyColors.graphite,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // PERMISSION TILE
  // -------------------------------------------------------------------------
  Widget _buildPermissionTile({
    required String title,
    required String subtitle,
    required bool isGranted,
    required VoidCallback onTap,
  }) {
    debugPrint('[SettingsScreen::_buildPermissionTile] $title: $isGranted');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: TherapyColors.surface,
        borderRadius: TherapyShapes.cardBorderRadius(),
        boxShadow: TherapyShadows.card(),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isGranted
                ? TherapyColors.growth.withOpacity(0.15)
                : TherapyColors.boundary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isGranted ? Icons.check_circle_outline : Icons.warning_amber_outlined,
            color: isGranted ? TherapyColors.growth : TherapyColors.boundary,
          ),
        ),
        title: Text(title, style: TherapyText.body()),
        subtitle: Text(
          subtitle,
          style: TherapyText.caption().copyWith(
            color: TherapyColors.graphite,
          ),
        ),
        trailing: isGranted
            ? null
            : TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onTap();
                },
                child: Text(
                  'Grant',
                  style: TherapyText.body().copyWith(
                    color: TherapyColors.growth,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
        onTap: isGranted ? null : () {
          HapticFeedback.lightImpact();
          onTap();
        },
      ),
    );
  }

  // -------------------------------------------------------------------------
  // TOGGLE TILE
  // -------------------------------------------------------------------------
  Widget _buildToggleTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isDestructive = false,
  }) {
    debugPrint('[SettingsScreen::_buildToggleTile] $title: $value');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: TherapyColors.surface,
        borderRadius: TherapyShapes.cardBorderRadius(),
        boxShadow: TherapyShadows.card(),
        border: isDestructive && value
            ? Border.all(color: TherapyColors.boundary.withOpacity(0.3), width: 1.5)
            : null,
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: Text(
          title,
          style: TherapyText.body().copyWith(
            color: isDestructive && value ? TherapyColors.boundary : TherapyColors.ink,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TherapyText.caption().copyWith(
            color: TherapyColors.graphite,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: isDestructive ? TherapyColors.boundary : TherapyColors.growth,
        activeTrackColor: isDestructive
            ? TherapyColors.boundary.withOpacity(0.3)
            : TherapyColors.growth.withOpacity(0.3),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // DIGEST SCHEDULE CARD
  // -------------------------------------------------------------------------
  Widget _buildDigestScheduleCard(SettingsState settings) {
    debugPrint('[SettingsScreen::_buildDigestScheduleCard] Building schedules.');

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TherapyColors.surface,
        borderRadius: TherapyShapes.cardBorderRadius(),
        boxShadow: TherapyShadows.card(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery Times',
            style: TherapyText.body().copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...settings.digestSchedules.map((schedule) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule,
                    color: TherapyColors.graphite,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    schedule.displayTime,
                    style: TherapyText.body(),
                  ),
                  const Spacer(),
                  Switch(
                    value: schedule.isEnabled,
                    onChanged: (value) {
                      debugPrint('[SettingsScreen] Schedule toggle: ${schedule.displayTime} -> $value');
                      HapticFeedback.lightImpact();
                      // TODO: Implement schedule toggle
                    },
                    activeColor: TherapyColors.growth,
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () {
              debugPrint('[SettingsScreen] Add digest time tapped.');
              HapticFeedback.lightImpact();
              _showAddScheduleDialog();
            },
            icon: Icon(Icons.add, color: TherapyColors.growth),
            label: Text(
              'Add Time',
              style: TherapyText.body().copyWith(
                color: TherapyColors.growth,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddScheduleDialog() {
    debugPrint('[SettingsScreen::_showAddScheduleDialog] Showing time picker.');

    showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    ).then((time) {
      if (time != null) {
        debugPrint('[SettingsScreen] New schedule time: ${time.hour}:${time.minute}');
        // TODO: Add new schedule
      }
    });
  }

  // -------------------------------------------------------------------------
  // INFO TILE
  // -------------------------------------------------------------------------
  Widget _buildInfoTile({
    required String title,
    required String value,
  }) {
    debugPrint('[SettingsScreen::_buildInfoTile] $title: $value');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: TherapyColors.surface,
        borderRadius: TherapyShapes.cardBorderRadius(),
        boxShadow: TherapyShadows.card(),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TherapyText.body()),
          Text(
            value,
            style: TherapyText.body().copyWith(
              color: TherapyColors.graphite,
            ),
          ),
        ],
      ),
    );
  }
}
