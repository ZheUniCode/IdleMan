import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/overlays/bureaucrat_overlay.dart';
import 'features/overlays/chase_overlay.dart';
import 'features/overlays/typing_overlay.dart';
import 'core/theme/theme_provider.dart';

@pragma('vm:entry-point')
void overlayMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  runApp(
    const ProviderScope(
      child: OverlayApp(),
    ),
  );
}

class OverlayApp extends ConsumerWidget {
  const OverlayApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return FutureBuilder<String>(
      future: _getOverlayType(),
      builder: (context, snapshot) {
        final overlayType = snapshot.data ?? 'bureaucrat';
        Widget overlayWidget;
        if (overlayType == 'random') {
          final overlays = [
            const BureaucratOverlay(),
            const ChaseOverlay(),
            const TypingOverlay(),
          ];
          overlayWidget = overlays[(DateTime.now().millisecondsSinceEpoch % overlays.length)];
        } else if (overlayType == 'bureaucrat') {
          overlayWidget = const BureaucratOverlay();
        } else if (overlayType == 'chase') {
          overlayWidget = const ChaseOverlay();
        } else if (overlayType == 'typing') {
          overlayWidget = const TypingOverlay();
        } else {
          overlayWidget = const BureaucratOverlay();
        }

        return MaterialApp(
          title: 'IdleMan Overlay',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: theme.accent,
            scaffoldBackgroundColor: theme.background,
            colorScheme: ColorScheme.fromSeed(
              seedColor: theme.accent,
              brightness: theme.isDark ? Brightness.dark : Brightness.light,
            ),
          ),
          home: overlayWidget,
        );
      },
    );
  }

  Future<String> _getOverlayType() async {
    final prefs = await Hive.openBox('settings');
    // Try Hive first, fallback to SharedPreferences
    String? overlayType = prefs.get('overlay_type');
    if (overlayType == null) {
      try {
        final sp = await SharedPreferences.getInstance();
        overlayType = sp.getString('overlay_type');
      } catch (_) {}
    }
    return overlayType ?? 'bureaucrat';
  }
}
