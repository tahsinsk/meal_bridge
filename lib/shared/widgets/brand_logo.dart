import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_constants.dart';

/// MealBridge wordmark: the real logo mark (fork + bridge + knife) next to
/// the two-tone "meal" (dark green) + "bridge" (mid green) text set in a
/// rounded Google Font. The [size] parameter scales the mark and text
/// together so this can be reused for the app bar, onboarding, splash, etc.
class BrandLogo extends StatelessWidget {
  final double size;

  const BrandLogo({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    final fontSize = size * 0.7;
    final markHeight = fontSize * 1.9;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/logo_mark_transparent.png',
          height: markHeight,
          fit: BoxFit.contain,
        ),
        SizedBox(width: size * 0.06),
        Padding(
          padding: EdgeInsets.only(top: size * 0.08),
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.quicksand(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                height: 1,
              ),
              children: const [
                TextSpan(text: 'meal', style: TextStyle(color: AppColors.primaryDark)),
                TextSpan(text: 'bridge', style: TextStyle(color: AppColors.accentMid)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
