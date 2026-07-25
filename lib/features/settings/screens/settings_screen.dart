import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../services/backup_service.dart';
import '../../../shared/app_constants.dart';
import '../../../shared/widgets/option_picker_sheet.dart';

class SettingsScreen extends StatelessWidget {
  final VoidCallback onImportSuccess;
  final VoidCallback onResetOnboarding;
  final String localeCode;
  final ValueChanged<String> onLocaleCodeChanged;

  const SettingsScreen({
    super.key,
    required this.onImportSuccess,
    required this.onResetOnboarding,
    required this.localeCode,
    required this.onLocaleCodeChanged,
  });

  // Language names are shown in their own language regardless of the
  // active app locale (so a Turkish speaker in an English UI can still
  // recognize "Türkçe") — only "System default" is a real UI string.
  String _languageLabel(String code, AppLocalizations l10n) {
    switch (code) {
      case 'en':
        return 'English';
      case 'tr':
        return 'Türkçe';
      case 'nl':
        return 'Nederlands';
      default:
        return l10n.settingsLanguageSystemDefault;
    }
  }

  Future<void> _openLanguagePicker(BuildContext context, AppLocalizations l10n) async {
    final result = await showOptionPickerSheet<String>(
      context,
      title: l10n.settingsLanguageSection,
      options: const ['system', 'en', 'tr', 'nl'],
      selected: localeCode,
      labelBuilder: (code) => _languageLabel(code, l10n),
    );
    if (result != null && result != localeCode) {
      onLocaleCodeChanged(result);
    }
  }

  void _showInfoDialog(BuildContext context, String title, String description) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(description),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.recipeFilterDone),
          ),
        ],
      ),
    );
  }

  // Keeps each row down to icon + title; the fuller description moves into
  // a short dialog behind a small (i) button instead of always-visible
  // subtitle text, so the list reads as lighter and less text-heavy.
  Widget _rowTrailing(
    BuildContext context, {
    required String infoTitle,
    required String infoText,
    bool showChevron = true,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.info_outline, size: 20),
          color: Colors.grey[400],
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          visualDensity: VisualDensity.compact,
          onPressed: () => _showInfoDialog(context, infoTitle, infoText),
        ),
        if (showChevron) const Icon(Icons.chevron_right),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final backupService = BackupService();

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Başlık kartı
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.settings_outlined,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.settingsTitle,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        l10n.settingsVersionLabel(AppInfo.version),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Language
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.language_outlined,
                  size: 18,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                l10n.settingsLanguageSection,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),

          const SizedBox(height: 8),

          Card(
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.translate_outlined,
                  color: Color(0xFF2E7D32),
                ),
              ),
              title: Text(l10n.settingsLanguageSection),
              subtitle: Text(_languageLabel(localeCode, l10n)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openLanguagePicker(context, l10n),
            ),
          ),

          const SizedBox(height: 20),

          // Backup bölümü
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.backup_outlined,
                  size: 18,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                l10n.settingsDataBackupSection,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),

          const SizedBox(height: 8),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.upload_outlined,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  title: Text(l10n.settingsExportTitle),
                  trailing: _rowTrailing(
                    context,
                    infoTitle: l10n.settingsExportTitle,
                    infoText: '${l10n.settingsExportSubtitle}\n\n${l10n.settingsBackupInfo}',
                  ),
                  onTap: () => backupService.exportBackup(context),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.download_outlined,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                  title: Text(l10n.settingsImportTitle),
                  trailing: _rowTrailing(
                    context,
                    infoTitle: l10n.settingsImportTitle,
                    infoText: l10n.settingsImportSubtitle,
                  ),
                  onTap: () async {
                    final success =
                        await backupService.importBackup(context);
                    if (success) onImportSuccess();
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Hakkında
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.info_outlined,
                  size: 18,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                l10n.settingsAboutSection,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),

          const SizedBox(height: 8),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.restaurant_menu_outlined,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  title: const Text('MealBridge'),
                  subtitle: Text(l10n.settingsAppVersionSubtitle(AppInfo.version)),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.storage_outlined,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  title: Text(l10n.settingsStorageTitle),
                  trailing: _rowTrailing(
                    context,
                    infoTitle: l10n.settingsStorageTitle,
                    infoText: l10n.settingsStorageSubtitle,
                    showChevron: false,
                  ),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.replay_outlined,
                      color: Color(0xFFEF6C00),
                    ),
                  ),
                  title: Text(l10n.settingsResetOnboardingTitle),
                  trailing: _rowTrailing(
                    context,
                    infoTitle: l10n.settingsResetOnboardingTitle,
                    infoText: l10n.settingsResetOnboardingSubtitle,
                  ),
                  onTap: onResetOnboarding,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
