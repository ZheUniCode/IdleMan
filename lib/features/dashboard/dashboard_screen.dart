
import 'package:flutter/foundation.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/blocklist_provider.dart';
import '../../core/services/platform_services.dart';
import '../../widgets/neumorphic/neu_background.dart';
import '../../widgets/neumorphic/neu_card.dart';
import '../../widgets/neumorphic/neu_button.dart';
import '../../widgets/service_status_banner.dart';
/// Main Dashboard (Home Screen)
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _isServiceEnabled = false;
  List<AppInfo> _installedApps = [];
  Set<String> _selectedPackages = {};
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCategory = 'All'; // Default to 'All'

  // Category list
  final List<String> _categories = [
    'All',
    'Social',
    'Media',
    'Money',
    'Productivity',
    'Lifestyle',
    'System',
  ];

  bool _containsAny(String text, List<String> keywords) {
    for (final k in keywords) {
      if (text.contains(k)) return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    _checkServiceStatus();
    _loadInstalledApps();
    _loadBlocklist();
  }


  Future<void> _loadBlocklist() async {
    final blocklist = ref.read(blocklistProvider);
    setState(() {
      _selectedPackages = blocklist.map((app) => app.packageName).toSet();
    });
  }

  Future<void> _checkServiceStatus() async {
    final isEnabled = await PlatformServices.checkAccessibilityPermission();
    if (mounted) {
      setState(() {
        _isServiceEnabled = isEnabled;
      });
    }
  }

  Future<void> _loadInstalledApps() async {
    setState(() => _isLoading = true);
    try {
      final apps = await InstalledApps.getInstalledApps(
        excludeSystemApps: false,
        withIcon: true,
      );
      final launchableApps = apps
          .where((app) =>
              app.packageName != 'com.google.android.inputmethod.latin' &&
              app.packageName != 'com.android.providers.downloads.ui' &&
              app.packageName != 'com.android.providers.media' &&
              app.packageName != 'com.android.providers.downloads' &&
              app.packageName != 'com.android.providers.contacts')
          .toList();
      if (mounted) {
        setState(() {
          _installedApps = launchableApps;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  String _getAppCategory(AppInfo app) {
    final name = app.name.toLowerCase();
    final pkg = app.packageName.toLowerCase();

    if (_containsAny(pkg + name, [
      'facebook', 'whatsapp', 'discord', 'linkedin', 'messenger', 'instagram', 'twitter', 'snapchat'
    ])) {
      return 'Social';
    }
    if (_containsAny(pkg + name, [
      'youtube', 'spotify', 'netflix', 'kindle', 'music', 'video', 'podcast'
    ])) {
      return 'Media';
    }
    if (_containsAny(pkg + name, [
      'bank', 'invest', 'shop', 'wallet', 'finance', 'pay', 'money', 'paypal', 'venmo', 'cashapp'
    ])) {
      return 'Money';
    }
    if (_containsAny(pkg + name, [
      'work', 'cloud', 'drive', 'docs', 'sheet', 'utility', 'tools', 'office', 'calendar', 'todo', 'notes'
    ])) {
      return 'Productivity';
    }
    if (_containsAny(pkg + name, [
      'fit', 'health', 'travel', 'food', 'lifestyle', 'exercise', 'run', 'walk', 'gym', 'map', 'restaurant', 'hotel'
    ])) {
      return 'Lifestyle';
    }
    if (_containsAny(pkg + name, [
      'settings', 'store', 'android', 'apple', 'system', 'default', 'play store', 'app store', 'google', 'ios'
    ])) {
      return 'System';
    }
    return 'Other';
  }

  List<AppInfo> get _filteredApps {
    List<AppInfo> apps = _installedApps;
    if (_selectedCategory != 'All') {
      apps = apps.where((app) => _getAppCategory(app) == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      apps = apps.where((app) {
        final appName = app.name.toLowerCase();
        final packageName = app.packageName.toLowerCase();
        final query = _searchQuery.toLowerCase();
        return appName.contains(query) || packageName.contains(query);
      }).toList();
    }
    return apps;
  }

  Future<void> _onAppSelected(AppInfo app) async {
    final hasPermission = await PlatformServices.checkAccessibilityPermission();
    if (!hasPermission) {
      await _showPermissionDialog();
      return;
    }

    final isSelected = _selectedPackages.contains(app.packageName);
    setState(() {
      if (isSelected) {
        _selectedPackages.remove(app.packageName);
      } else {
        _selectedPackages.add(app.packageName);
      }
    });

    await PlatformServices.updateBlockedApps(_selectedPackages.toList());
  }

  Future<void> _showPermissionDialog() async {
    final theme = ref.read(themeProvider);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.background,
        title: Text(
          'Permission Required',
          style: TextStyle(color: theme.mainText, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'To block apps, IdleMan needs the Accessibility Service to be enabled. Please enable it in your device settings.',
          style: TextStyle(color: theme.mainText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: TextStyle(color: theme.accent)),
          ),
          ElevatedButton(
            onPressed: () async {
              await PlatformServices.requestAccessibilityPermission();
              Navigator.of(context).pop();
            },
            child: const Text('Open Settings'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.accent,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: theme.background,
      body: NeuBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with settings button
              Padding(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.appName,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: theme.mainText,
                      ),
                    ),
                    NeuIconButton(
                      icon: Icons.settings,
                      onTap: () async {
                        await Navigator.of(context).pushNamed('/settings');
                        _loadInstalledApps();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.paddingLarge),
              // ...existing code... (ServiceStatusBanner removed)
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: NeuCard(
                  child: TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: 'Search apps...',
                      hintStyle:
                          TextStyle(color: theme.mainText.withOpacity(0.87)),
                      prefixIcon: Icon(Icons.search,
                          color: theme.mainText.withOpacity(0.87)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    style: TextStyle(color: theme.mainText),
                  ),
                ),
              ),
              // Category Filter Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((cat) {
                      final selected = _selectedCategory == cat;
                        // Custom filter tab for better dark mode contrast, no tick
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedCategory = cat),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                              decoration: BoxDecoration(
                                color: selected
                                    ? (theme.isDark ? theme.accent.withOpacity(0.18) : theme.background)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: selected ? theme.accent : theme.mainText.withOpacity(0.2),
                                  width: selected ? 2 : 1,
                                ),
                              ),
                              child: Text(
                                cat,
                                style: TextStyle(
                                  color: selected
                                      ? (theme.isDark ? theme.accent : theme.mainText)
                                      : theme.mainText.withOpacity(theme.isDark ? 0.7 : 1.0),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                    }).toList(),
                  ),
                ),
              ),

              // App grid
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: theme.accent,
                        ),
                      )
                    : _filteredApps.isEmpty
                        ? Center(
                            child: Text(
                              _searchQuery.isEmpty
                                  ? 'No apps found'
                                  : 'No apps match "$_searchQuery"',
                              style: TextStyle(
                                color: theme.mainText.withOpacity(0.87),
                                fontSize: 16,
                              ),
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 0.85,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: _filteredApps.length,
                            itemBuilder: (context, index) {
                              final app = _filteredApps[index];
                              final isSelected = _selectedPackages.contains(app.packageName);
                              return GestureDetector(
                                onTap: () async {
                                  await _onAppSelected(app);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        isSelected
                                            ? 'Unblocked ${app.name}'
                                            : 'Blocked ${app.name}',
                                      ),
                                      duration: const Duration(milliseconds: 800),
                                    ),
                                  );
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? theme.accent.withOpacity(0.12)
                                        : theme.background,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: isSelected
                                          ? theme.accent
                                          : theme.mainText.withOpacity(0.08),
                                      width: 2,
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Image.memory(
                                              app.icon!,
                                              width: 56,
                                              height: 56,
                                            ),
                                            const SizedBox(height: 8),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 4),
                                              child: Text(
                                                app.name,
                                                style: TextStyle(
                                                  color: Theme.of(context).brightness == Brightness.dark
                                                      ? Colors.white
                                                      : Colors.black87,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.center,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Removed tick/checkmark for selected filter tab/app
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
