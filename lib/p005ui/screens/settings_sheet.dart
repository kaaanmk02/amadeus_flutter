import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({required this.viewModel, super.key});
  final dynamic viewModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgDeep,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _SectionTitle(title: 'Settings'),
          _Field(label: 'Language', value: 'Turkish', onTap: () {}),
          _Field(label: 'Theme', value: 'Dark', onTap: () {}),
          _Field(label: 'Resolution', value: '1080p', onTap: () {}),
          _Field(label: 'Volume', value: '100%', onTap: () {}),
          _Field(label: 'Quality', value: 'High', onTap: () {}),
          _Field(label: 'Fullscreen', value: 'Off', onTap: () {}),
          _Field(label: 'Auto-Start', value: 'Off', onTap: () {}),
          _Field(label: 'Update', value: 'Auto', onTap: () {}),
          _Field(label: 'Reset', value: 'None', onTap: () {}),
          const _SectionTitle(title: 'Account'),
          _Field(label: 'Name', value: 'Guest', onTap: () {}),
          _Field(label: 'Email', value: 'guest@example.com', onTap: () {}),
          _Field(label: 'Password', value: '••••••••', onTap: () {}),
          _Field(label: 'Avatar', value: 'Default', onTap: () {}),
          _Field(label: 'Status', value: 'Online', onTap: () {}),
          _Field(label: 'Notifications', value: 'On', onTap: () {}),
          _Field(label: 'Privacy', value: 'Public', onTap: () {}),
          _Field(label: 'Blocked', value: '0', onTap: () {}),
          _Field(label: 'Muted', value: '0', onTap: () {}),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 4, left: 4, right: 4),
    child: Text(
      title,
      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10, letterSpacing: 1.2),
    ),
  );
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value, required this.onTap});
  final String label;
  final String value;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          Text(value, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        ],
      ),
    ),
  );
}
