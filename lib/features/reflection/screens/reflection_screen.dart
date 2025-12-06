// ============================================================================
// IDLEMAN v16.0 - REFLECTION SCREEN
// ============================================================================
// File: lib/features/reflection/screens/reflection_screen.dart
// Purpose: The main "Journal Entry" list UI for reflecting on app usage
// Philosophy: "Where is your energy going?" - Compassionate self-discovery
// ============================================================================

// Import Flutter's material design library
import 'package:flutter/material.dart';

// Import Riverpod for state management
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import our theme system
import 'package:idleman/core/theme/therapy_theme.dart';

// Import our usage provider and models
import 'package:idleman/features/reflection/providers/usage_provider.dart';
import 'package:idleman/features/reflection/models/app_usage_model.dart';
import 'package:idleman/features/settings/screens/settings_screen.dart';

// ============================================================================
// REFLECTION SCREEN
// ============================================================================
// The main dashboard where users "reflect" on their app usage
// Displays apps as "Journal Entries" with usage time and boundary toggles
// ============================================================================
class ReflectionScreen extends ConsumerWidget {
  // -------------------------------------------------------------------------
  // Constructor - const for performance optimization
  // -------------------------------------------------------------------------
  const ReflectionScreen({super.key});

  // -------------------------------------------------------------------------
  // BUILD METHOD - Constructs the widget tree
  // -------------------------------------------------------------------------
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Log entry into build method
    debugPrint('[ReflectionScreen::build] Building Reflection screen.');

    // Watch the usage provider for state changes
    final usageState = ref.watch(usageProvider);

    // Log the current state
    debugPrint('[ReflectionScreen::build] isLoading: ${usageState.isLoading}');
    debugPrint('[ReflectionScreen::build] Apps count: ${usageState.apps.length}');

