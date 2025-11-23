import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/overlays/bureaucrat_overlay.dart';
import 'features/overlays/chase_overlay.dart';
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
      initialRoute: '/overlay/bureaucrat',
      routes: {
        '/overlay/bureaucrat': (context) => const BureaucratOverlay(),
        '/overlay/chase': (context) => const ChaseOverlay(),
      },
    );
  }
}
