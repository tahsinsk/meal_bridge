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

  const _ShopEntry({
    required this.name,
    required this.initials,
    required this.color,
    required this.textColor,
    required this.url,
  });
}

// Store names are brand names and are never translated. Colors are rough
// approximations of each brand's palette, not scraped assets — paired with
// a plain initial(s) badge, not a logo, to stay clear of trademarked
// graphics.
const _shops = [
  _ShopEntry(
    name: 'Albert Heijn',
    initials: 'AH',
    color: Color(0xFF0F6FBE),
    textColor: Colors.white,
    url: 'https://www.ah.nl',
  ),
  _ShopEntry(
    name: 'Jumbo',
    initials: 'J',
    color: Color(0xFFFFD200),
    textColor: Color(0xFF1A1C19),
    url: 'https://www.jumbo.com',
  ),
  _ShopEntry(
    name: 'Picnic',
    initials: 'P',
    color: Color(0xFFE53950),
    textColor: Colors.white,
    url: 'https://picnic.app',
  ),
  _ShopEntry(
    name: 'Flink',
    initials: 'F',
    color: Color(0xFF6A3DE8),
    textColor: Colors.white,
    url: 'https://goflink.com',
  ),
];

/// Opens the "Shop at" bottom sheet — same rounded-top/drag-handle style as
/// the sort/category pickers. A 2x2 grid of store badges (brand color +
/// initials only, no logos); tapping one launches that store's site and
/// closes the sheet. Purely a shortcut — there is no cart-filling.
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

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _openAndClose(context, shop.url),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
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
