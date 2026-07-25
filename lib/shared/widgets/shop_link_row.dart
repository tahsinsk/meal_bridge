import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';

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

/// Small "Shop at" quick-access row — a row of store badges (brand color +
/// initials only, no logos) that just open the store's website. Purely a
/// shortcut; there is no cart-filling or ordering integration.
class ShopLinksRow extends StatelessWidget {
  const ShopLinksRow({super.key});

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.shoppingShopAtCaption,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[600]),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                for (final shop in _shops) ...[
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => _open(shop.url),
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
                                style: TextStyle(
                                  color: shop.textColor,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            shop.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (shop != _shops.last) const SizedBox(width: 8),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
