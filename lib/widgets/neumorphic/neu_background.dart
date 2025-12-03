import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme_provider.dart';
import 'dart:math' as math;

/// Neumorphic Background with ambient floating blobs
class NeuBackground extends ConsumerStatefulWidget {
  final Widget child;

  const NeuBackground({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<NeuBackground> createState() => _NeuBackgroundState();
}

class _NeuBackgroundState extends ConsumerState<NeuBackground>
    with TickerProviderStateMixin {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: theme.background,
      child: widget.child,
    );
  }
}
