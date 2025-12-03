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
  late List<AnimationController> _controllers;
  late List<Animation<Offset>> _animations;
  final int _blobCount = 5;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      _blobCount,
      (index) => AnimationController(
        duration: Duration(seconds: 15 + index * 3),
        vsync: this,
      )..repeat(reverse: true),
    );

    _animations = _controllers.map((controller) {
      final random = math.Random(controller.hashCode);
      return Tween<Offset>(
        begin: Offset(
          random.nextDouble() * 2 - 1,
          random.nextDouble() * 2 - 1,
        ),
        end: Offset(
          random.nextDouble() * 2 - 1,
          random.nextDouble() * 2 - 1,
        ),
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ));
    }).toList();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final size = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: theme.background,
      child: Stack(
        children: [
          // Animated blobs
          ...List.generate(_blobCount, (index) {
            return AnimatedBuilder(
              animation: _animations[index],
              builder: (context, child) {
                // Spread blobs evenly by assigning each blob a unique base position
                final angle = (index / _blobCount) * 2 * math.pi;
                final baseX = 0.5 + 0.35 * math.cos(angle);
                final baseY = 0.5 + 0.35 * math.sin(angle);
                final jitterX = _animations[index].value.dx * 0.15;
                final jitterY = _animations[index].value.dy * 0.15;
                return Positioned(
                  left: size.width * (baseX + jitterX),
                  top: size.height * (baseY + jitterY),
                  child: child!,
                );
              },
              child: Container(
                width: 200 + (index * 50).toDouble(),
                height: 200 + (index * 50).toDouble(),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      theme.background.withOpacity(0.0),
                      (theme.isDark ? theme.shadowLight : theme.shadowDark)
                          .withOpacity(0.03),
                    ],
                  ),
                ),
              ),
            );
          }),
          // Main content
          widget.child,
        ],
      ),
    );
  }
}
