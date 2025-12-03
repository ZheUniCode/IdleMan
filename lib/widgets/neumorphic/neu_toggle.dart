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
  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Center(
        child: GestureDetector(
          onTap: () => widget.onChanged(!widget.value),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
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
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.ease,
                      left: widget.value
                          ? widget.width - widget.height
                          : 0,
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
