import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/app_constants.dart';
import '../../../shared/widgets/brand_logo.dart';
import '../widgets/onboarding_illustrations.dart';

class _OnboardingPageData {
  final String title;
  final String body;
  final Widget illustration;

  const _OnboardingPageData({
    required this.title,
    required this.body,
    required this.illustration,
  });
}

/// First-run intro flow: 4 swipeable pages previewing Recipes (incl. AI
/// generation/photo scan) / Plan / Shopping List. Shown once, gated by a
/// persisted flag the caller (MainShell) owns — this widget only reports
/// back via [onFinished].
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinished;

  const OnboardingScreen({super.key, required this.onFinished});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  List<_OnboardingPageData> _pages(AppLocalizations l10n) => [
        _OnboardingPageData(
          title: l10n.onboardingPage1Title,
          body: l10n.onboardingPage1Body,
          illustration: const RecipeCardIllustration(),
        ),
        _OnboardingPageData(
          title: l10n.onboardingPage2Title,
          body: l10n.onboardingPage2Body,
          illustration: const AiRecipeIllustration(),
        ),
        _OnboardingPageData(
          title: l10n.onboardingPage3Title,
          body: l10n.onboardingPage3Body,
          illustration: const WeekStripIllustration(),
        ),
        _OnboardingPageData(
          title: l10n.onboardingPage4Title,
          body: l10n.onboardingPage4Body,
          illustration: const ShoppingListIllustration(),
        ),
      ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next(int pageCount) {
    if (_page < pageCount - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 320), curve: Curves.easeOut);
    } else {
      widget.onFinished();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pages = _pages(l10n);
    final isLastPage = _page == pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 44,
              child: isLastPage
                  ? null
                  : Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: TextButton(
                          onPressed: widget.onFinished,
                          child: Text(l10n.onboardingSkip),
                        ),
                      ),
                    ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (index) => setState(() => _page = index),
                itemBuilder: (context, index) => _OnboardingPage(
                  data: pages[index],
                  showLogo: index == 0,
                ),
              ),
            ),
            _PageIndicator(count: pages.length, activeIndex: _page),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () => _next(pages.length),
                  child: Text(isLastPage ? l10n.onboardingGetStarted : l10n.onboardingNext),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingPageData data;
  final bool showLogo;

  const _OnboardingPage({required this.data, required this.showLogo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          SizedBox(
            height: 48,
            child: showLogo ? const Center(child: BrandLogo(size: 26)) : null,
          ),
          Expanded(
            flex: 4,
            child: Center(child: data.illustration),
          ),
          const SizedBox(height: 36),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: AppTextStyles.pageHeading,
          ),
          const SizedBox(height: 12),
          Text(
            data.body,
            textAlign: TextAlign.center,
            style: AppTextStyles.pageSubtitle.copyWith(fontSize: 15, height: 1.45),
          ),
          const Expanded(flex: 3, child: SizedBox()),
        ],
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final int count;
  final int activeIndex;

  const _PageIndicator({required this.count, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
