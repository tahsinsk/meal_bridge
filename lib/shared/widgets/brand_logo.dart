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
        // Text widgets reserve extra vertical space above/below the visible
        // glyphs based on the font's line-height metrics — with
        // crossAxisAlignment.center, the Row centers that whole box
        // (glyphs + invisible padding), not the glyphs themselves, so the
        // wordmark reads as sitting high next to the icon. Stripping the
        // ascent/descent padding via textHeightBehavior is the "proper"
        // fix; the Transform.translate nudge on top of it is a pragmatic
        // correction for Quicksand's remaining optical offset.
        Transform.translate(
          offset: Offset(0, size * 0.12),
          child: RichText(
            textHeightBehavior: const TextHeightBehavior(
              applyHeightToFirstAscent: false,
              applyHeightToLastDescent: false,
            ),
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
