import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../app_constants.dart';

class _ShopEntry {
  final String name;
  final String initials;
  final Color color;
  final Color textColor;
  final String url;
  final String logoAsset;

  const _ShopEntry({
    required this.name,
    required this.initials,
    required this.color,
    required this.textColor,
    required this.url,
    required this.logoAsset,
  });
}

// TODO(legal): logoAsset files under assets/images/stores/ are each store's
// real trademarked logo (fetched from Google's public favicon service,
// since Clearbit's logo API isn't reachable from this environment), bundled
// here for personal/local testing only. They are NOT cleared for public
// distribution — before any App Store/Play Store submission, either get
// explicit permission to use each mark, or replace this whole badge with a
// non-logo alternative (e.g. the plain color+initials badge every _ShopBadge
// already falls back to below, or a text-only wordmark).
//
// Store names are brand names and are never translated. Colors are rough
// approximations of each brand's palette, used only as the fallback badge
// background if a logo asset fails to load.
const _shops = [
  _ShopEntry(
    name: 'Albert Heijn',
    initials: 'AH',
    color: Color(0xFF0F6FBE),
    textColor: Colors.white,
    url: 'https://www.ah.nl',
    logoAsset: 'assets/images/stores/ah.png',
  ),
  _ShopEntry(
    name: 'Jumbo',
    initials: 'J',
    color: Color(0xFFFFD200),
    textColor: Color(0xFF1A1C19),
    url: 'https://www.jumbo.com',
    logoAsset: 'assets/images/stores/jumbo.png',
  ),
  _ShopEntry(
    name: 'Picnic',
    initials: 'P',
    color: Color(0xFFE53950),
    textColor: Colors.white,
    url: 'https://picnic.app',
    logoAsset: 'assets/images/stores/picnic.jpg',
  ),
  _ShopEntry(
    name: 'Flink',
    initials: 'F',
    color: Color(0xFF6A3DE8),
    textColor: Colors.white,
    url: 'https://goflink.com',
    logoAsset: 'assets/images/stores/flink.png',
  ),
];

/// Opens the "Shop at" bottom sheet — same rounded-top/drag-handle style as
/// the sort/category pickers. A 2x2 grid of store badges (each store's real
/// logo, falling back to a plain color+initials badge if that logo asset
/// fails to load — see the TODO(legal) note above); tapping one launches
/// that store's site and closes the sheet. Purely a shortcut — there is no
/// cart-filling.
Future<void> showShopLinksSheet(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.large)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(l10n.shoppingShopAtCaption, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(child: _ShopBadge(shop: _shops[0])),
                    const SizedBox(width: 14),
                    Expanded(child: _ShopBadge(shop: _shops[1])),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(child: _ShopBadge(shop: _shops[2])),
                    const SizedBox(width: 14),
                    Expanded(child: _ShopBadge(shop: _shops[3])),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Future<void> _openAndClose(BuildContext context, String url) async {
  Navigator.of(context).pop();
  await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}

class _ShopBadge extends StatelessWidget {
  final _ShopEntry shop;

  const _ShopBadge({required this.shop});

  // Plain color+initials badge — used as-is when a logo asset is missing or
  // fails to decode, so one bad/absent download never breaks the row for
  // the other three stores.
  Widget _initialsFallback() {
    return Container(
      decoration: BoxDecoration(
        color: shop.color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          shop.initials,
          style: TextStyle(color: shop.textColor, fontWeight: FontWeight.w800, fontSize: 15),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _openAndClose(context, shop.url),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 48,
              height: 48,
              child: Image.asset(
                shop.logoAsset,
                fit: BoxFit.contain,
                // Light backdrop + breathing room behind the logo — most of
                // these favicons don't carry a transparent background, so
                // this keeps the badge readable/consistent regardless.
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  return DecoratedBox(
                    decoration: const BoxDecoration(color: Colors.white),
                    child: Padding(padding: const EdgeInsets.all(8), child: child),
                  );
                },
                // One missing/corrupt logo falls back to the original plain
                // color+initials badge, full-bleed — never breaks the row
                // for the other three stores.
                errorBuilder: (context, error, stackTrace) => _initialsFallback(),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            shop.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF1A1C19)),
          ),
        ],
      ),
    );
  }
}
