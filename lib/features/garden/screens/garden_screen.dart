// ============================================================================
// IDLEMAN v16.0 - GARDEN SCREEN
// ============================================================================
// File: lib/features/garden/screens/garden_screen.dart
// Purpose: Visual garden with plants, stats, and community
// Philosophy: Celebrate growth, connect with others on the journey
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idleman/core/theme/therapy_theme.dart';
import 'package:idleman/features/garden/providers/garden_provider.dart';

// ============================================================================
// GARDEN SCREEN
// ============================================================================
class GardenScreen extends ConsumerWidget {
  const GardenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('[GardenScreen::build] Building garden screen.');

    final gardenState = ref.watch(gardenProvider);

    return Scaffold(
      backgroundColor: _getBackgroundColor(gardenState.currentWeather),
      body: gardenState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // App bar with weather
                _buildSliverAppBar(context, gardenState),

                // Stats card
                SliverToBoxAdapter(
                  child: _buildStatsCard(gardenState),
                ),

                // My garden section
                SliverToBoxAdapter(
                  child: _buildMyGardenSection(context, ref, gardenState),
                ),

                // Community section
                SliverToBoxAdapter(
                  child: _buildCommunitySection(context, gardenState),
                ),

                // Bottom padding
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
      floatingActionButton: gardenState.isAuthenticated
          ? FloatingActionButton.extended(
              onPressed: () => _showPlantPicker(context, ref),
              backgroundColor: TherapyColors.growth,
              icon: const Icon(Icons.add),
              label: const Text('Plant'),
            )
          : null,
    );
  }

  Color _getBackgroundColor(GardenWeather weather) {
    switch (weather) {
      case GardenWeather.sunny:
        return const Color(0xFFFFFBE6); // Warm yellow tint
      case GardenWeather.cloudy:
        return const Color(0xFFF0F4F8); // Cool grey
      case GardenWeather.rainy:
        return const Color(0xFFE8EEF4); // Blue grey
      case GardenWeather.misty:
        return const Color(0xFFF5F5F0); // Soft green grey
    }
  }

  // -------------------------------------------------------------------------
  // APP BAR
  // -------------------------------------------------------------------------
  Widget _buildSliverAppBar(BuildContext context, GardenState state) {
    debugPrint('[GardenScreen::_buildSliverAppBar] Building app bar.');

    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                TherapyColors.growth.withOpacity(0.3),
                _getBackgroundColor(state.currentWeather),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Weather icon
                Text(
                  _getWeatherEmoji(state.currentWeather),
                  style: const TextStyle(fontSize: 48),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your Garden',
                  style: TherapyText.heading1().copyWith(
                    color: TherapyColors.ink,
                  ),
                ),
                Text(
                  'Level ${state.gardenLevel}',
                  style: TherapyText.body().copyWith(
                    color: TherapyColors.graphite,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            // Settings or info
          },
          icon: Icon(
            Icons.info_outline,
            color: TherapyColors.ink,
          ),
        ),
      ],
    );
  }

  String _getWeatherEmoji(GardenWeather weather) {
    switch (weather) {
      case GardenWeather.sunny:
        return '☀️';
      case GardenWeather.cloudy:
        return '⛅';
      case GardenWeather.rainy:
        return '🌧️';
      case GardenWeather.misty:
        return '🌫️';
    }
  }

  // -------------------------------------------------------------------------
  // STATS CARD
  // -------------------------------------------------------------------------
  Widget _buildStatsCard(GardenState state) {
    debugPrint('[GardenScreen::_buildStatsCard] Building stats.');

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TherapyColors.surface,
        borderRadius: TherapyShapes.cardBorderRadius(),
        boxShadow: TherapyShadows.card(),
      ),
      child: Column(
        children: [
          // Level progress
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Garden Level ${state.gardenLevel}',
                      style: TherapyText.heading3(),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: LinearProgressIndicator(
                        value: state.levelProgress,
                        backgroundColor: TherapyColors.graphite.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation(TherapyColors.growth),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(state.levelProgress * 60).toInt()} / 60 min to next level',
                      style: TherapyText.caption().copyWith(
                        color: TherapyColors.graphite,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),

          // Stats row
          Row(
            children: [
              _buildStatItem(
                '${state.totalMinutesReclaimed}',
                'Minutes\nReclaimed',
                Icons.access_time_rounded,
              ),
              _buildStatItem(
                '${state.currentStreak}',
                'Day\nStreak',
                Icons.local_fire_department_rounded,
              ),
              _buildStatItem(
                '${state.myPlants.length}',
                'Plants\nGrown',
                Icons.eco_rounded,
              ),
              _buildStatItem(
                '${state.growthMultiplier}x',
                'Growth\nBonus',
                Icons.trending_up_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: TherapyColors.growth,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TherapyText.heading3().copyWith(
              color: TherapyColors.ink,
            ),
          ),
          Text(
            label,
            style: TherapyText.caption().copyWith(
              color: TherapyColors.graphite,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // MY GARDEN SECTION
  // -------------------------------------------------------------------------
  Widget _buildMyGardenSection(BuildContext context, WidgetRef ref, GardenState state) {
    debugPrint('[GardenScreen::_buildMyGardenSection] Building plant grid.');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Plants',
            style: TherapyText.heading2(),
          ),
          const SizedBox(height: 16),

          if (state.myPlants.isEmpty)
            _buildEmptyGarden(ref)
          else
            _buildPlantGrid(context, ref, state.myPlants),
        ],
      ),
    );
  }

  Widget _buildEmptyGarden(WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: TherapyColors.surface,
        borderRadius: TherapyShapes.cardBorderRadius(),
        border: Border.all(
          color: TherapyColors.growth.withOpacity(0.3),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Text(
            '🌱',
            style: const TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 16),
          Text(
            'Your garden is empty',
            style: TherapyText.heading3(),
          ),
          const SizedBox(height: 8),
          Text(
            'Plant your first seed to start growing!',
            style: TherapyText.body().copyWith(
              color: TherapyColors.graphite,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPlantGrid(BuildContext context, WidgetRef ref, List<GardenPlant> plants) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: plants.length,
      itemBuilder: (context, index) {
        final plant = plants[index];
        return _buildPlantCard(context, ref, plant);
      },
    );
  }

  Widget _buildPlantCard(BuildContext context, WidgetRef ref, GardenPlant plant) {
    return GestureDetector(
      onTap: () => _showPlantDetails(context, ref, plant),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: TherapyColors.surface,
          borderRadius: TherapyShapes.cardBorderRadius(),
          boxShadow: TherapyShadows.card(),
          border: plant.isFullyGrown
              ? Border.all(color: TherapyColors.growth, width: 2)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Plant emoji
            Text(
              plant.stageEmoji,
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(height: 8),

            // Name
            Text(
              plant.displayName,
              style: TherapyText.caption().copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            // Progress
            if (!plant.isFullyGrown) ...[
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: LinearProgressIndicator(
                  value: plant.minutesInvested / plant.type.minutesToGrow,
                  backgroundColor: TherapyColors.graphite.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation(TherapyColors.growth),
                  minHeight: 4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showPlantDetails(BuildContext context, WidgetRef ref, GardenPlant plant) {
    debugPrint('[GardenScreen::_showPlantDetails] Showing details for ${plant.displayName}.');
    HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: TherapyColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Plant emoji large
            Text(
              plant.stageEmoji,
              style: const TextStyle(fontSize: 80),
            ),
            const SizedBox(height: 16),

            // Name
            Text(
              plant.displayName,
              style: TherapyText.heading2(),
            ),
            Text(
              plant.type.defaultName,
              style: TherapyText.caption().copyWith(
                color: TherapyColors.graphite,
              ),
            ),

            const SizedBox(height: 24),

            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPlantStat(
                  'Stage',
                  '${plant.growthStage + 1} / 5',
                ),
                _buildPlantStat(
                  'Invested',
                  '${plant.minutesInvested} min',
                ),
                _buildPlantStat(
                  'Planted',
                  _formatDate(plant.plantedAt),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Rename button
            TextButton.icon(
              onPressed: () => _showRenameDialog(context, ref, plant),
              icon: const Icon(Icons.edit),
              label: const Text('Rename'),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TherapyText.heading3(),
        ),
        Text(
          label,
          style: TherapyText.caption().copyWith(
            color: TherapyColors.graphite,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.month}/${date.day}';
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref, GardenPlant plant) {
    final controller = TextEditingController(text: plant.customName ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Plant'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: plant.type.defaultName,
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
              ref.read(gardenProvider.notifier).renamePlant(
                    plant.id,
                    controller.text.trim(),
                  );
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Close details sheet too
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // PLANT PICKER
  // -------------------------------------------------------------------------
  void _showPlantPicker(BuildContext context, WidgetRef ref) {
    debugPrint('[GardenScreen::_showPlantPicker] Opening plant picker.');
    HapticFeedback.mediumImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: TherapyColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose a Seed',
              style: TherapyText.heading2(),
            ),
            const SizedBox(height: 8),
            Text(
              'Plant something new in your garden',
              style: TherapyText.body().copyWith(
                color: TherapyColors.graphite,
              ),
            ),
            const SizedBox(height: 24),

            // Plant options
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: PlantType.values.map((type) {
                return _buildPlantOption(context, ref, type);
              }).toList(),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantOption(BuildContext context, WidgetRef ref, PlantType type) {
    return GestureDetector(
      onTap: () {
        ref.read(gardenProvider.notifier).plantSeed(type);
        HapticFeedback.mediumImpact();
        Navigator.of(context).pop();
      },
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: TherapyColors.canvas,
          borderRadius: TherapyShapes.cardBorderRadius(),
          border: Border.all(
            color: TherapyColors.graphite.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Text(
              type.bloomEmoji,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 8),
            Text(
              type.defaultName,
              style: TherapyText.caption(),
              textAlign: TextAlign.center,
            ),
            Text(
              '${type.minutesToGrow} min',
              style: TherapyText.caption().copyWith(
                color: TherapyColors.graphite,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // COMMUNITY SECTION
  // -------------------------------------------------------------------------
  Widget _buildCommunitySection(BuildContext context, GardenState state) {
    debugPrint('[GardenScreen::_buildCommunitySection] Building community.');

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Community Garden',
                style: TherapyText.heading2(),
              ),
              TextButton(
                onPressed: () {
                  // View full leaderboard
                },
                child: Text(
                  'See All',
                  style: TherapyText.button().copyWith(
                    color: TherapyColors.growth,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Leaderboard
          Container(
            decoration: BoxDecoration(
              color: TherapyColors.surface,
              borderRadius: TherapyShapes.cardBorderRadius(),
              boxShadow: TherapyShadows.card(),
            ),
            child: Column(
              children: state.communityGardeners.take(5).toList().asMap().entries.map((entry) {
                final index = entry.key;
                final gardener = entry.value;
                return _buildLeaderboardRow(index + 1, gardener);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardRow(int rank, CommunityGardener gardener) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 32,
            child: Text(
              rank <= 3 ? ['🥇', '🥈', '🥉'][rank - 1] : '#$rank',
              style: TherapyText.body(),
            ),
          ),

          // Name
          Expanded(
            child: Text(
              gardener.displayName,
              style: TherapyText.body(),
            ),
          ),

          // Stats
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${gardener.totalMinutes} min',
                style: TherapyText.caption().copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${gardener.streak} day streak',
                style: TherapyText.caption().copyWith(
                  color: TherapyColors.graphite,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