    // Build the scaffold with Therapy Paper aesthetic
    return Scaffold(
      // -----------------------------------------------------------------------
      // Background color is set by theme (Canvas - Warm Cream)
      // -----------------------------------------------------------------------
      backgroundColor: TherapyColors.canvas,

      // -----------------------------------------------------------------------
      // App Bar - Minimal, calming header
      // -----------------------------------------------------------------------
      appBar: _buildAppBar(context),

      // -----------------------------------------------------------------------
      // Body - The main content area
      // -----------------------------------------------------------------------
      body: _buildBody(context, ref, usageState),
    );
  }

  // -------------------------------------------------------------------------
  // PRIVATE: Build the app bar
  // Minimal design with therapeutic messaging
  // -------------------------------------------------------------------------
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    // Log entry into the method
    debugPrint('[ReflectionScreen::_buildAppBar] Building app bar.');

    // Return the AppBar widget
    return AppBar(
      // Title with therapeutic question
      title: Text(
        'Reflection',
        style: TherapyText.heading2(),
      ),
      // Center the title for balanced look
      centerTitle: true,
      // No elevation for seamless look
      elevation: 0,
      // Background matches scaffold
      backgroundColor: TherapyColors.canvas,
      // Add settings action button
      actions: [
        // Settings icon button
        IconButton(
          // Use outlined settings icon
          icon: const Icon(
            Icons.settings_outlined,
            color: TherapyColors.graphite,
          ),
          // On tap, show settings (placeholder for now)
          onPressed: () {
            debugPrint('[ReflectionScreen::_buildAppBar] Settings tapped.');
            // Show a snackbar indicating settings is coming soon
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Settings coming soon...',
                  style: TherapyText.body().copyWith(color: TherapyColors.surface),
                ),
                backgroundColor: TherapyColors.ink,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          // Accessibility label
          tooltip: 'Settings',
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // PRIVATE: Build the main body content
  // Shows loading, error, or the app list
  // -------------------------------------------------------------------------
  Widget _buildBody(BuildContext context, WidgetRef ref, UsageState usageState) {
    // Log entry into the method
    debugPrint('[ReflectionScreen::_buildBody] Building body content.');

    // Check if we're loading
    if (usageState.isLoading) {
      // Show loading indicator
      debugPrint('[ReflectionScreen::_buildBody] Showing loading state.');
      return _buildLoadingState();
    }

    // Check if there's an error
    if (usageState.errorMessage != null) {
      // Show error state
      debugPrint('[ReflectionScreen::_buildBody] Showing error state.');
      return _buildErrorState(ref, usageState.errorMessage!);
    }

    // Check if there are no apps
    if (usageState.filteredApps.isEmpty) {
      // Show empty state
      debugPrint('[ReflectionScreen::_buildBody] Showing empty state.');
      return _buildEmptyState();
    }

    // Show the app list
    debugPrint('[ReflectionScreen::_buildBody] Showing app list.');
    return _buildAppList(context, ref, usageState);
  }

  // -------------------------------------------------------------------------
  // PRIVATE: Build the loading state
  // Calm, non-intrusive loading indicator
  // -------------------------------------------------------------------------
  Widget _buildLoadingState() {
    // Log entry into the method
    debugPrint('[ReflectionScreen::_buildLoadingState] Building loading state.');

    // Return centered loading indicator
    return Center(
      // Column for vertical centering
      child: Column(
        // Center vertically
        mainAxisAlignment: MainAxisAlignment.center,
        // Column children
        children: [
          // Circular progress indicator with Growth color
          const CircularProgressIndicator(
            // Use Growth (Sage Green) color
            color: TherapyColors.growth,
            // Thin stroke for elegance
            strokeWidth: 2,
          ),
          // Spacing
          const SizedBox(height: 24),
          // Loading message
          Text(
            'Gathering your reflections...',
            style: TherapyText.body().copyWith(
              color: TherapyColors.graphite,
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // PRIVATE: Build the error state
  // Gentle, non-judgmental error message
  // -------------------------------------------------------------------------
  Widget _buildErrorState(WidgetRef ref, String errorMessage) {
    // Log entry into the method
    debugPrint('[ReflectionScreen::_buildErrorState] Building error state: $errorMessage');

    // Return centered error message with retry button
    return Center(
      // Padding for margins
      child: Padding(
        padding: const EdgeInsets.all(32),
        // Column for vertical layout
        child: Column(
          // Center vertically
          mainAxisAlignment: MainAxisAlignment.center,
          // Column children
          children: [
            // Error icon (using Boundary color, not aggressive red)
            const Icon(
              Icons.refresh_outlined,
              size: 64,
              color: TherapyColors.boundary,
            ),
            // Spacing
            const SizedBox(height: 24),
            // Error message
            Text(
              errorMessage,
              style: TherapyText.body(),
              textAlign: TextAlign.center,
            ),
            // Spacing
            const SizedBox(height: 24),
            // Retry button
            ElevatedButton(
              onPressed: () {
                debugPrint('[ReflectionScreen::_buildErrorState] Retry tapped.');
                ref.read(usageProvider.notifier).refresh();
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // PRIVATE: Build the empty state
  // Encouraging message when no apps are found
  // -------------------------------------------------------------------------
  Widget _buildEmptyState() {
    // Log entry into the method
    debugPrint('[ReflectionScreen::_buildEmptyState] Building empty state.');

    // Return centered empty message
    return Center(
      // Padding for margins
      child: Padding(
        padding: const EdgeInsets.all(32),
        // Column for vertical layout
        child: Column(
          // Center vertically
          mainAxisAlignment: MainAxisAlignment.center,
          // Column children
          children: [
            // Empty icon
            const Icon(
              Icons.spa_outlined,
              size: 64,
              color: TherapyColors.growth,
            ),
            // Spacing
            const SizedBox(height: 24),
            // Empty message
            Text(
              'No apps to reflect on',
              style: TherapyText.heading3(),
            ),
            // Spacing
            const SizedBox(height: 8),
            // Sub-message
            Text(
              'Your digital space is clear.',
              style: TherapyText.body().copyWith(
                color: TherapyColors.graphite,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // PRIVATE: Build the main app list
  // Shows header, category filters, and app cards
  // -------------------------------------------------------------------------
  Widget _buildAppList(BuildContext context, WidgetRef ref, UsageState usageState) {
    // Log entry into the method
    debugPrint('[ReflectionScreen::_buildAppList] Building app list with ${usageState.filteredApps.length} apps.');

    // Return a CustomScrollView for proper scrolling behavior
    return RefreshIndicator(
      // Pull-to-refresh color
      color: TherapyColors.growth,
      // On refresh callback
      onRefresh: () async {
        debugPrint('[ReflectionScreen::_buildAppList] Pull to refresh triggered.');
        await ref.read(usageProvider.notifier).refresh();
      },
      // The scrollable content
      child: CustomScrollView(
        // Physics for smooth scrolling
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        // Sliver children
        slivers: [
          // Header section with question and total time
          SliverToBoxAdapter(
            child: _buildHeader(usageState),
          ),

          // Category filter chips
          SliverToBoxAdapter(
            child: _buildCategoryFilters(ref, usageState),
          ),

          // App cards grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.8,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  // Get the app at this index
                  final app = usageState.filteredApps[index];
                  
                  // Build the app card
                  return _buildAppGridItem(context, ref, app);
                },
                // Number of items
                childCount: usageState.filteredApps.length,
              ),
            ),
          ),

          // Bottom padding
          const SliverPadding(
            padding: EdgeInsets.only(bottom: 32),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // PRIVATE: Build the header section
  // Shows the therapeutic question and total usage time
  // -------------------------------------------------------------------------
  Widget _buildHeader(UsageState usageState) {
    // Log entry into the method
    debugPrint('[ReflectionScreen::_buildHeader] Building header section.');

    // Return the header container
    return Padding(
      // Padding around the header
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      // Column for vertical layout
      child: Column(
        // Align to start
        crossAxisAlignment: CrossAxisAlignment.start,
        // Column children
        children: [
          // The therapeutic question (Serif font for authority)
          Text(
            'Where is your energy going?',
            style: TherapyText.heading1(),
          ),
          // Spacing
          const SizedBox(height: 8),
          // Today's total usage
          Row(
            // Row children
            children: [
              // Label
              Text(
                'Today: ',
                style: TherapyText.body().copyWith(
                  color: TherapyColors.graphite,
                ),
              ),
              // Total time
              Text(
                usageState.totalUsageFormatted,
                style: TherapyText.bodyBold().copyWith(
                  color: TherapyColors.boundary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // PRIVATE: Build category filter chips
  // Horizontal scroll of filter options
  // -------------------------------------------------------------------------
  Widget _buildCategoryFilters(WidgetRef ref, UsageState usageState) {
    // Log entry into the method
    debugPrint('[ReflectionScreen::_buildCategoryFilters] Building category filters.');

    // Return horizontal scroll view of chips
    return SizedBox(
      // Fixed height for the chip row
      height: 56,
      // Horizontal list view
      child: ListView.builder(
        // Scroll horizontally
        scrollDirection: Axis.horizontal,
        // Padding at start and end
        padding: const EdgeInsets.symmetric(horizontal: 16),
        // Number of categories
        itemCount: AppCategory.values.length,
        // Build each chip
        itemBuilder: (context, index) {
          // Get the category
          final category = AppCategory.values[index];
          
          // Check if this is the selected category
          final isSelected = category == usageState.selectedCategory;
          
          // Log which chip is being built
          debugPrint('[ReflectionScreen::_buildCategoryFilters] Building chip: ${category.displayName}, selected: $isSelected');
          
          // Return the filter chip with padding
          return Padding(
            // Horizontal padding between chips
            padding: const EdgeInsets.only(right: 8),
            // Center vertically
            child: Center(
              // The filter chip
              child: FilterChip(
                // Label text
                label: Text(
                  category.displayName,
                  style: TherapyText.caption().copyWith(
                    // Use appropriate color based on selection
                    color: isSelected ? TherapyColors.surface : TherapyColors.ink,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                // Selection state
                selected: isSelected,
                // On selection callback
                onSelected: (selected) {
                  debugPrint('[ReflectionScreen::_buildCategoryFilters] Category selected: ${category.displayName}');
                  ref.read(usageProvider.notifier).setCategory(category);
                },
                // Background color when selected
                selectedColor: TherapyColors.growth,
                // Background color when not selected
                backgroundColor: TherapyColors.surface,
                // Check mark color
                checkmarkColor: TherapyColors.surface,
                // Show check mark when selected
                showCheckmark: false,
                // Shape
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(TherapyShapes.buttonRadius),
                  side: BorderSide(
                    color: isSelected ? TherapyColors.growth : TherapyColors.graphite.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                // Padding inside the chip
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          );
        },
      ),
    );
  }

  // -------------------------------------------------------------------------
  // PRIVATE: Build a single app card
  // The "Journal Entry" card for each app
  // -------------------------------------------------------------------------
  Widget _buildAppCard(BuildContext context, WidgetRef ref, AppUsageModel app) {
    // Log entry into the method
    debugPrint('[ReflectionScreen::_buildAppCard] Building card for: ${app.appName}');

    // Return the card container with margin
    return Padding(
      // Vertical margin between cards
      padding: const EdgeInsets.only(bottom: 12),
      // The card container
      child: Container(
        // Decoration for the "Paper" card look
        decoration: BoxDecoration(
          // Surface color (Pure White)
          color: TherapyColors.surface,
          // Rounded corners (24px)
          borderRadius: TherapyShapes.cardBorderRadius(),
          // Diffused shadow for floating effect
          boxShadow: TherapyShadows.card(),
        ),
        // Card content
        child: Material(
          // Transparent material for ink splash
          color: Colors.transparent,
          // Rounded corners for ink splash
          borderRadius: TherapyShapes.cardBorderRadius(),
          // InkWell for tap feedback
          child: InkWell(
            // Rounded corners for ink splash
            borderRadius: TherapyShapes.cardBorderRadius(),
            // On tap - show app details or options
            onTap: () {
              debugPrint('[ReflectionScreen::_buildAppCard] Card tapped: ${app.appName}');
              // TODO: Show app details bottom sheet
            },
            // Card inner content
            child: Padding(
              // Inner padding
              padding: const EdgeInsets.all(16),
              // Row for horizontal layout
              child: Row(
                // Children
                children: [
                  // App icon (or placeholder)
                  _buildAppIcon(app),
                  // Spacing
                  const SizedBox(width: 16),
                  // App name and usage time (expanded to fill space)
                  Expanded(
                    child: _buildAppInfo(app),
                  ),
                  // Boundary toggle
                  _buildBoundaryToggle(ref, app),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // PRIVATE: Build the app icon
  // Shows app icon or a placeholder
  // -------------------------------------------------------------------------
  Widget _buildAppIcon(AppUsageModel app) {
    // Log entry into the method
    debugPrint('[ReflectionScreen::_buildAppIcon] Building icon for: ${app.appName}');

    // Container for the icon
    return Container(
      // Fixed size for icon container
      width: 48,
      height: 48,
      // Decoration
      decoration: BoxDecoration(
        // Light grey background for placeholder
        color: TherapyColors.canvas,
        // Rounded corners
        borderRadius: BorderRadius.circular(12),
      ),
      // Center the icon
      child: Center(
        // Check if we have an actual icon
        child: app.appIcon != null
            // If we have icon bytes, display them
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  app.appIcon!,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                ),
              )
            // Otherwise show a placeholder icon
            : Icon(
                _getIconForCategory(app.category),
                color: TherapyColors.graphite,
                size: 24,
              ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // PRIVATE: Get an icon for the app category
  // Returns appropriate icon based on category
  // -------------------------------------------------------------------------
  IconData _getIconForCategory(String? category) {
    // Log the category lookup
    debugPrint('[ReflectionScreen::_getIconForCategory] Getting icon for category: $category');

    // Return icon based on category
    switch (category?.toLowerCase()) {
      case 'social':
        return Icons.people_outline;
      case 'games':
      case 'game':
        return Icons.sports_esports_outlined;
      case 'entertainment':
      case 'video':
        return Icons.play_circle_outline;
      case 'productivity':
        return Icons.work_outline;
      default:
        return Icons.apps_outlined;
    }
  }

  // -------------------------------------------------------------------------
  // PRIVATE: Build the app info section
  // Shows app name and usage time
  // -------------------------------------------------------------------------
  Widget _buildAppInfo(AppUsageModel app) {
    // Log entry into the method
    debugPrint('[ReflectionScreen::_buildAppInfo] Building info for: ${app.appName}');

    // Column for vertical layout
    return Column(
      // Align to start
      crossAxisAlignment: CrossAxisAlignment.start,
      // Children
      children: [
        // App name (using Serif for "Journal Entry" feel)
        Text(
          app.appName,
          style: TherapyText.heading3(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        // Spacing
        const SizedBox(height: 4),
        // Usage time
        Text(
          app.usageTimeFormatted,
          style: TherapyText.caption().copyWith(
            // Use Boundary color for high usage, Graphite for low
            color: app.usageTimeMs > 3600000 // More than 1 hour
                ? TherapyColors.boundary
                : TherapyColors.graphite,
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // PRIVATE: Build the boundary toggle
  // Switch to enable/disable boundary for the app
  // -------------------------------------------------------------------------
  Widget _buildBoundaryToggle(WidgetRef ref, AppUsageModel app) {
    // Log entry into the method
    debugPrint('[ReflectionScreen::_buildBoundaryToggle] Building toggle for: ${app.appName}, bounded: ${app.isBounded}');

    // Return the Switch widget
    return Switch(
      // Current value
      value: app.isBounded,
      // On change callback
      onChanged: (value) {
        debugPrint('[ReflectionScreen::_buildBoundaryToggle] Toggle changed for ${app.appName}: $value');
        ref.read(usageProvider.notifier).toggleBoundary(app.packageName);
      },
      // Active (on) color - Growth (Sage Green)
      activeColor: TherapyColors.growth,
      // Active track color
      activeTrackColor: TherapyColors.growth.withOpacity(0.3),
      // Inactive track color
      inactiveTrackColor: TherapyColors.graphite.withOpacity(0.2),
      // Inactive thumb color
      inactiveThumbColor: TherapyColors.graphite,
    );
  }

  // -------------------------------------------------------------------------
  // PRIVATE: Build a single app grid item
  // -------------------------------------------------------------------------
  Widget _buildAppGridItem(BuildContext context, WidgetRef ref, AppUsageModel app) {
    return Container(
      decoration: BoxDecoration(
        color: TherapyColors.surface,
        borderRadius: TherapyShapes.cardBorderRadius(),
        boxShadow: TherapyShadows.card(),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: TherapyShapes.cardBorderRadius(),
        child: InkWell(
          borderRadius: TherapyShapes.cardBorderRadius(),
          onTap: () {
             // TODO: Details
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildAppIcon(app),
                const SizedBox(height: 8),
                Text(
                  app.appName,
                  style: TherapyText.captionBold(),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  app.usageTimeFormatted,
                  style: TherapyText.caption().copyWith(color: TherapyColors.boundary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
