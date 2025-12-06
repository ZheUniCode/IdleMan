// ============================================================================
// IDLEMAN v16.0 - DIGEST SCREEN
// ============================================================================
// File: lib/features/digest/screens/digest_screen.dart
// Purpose: View and manage batched notifications
// Philosophy: Calm, organized delivery of updates
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idleman/core/theme/therapy_theme.dart';
import 'package:idleman/features/digest/providers/digest_provider.dart';

// ============================================================================
// DIGEST SCREEN
// ============================================================================
class DigestScreen extends ConsumerWidget {
  const DigestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('[DigestScreen::build] Building digest screen.');

    final digestState = ref.watch(digestProvider);

    return Scaffold(
      backgroundColor: TherapyColors.canvas,
      appBar: AppBar(
        backgroundColor: TherapyColors.canvas,
        elevation: 0,
        title: Text(
          'Notification Digest',
          style: TherapyText.heading2(),
        ),
        actions: [
          // Settings
          IconButton(
            onPressed: () => _showDigestSettings(context, ref),
            icon: Icon(
              Icons.tune_rounded,
              color: TherapyColors.ink,
            ),
          ),
        ],
      ),
      body: digestState.isEnabled
          ? _buildDigestContent(context, ref, digestState)
          : _buildEnablePrompt(context, ref, digestState),
    );
  }

  // -------------------------------------------------------------------------
  // ENABLE PROMPT
  // -------------------------------------------------------------------------
  Widget _buildEnablePrompt(BuildContext context, WidgetRef ref, DigestState state) {
    debugPrint('[DigestScreen::_buildEnablePrompt] Showing enable prompt.');

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: TherapyColors.growth.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_paused_rounded,
              size: 70,
              color: TherapyColors.growth,
            ),
          ),
          const SizedBox(height: 32),

          // Title
          Text(
            'Batch Your Notifications',
            style: TherapyText.heading2(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            'Instead of constant interruptions, receive all your '
            'notifications in calm, scheduled batches.',
            style: TherapyText.body().copyWith(
              color: TherapyColors.graphite,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          // Benefits
          _buildBenefit(
            Icons.spa_rounded,
            'Reduce anxiety',
            'No more notification FOMO',
          ),
          const SizedBox(height: 16),
          _buildBenefit(
            Icons.schedule_rounded,
            'Stay focused',
            'Choose when to check updates',
          ),
          const SizedBox(height: 16),
          _buildBenefit(
            Icons.security_rounded,
            'Privacy first',
            'Sensitive info auto-hidden',
          ),

          const SizedBox(height: 40),

          // Enable button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                debugPrint('[DigestScreen] Enable tapped.');
                HapticFeedback.mediumImpact();
                await ref.read(digestProvider.notifier).setEnabled(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TherapyColors.growth,
                foregroundColor: TherapyColors.surface,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Enable Digest Mode',
                style: TherapyText.button().copyWith(
                  color: TherapyColors.surface,
                ),
              ),
            ),
          ),

          if (!state.hasNotificationAccess) ...[
            const SizedBox(height: 12),
            Text(
              'Requires notification access permission',
              style: TherapyText.caption().copyWith(
                color: TherapyColors.graphite,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBenefit(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: TherapyColors.growth.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: TherapyColors.growth,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TherapyText.body().copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: TherapyText.caption().copyWith(
                  color: TherapyColors.graphite,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // DIGEST CONTENT
  // -------------------------------------------------------------------------
  Widget _buildDigestContent(BuildContext context, WidgetRef ref, DigestState state) {
    debugPrint('[DigestScreen::_buildDigestContent] Building content.');

    return Column(
      children: [
        // Status card
        _buildStatusCard(ref, state),

        // Next delivery info
        _buildNextDeliveryInfo(state),

        // Pending notifications
        Expanded(
          child: state.pendingNotifications.isEmpty
              ? _buildEmptyState()
              : _buildNotificationList(ref, state),
        ),
      ],
    );
  }

  Widget _buildStatusCard(WidgetRef ref, DigestState state) {
    debugPrint('[DigestScreen::_buildStatusCard] Building status.');

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TherapyColors.surface,
        borderRadius: TherapyShapes.cardBorderRadius(),
        boxShadow: TherapyShadows.card(),
      ),
      child: Row(
        children: [
          // Stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${state.pendingNotifications.length}',
                  style: TherapyText.heading1().copyWith(
                    color: TherapyColors.growth,
                  ),
                ),
                Text(
                  'pending notifications',
                  style: TherapyText.caption().copyWith(
                    color: TherapyColors.graphite,
                  ),
                ),
              ],
            ),
          ),

          // Actions
          if (state.pendingNotifications.isNotEmpty) ...[
            // Deliver now
            IconButton(
              onPressed: () async {
                debugPrint('[DigestScreen] Deliver now tapped.');
                HapticFeedback.mediumImpact();
                await ref.read(digestProvider.notifier).deliverNow();
              },
              style: IconButton.styleFrom(
                backgroundColor: TherapyColors.growth.withOpacity(0.1),
              ),
              icon: Icon(
                Icons.send_rounded,
                color: TherapyColors.growth,
              ),
              tooltip: 'Deliver now',
            ),
            const SizedBox(width: 8),

            // Clear all
            IconButton(
              onPressed: () async {
                debugPrint('[DigestScreen] Clear all tapped.');
                HapticFeedback.lightImpact();
                await ref.read(digestProvider.notifier).clearPending();
              },
              style: IconButton.styleFrom(
                backgroundColor: TherapyColors.graphite.withOpacity(0.1),
              ),
              icon: Icon(
                Icons.clear_all_rounded,
                color: TherapyColors.graphite,
              ),
              tooltip: 'Clear all',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNextDeliveryInfo(DigestState state) {
    final enabledSchedules = state.schedules.where((s) => s.isEnabled).toList();
    if (enabledSchedules.isEmpty) return const SizedBox.shrink();

    // Find next delivery
    final nextTimes = enabledSchedules.map((s) => MapEntry(s, s.nextDeliveryTime));
    final soonest = nextTimes.reduce((a, b) => a.value.isBefore(b.value) ? a : b);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(
            Icons.schedule_rounded,
            size: 16,
            color: TherapyColors.graphite,
          ),
          const SizedBox(width: 8),
          Text(
            'Next delivery: ${soonest.key.label} at ${soonest.key.timeString}',
            style: TherapyText.caption().copyWith(
              color: TherapyColors.graphite,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    debugPrint('[DigestScreen::_buildEmptyState] No pending notifications.');

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_rounded,
            size: 64,
            color: TherapyColors.graphite.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'All caught up!',
            style: TherapyText.heading3().copyWith(
              color: TherapyColors.graphite,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No pending notifications',
            style: TherapyText.body().copyWith(
              color: TherapyColors.graphite.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(WidgetRef ref, DigestState state) {
    debugPrint('[DigestScreen::_buildNotificationList] Building list.');

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.pendingNotifications.length,
      itemBuilder: (context, index) {
        final entry = state.pendingNotifications[index];
        return _buildNotificationCard(entry);
      },
    );
  }

  Widget _buildNotificationCard(DigestEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TherapyColors.surface,
        borderRadius: TherapyShapes.cardBorderRadius(),
        border: entry.priority == NotificationPriority.urgent
            ? Border.all(color: TherapyColors.boundary.withOpacity(0.5))
            : entry.priority == NotificationPriority.high
                ? Border.all(color: TherapyColors.growth.withOpacity(0.5))
                : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App icon placeholder
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: TherapyColors.graphite.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                entry.appName.substring(0, 1).toUpperCase(),
                style: TherapyText.heading3().copyWith(
                  color: TherapyColors.graphite,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.appName,
                        style: TherapyText.caption().copyWith(
                          color: TherapyColors.graphite,
                        ),
                      ),
                    ),
                    if (entry.isGrouped)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: TherapyColors.graphite.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          '${entry.groupCount}',
                          style: TherapyText.caption().copyWith(
                            fontSize: 11,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  entry.title,
                  style: TherapyText.body().copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (entry.body.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    entry.sanitizedBody,
                    style: TherapyText.caption().copyWith(
                      color: TherapyColors.graphite,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // SETTINGS DIALOG
  // -------------------------------------------------------------------------
  void _showDigestSettings(BuildContext context, WidgetRef ref) {
    debugPrint('[DigestScreen::_showDigestSettings] Opening settings.');
    HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: TherapyColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _DigestSettingsSheet(ref: ref),
    );
  }
}

// ============================================================================
// DIGEST SETTINGS SHEET
// ============================================================================
class _DigestSettingsSheet extends ConsumerWidget {
  final WidgetRef ref;

  const _DigestSettingsSheet({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final digestState = ref.watch(digestProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: scrollController,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: TherapyColors.graphite.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'Digest Settings',
                style: TherapyText.heading2(),
              ),
              const SizedBox(height: 24),

              // Enable toggle
              SwitchListTile(
                value: digestState.isEnabled,
                onChanged: (value) {
                  ref.read(digestProvider.notifier).setEnabled(value);
                },
                title: Text(
                  'Digest Mode',
                  style: TherapyText.body(),
                ),
                subtitle: Text(
                  'Batch notifications for scheduled delivery',
                  style: TherapyText.caption().copyWith(
                    color: TherapyColors.graphite,
                  ),
                ),
                activeColor: TherapyColors.growth,
              ),

              const SizedBox(height: 24),

              // Schedules
              Text(
                'Delivery Times',
                style: TherapyText.heading3(),
              ),
              const SizedBox(height: 12),

              ...digestState.schedules.map((schedule) => _buildScheduleTile(
                    context,
                    ref,
                    schedule,
                  )),

              const SizedBox(height: 16),

              // Add schedule button
              OutlinedButton.icon(
                onPressed: () => _showAddScheduleDialog(context, ref),
                icon: const Icon(Icons.add),
                label: const Text('Add Time'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: TherapyColors.growth,
                  side: BorderSide(color: TherapyColors.growth),
                ),
              ),

              const SizedBox(height: 24),

              // Disable button
              if (digestState.isEnabled)
                TextButton(
                  onPressed: () {
                    ref.read(digestProvider.notifier).setEnabled(false);
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Disable Digest Mode',
                    style: TherapyText.body().copyWith(
                      color: TherapyColors.boundary,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScheduleTile(BuildContext context, WidgetRef ref, DigestSchedule schedule) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Switch(
        value: schedule.isEnabled,
        onChanged: (value) {
          ref.read(digestProvider.notifier).toggleSchedule(schedule.id, value);
        },
        activeColor: TherapyColors.growth,
      ),
      title: Text(
        schedule.label,
        style: TherapyText.body(),
      ),
      subtitle: Text(
        schedule.timeString,
        style: TherapyText.caption().copyWith(
          color: TherapyColors.graphite,
        ),
      ),
      trailing: IconButton(
        onPressed: () async {
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay(hour: schedule.hour, minute: schedule.minute),
          );
          if (time != null) {
            ref.read(digestProvider.notifier).updateSchedule(
                  DigestSchedule(
                    id: schedule.id,
                    label: schedule.label,
                    hour: time.hour,
                    minute: time.minute,
                    isEnabled: schedule.isEnabled,
                  ),
                );
          }
        },
        icon: Icon(
          Icons.edit_rounded,
          color: TherapyColors.graphite,
        ),
      ),
    );
  }

  void _showAddScheduleDialog(BuildContext context, WidgetRef ref) async {
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
    );

    if (time != null && context.mounted) {
      // Show label dialog
      final labelController = TextEditingController();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Schedule Name'),
          content: TextField(
            controller: labelController,
            decoration: const InputDecoration(
              hintText: 'e.g., Afternoon',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final label = labelController.text.trim();
                if (label.isNotEmpty) {
                  ref.read(digestProvider.notifier).addSchedule(
                        DigestSchedule(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          label: label,
                          hour: time.hour,
                          minute: time.minute,
                        ),
                      );
                }
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        ),
      );
    }
  }
}
