import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/constants/app_constants.dart';

/// Neumorphic Toggle Switch
class NeuToggle extends ConsumerStatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final double width;
  final double height;

  const NeuToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.width = 60.0,
    this.height = 30.0,
  });

  @override
  ConsumerState<NeuToggle> createState() => _NeuToggleState();
}

class _NeuToggleState extends ConsumerState<NeuToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: AppConstants.animationMedium),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    if (widget.value) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(NeuToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    return GestureDetector(
      onTap: () => widget.onChanged(!widget.value),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: theme.background,
          borderRadius: BorderRadius.circular(widget.height / 2),
          boxShadow: theme.getPressedInShadows(
            distance: AppConstants.shadowDistanceSmall,
            blur: AppConstants.shadowBlurSmall,
          ),
        ),
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Stack(
              children: [
                Positioned(
                  left: _animation.value * (widget.width - widget.height),
                  child: Container(
                    width: widget.height,
                    height: widget.height,
                    decoration: BoxDecoration(
                      color: theme.background,
                      shape: BoxShape.circle,
                      boxShadow: theme.getPopOutShadows(
                        distance: AppConstants.shadowDistanceSmall,
                        blur: AppConstants.shadowBlurSmall,
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: widget.height * 0.4,
                        height: widget.height * 0.4,
                        decoration: BoxDecoration(
                          color: theme.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
