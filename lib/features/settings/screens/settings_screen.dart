import 'package:flutter/material.dart';

import '../../../services/backup_service.dart';

class SettingsScreen extends StatelessWidget {
  final VoidCallback onImportSuccess;

  const SettingsScreen({super.key, required this.onImportSuccess});

  @override
  Widget build(BuildContext context) {
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
                        'Settings',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        'MealBridge v0.3.0',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
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
                'Data & Backup',
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
                  title: const Text('Export backup'),
                  subtitle: const Text(
                    'Save all your recipes and meal plan as a JSON file',
                  ),
                  trailing: const Icon(Icons.chevron_right),
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
                  title: const Text('Import backup'),
                  subtitle: const Text(
                    'Restore your recipes and meal plan from a backup file',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final success =
                        await backupService.importBackup(context);
                    if (success) onImportSuccess();
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 18,
                    color: Color(0xFF2E7D32),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Export your data regularly to avoid losing your recipes if you change phones.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
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
                'About',
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
                  subtitle: const Text('Version 0.3.0'),
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
                  title: const Text('Storage'),
                  subtitle: const Text('All data stored locally on your device'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}