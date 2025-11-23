import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/neumorphic/neu_card.dart';
import '../../widgets/neumorphic/neu_button.dart';
import '../../core/services/platform_services.dart';

// Isolate function for loading apps
List<Map<String, dynamic>> _parseAppsInIsolate(List<dynamic> rawApps) {
  return rawApps.cast<Map<String, dynamic>>();
}

/// Screen for selecting which apps to block with categorized layout
class BlockedAppsScreen extends ConsumerStatefulWidget {
  const BlockedAppsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BlockedAppsScreen> createState() => _BlockedAppsScreenState();
}

class _BlockedAppsScreenState extends ConsumerState<BlockedAppsScreen> {
  List<Map<String, dynamic>> _installedApps = [];
  Set<String> _selectedPackages = {};
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadInstalledApps();
  }

  Future<void> _loadInstalledApps() async {
    setState(() => _isLoading = true);
    try {
      final apps = await PlatformServices.getInstalledApps();
      // Process in isolate to avoid blocking UI
      final parsed = await compute(_parseAppsInIsolate, apps);
      
      // 🛡️ Filter out our own app and critical system apps to prevent accidental self-blocking
      final criticalApps = {
        'com.idleman.app',                      // Our app
        'com.android.settings',                 // Settings
        'com.android.phone',                    // Phone dialer
        'com.android.dialer',                   // Alternative dialer
        'com.google.android.dialer',            // Google Phone
        'com.android.messaging',                // Messaging
        'com.google.android.apps.messaging',    // Google Messages
        'com.android.mms',                      // MMS
        'com.android.contacts',                 // Contacts
        'android',                              // System UI
        'com.android.systemui',                 // System UI
        'com.google.android.apps.nexuslauncher', // Launcher
        'com.android.launcher3',                // Default launcher
      };
      
      final filtered = parsed.where((app) {
        final packageName = app['packageName'] as String;
        return !criticalApps.contains(packageName);
      }).toList();
      
      if (mounted) {
        setState(() {
          _installedApps = filtered;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading apps: $e')),
        );
      }
    }
  }

  Future<void> _saveBlockedApps() async {
    try {
      await PlatformServices.updateBlockedApps(_selectedPackages.toList());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Blocked apps updated!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e')),
        );
      }
    }
  }

  String _getAppCategory(String packageName) {
    final pkg = packageName.toLowerCase();
    if (pkg.contains('facebook') || pkg.contains('instagram') || pkg.contains('twitter') || 
        pkg.contains('tiktok') || pkg.contains('snapchat') || pkg.contains('reddit')) {
      return 'Social';
    } else if (pkg.contains('youtube') || pkg.contains('netflix') || pkg.contains('spotify') ||
               pkg.contains('music') || pkg.contains('video')) {
      return 'Entertainment';
    } else if (pkg.contains('chrome') || pkg.contains('browser') || pkg.contains('firefox') ||
               pkg.contains('edge') || pkg.contains('opera')) {
      return 'Browsers';
    } else if (pkg.contains('game') || pkg.contains('play.') || pkg.contains('unity')) {
      return 'Games';
    } else if (pkg.contains('whatsapp') || pkg.contains('telegram') || pkg.contains('messaging') ||
               pkg.contains('messages') || pkg.contains('sms')) {
      return 'Messaging';
    } else if (pkg.contains('gmail') || pkg.contains('email') || pkg.contains('mail')) {
      return 'Email';
    } else if (pkg.contains('docs') || pkg.contains('drive') || pkg.contains('office') ||
               pkg.contains('sheets') || pkg.contains('slides')) {
      return 'Productivity';
    } else {
      return 'Other';
    }
  }

  Map<String, List<Map<String, dynamic>>> get _categorizedApps {
    final Map<String, List<Map<String, dynamic>>> categories = {};
    for (final app in _installedApps) {
      final category = _getAppCategory(app['packageName'] as String);
      categories.putIfAbsent(category, () => []);
      categories[category]!.add(app);
    }
    return categories;
  }

  List<Map<String, dynamic>> get _filteredApps {
    List<Map<String, dynamic>> apps = _installedApps;
    
    // Filter by category
    if (_selectedCategory != null) {
      apps = apps.where((app) => _getAppCategory(app['packageName'] as String) == _selectedCategory).toList();
    }
    
    // Filter by search
    if (_searchQuery.isNotEmpty) {
      apps = apps.where((app) {
        final appName = (app['appName'] as String).toLowerCase();
        final packageName = (app['packageName'] as String).toLowerCase();
        final query = _searchQuery.toLowerCase();
        return appName.contains(query) || packageName.contains(query);
      }).toList();
    }
    
    return apps;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    
    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.mainText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Select Apps to Block',
          style: TextStyle(
            color: theme.mainText,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _selectedPackages.isEmpty ? null : _saveBlockedApps,
            child: Text(
              'Save',
              style: TextStyle(
                color: _selectedPackages.isEmpty ? theme.mainText.withOpacity(0.6) : theme.accent,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: NeuCard(
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search apps...',
                  hintStyle: TextStyle(color: theme.mainText.withOpacity(0.6)),
                  prefixIcon: Icon(Icons.search, color: theme.mainText.withOpacity(0.6)),
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
          
          // Category chips
          if (_searchQuery.isEmpty)
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _buildCategoryChip('All', null, theme),
                  ..._categorizedApps.keys.map((category) => 
                    _buildCategoryChip(category, category, theme),
                  ),
                ],
              ),
            ),
          
          // Quick select buttons
              Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: NeuButton(
                    onTap: () {
                      setState(() {
                        _selectedPackages.addAll(
                          _filteredApps.map((app) => app['packageName'] as String),
                        );
                      });
                    },
                    child: const Text('Select All', textAlign: TextAlign.center),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: NeuButton(
                    onTap: _selectedPackages.isEmpty ? null : () {
                      setState(() => _selectedPackages.clear());
                    },
                    child: const Text('Clear All', textAlign: TextAlign.center),
                  ),
                ),
              ],
            ),
          ),          // Selected count
          if (_selectedPackages.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                '${_selectedPackages.length} app${_selectedPackages.length == 1 ? '' : 's'} selected',
                style: TextStyle(
                  color: theme.accent,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
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
                            color: theme.mainText.withOpacity(0.6),
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
                          final packageName = app['packageName'] as String;
                          final appName = app['appName'] as String;
                          final isSelected = _selectedPackages.contains(packageName);
                          
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedPackages.remove(packageName);
                                } else {
                                  _selectedPackages.add(packageName);
                                }
                              });
                            },
                            child: NeuCard(
                              child: Stack(
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: theme.background,
                                          borderRadius: BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: theme.shadowLight,
                                              offset: const Offset(-2, -2),
                                              blurRadius: 4,
                                            ),
                                            BoxShadow(
                                              color: theme.shadowDark,
                                              offset: const Offset(2, 2),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          _getAppIcon(packageName),
                                          color: theme.accent,
                                          size: 32,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                        child: Text(
                                          appName,
                                          style: TextStyle(
                                            color: theme.mainText,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: isSelected ? theme.accent : theme.background.withOpacity(0.5),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected ? theme.accent : theme.mainText.withOpacity(0.3),
                                          width: 2,
                                        ),
                                      ),
                                      child: isSelected
                                          ? const Icon(
                                              Icons.check,
                                              size: 16,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, String? category, dynamic theme) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: () => setState(() => _selectedCategory = category),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: theme.background,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: theme.shadowDark,
                      offset: const Offset(2, 2),
                      blurRadius: 4,
                    ),
                    BoxShadow(
                      color: theme.shadowLight,
                      offset: const Offset(-2, -2),
                      blurRadius: 4,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: theme.shadowLight,
                      offset: const Offset(-2, -2),
                      blurRadius: 4,
                    ),
                    BoxShadow(
                      color: theme.shadowDark,
                      offset: const Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? theme.accent : theme.mainText,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  IconData _getAppIcon(String packageName) {
    // Map common app packages to appropriate icons
    if (packageName.contains('chrome') || packageName.contains('browser')) {
      return Icons.language;
    } else if (packageName.contains('facebook')) {
      return Icons.facebook;
    } else if (packageName.contains('instagram')) {
      return Icons.camera_alt;
    } else if (packageName.contains('twitter') || packageName.contains('x.')) {
      return Icons.chat_bubble_outline;
    } else if (packageName.contains('youtube')) {
      return Icons.play_circle_outline;
    } else if (packageName.contains('tiktok')) {
      return Icons.music_note;
    } else if (packageName.contains('reddit')) {
      return Icons.forum;
    } else if (packageName.contains('snapchat')) {
      return Icons.photo_camera;
    } else if (packageName.contains('whatsapp') || packageName.contains('telegram')) {
      return Icons.message;
    } else if (packageName.contains('email') || packageName.contains('gmail')) {
      return Icons.email;
    } else if (packageName.contains('game')) {
      return Icons.sports_esports;
    } else if (packageName.contains('music') || packageName.contains('spotify')) {
      return Icons.music_note;
    } else if (packageName.contains('maps')) {
      return Icons.map;
    } else if (packageName.contains('settings')) {
      return Icons.settings;
    } else if (packageName.contains('camera')) {
      return Icons.camera;
    } else if (packageName.contains('gallery') || packageName.contains('photos')) {
      return Icons.photo_library;
    } else if (packageName.contains('clock')) {
      return Icons.access_time;
    } else if (packageName.contains('calculator')) {
      return Icons.calculate;
    } else if (packageName.contains('store') || packageName.contains('play')) {
      return Icons.shopping_bag;
    } else {
      return Icons.apps;
    }
  }
}
