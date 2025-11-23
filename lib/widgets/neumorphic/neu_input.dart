import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/constants/app_constants.dart';

/// Neumorphic Input Field with pressed-in effect
class NeuInput extends ConsumerWidget {
  final TextEditingController? controller;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int? maxLines;
  final ValueChanged<String>? onChanged;

  const NeuInput({
    super.key,
    this.controller,
    this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return Container(
      decoration: BoxDecoration(
        color: theme.background,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusInput),
        boxShadow: theme.getPressedInShadows(
          distance: AppConstants.shadowDistanceSmall,
          blur: AppConstants.shadowBlurSmall,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        maxLines: maxLines,
        onChanged: onChanged,
        style: TextStyle(
          color: theme.mainText,
          fontSize: 16.0,
          // fontFamily removed
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: theme.mainText.withOpacity(0.5),
            fontSize: 16.0,
            // fontFamily removed
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(AppConstants.paddingMedium),
        ),
      ),
    );
  }
}
