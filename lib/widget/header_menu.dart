import 'package:flutter/material.dart';
import 'package:sem_dsn/core/constants/app_strings.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';
import 'package:sem_dsn/pages/splashscreen.dart';
import 'package:sem_dsn/pages/webview/webview_page.dart';

/// Affiche le menu (Langues [caché] + Politique/CGU/Contact + Déconnexion) au clic sur les 3 points du header.
void showHeaderMenu(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => const _HeaderMenuContent(),
  );
}

class _HeaderMenuContent extends StatelessWidget {
  const _HeaderMenuContent();

  /// À remettre à true pour réafficher le bloc Langues plus tard.
  static const bool _showLanguages = false;

  /// Français actif ; Anglais, Lingala, Kituba affichés en grisé (désactivés).
  static const List<({String flag, String label, bool enabled})> _languages = [
    (flag: '🇫🇷', label: AppStrings.languageFrench, enabled: true),
    (flag: '🇬🇧', label: AppStrings.languageEnglish, enabled: false),
    (flag: '🇨🇬', label: AppStrings.languageLingala, enabled: false),
    (flag: '🇨🇬', label: AppStrings.languageKituba, enabled: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(
              AppStrings.menuTitle,
              style: const TextStyle(
                color: AppColors.sectionTitle,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (_showLanguages) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Text(
                AppStrings.menuLanguages,
                style: const TextStyle(
                  color: AppColors.grayTextColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ..._languages.map(
              (e) => ListTile(
                enabled: e.enabled,
                leading: Opacity(
                  opacity: e.enabled ? 1 : 0.5,
                  child: CircleAvatar(
                    backgroundColor: AppColors.filterUnselected,
                    radius: 20,
                    child: Text(e.flag, style: const TextStyle(fontSize: 22)),
                  ),
                ),
                title: Text(
                  e.label,
                  style: TextStyle(
                    color: e.enabled
                        ? AppColors.newsTitle
                        : AppColors.grayTextColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: e.enabled ? () => Navigator.of(context).pop() : null,
              ),
            ),
          ],
          _MenuLinkTile(
            icon: Icons.privacy_tip_outlined,
            label: AppStrings.menuPrivacy,
            url: 'https://appdsn.reveurs.pro/pages/privacy',
          ),
          _MenuLinkTile(
            icon: Icons.description_outlined,
            label: AppStrings.menuCGU,
            url: 'https://appdsn.reveurs.pro/pages/cgu',
          ),
          _MenuLinkTile(
            icon: Icons.contact_mail_outlined,
            label: AppStrings.menuContact,
            url: 'https://appdsn.reveurs.pro/pages/contact',
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute<void>(
                      builder: (_) => const SplashScreen(),
                    ),
                    (route) => false,
                  );
                },
                icon: const Icon(
                  Icons.logout,
                  size: 20,
                  color: AppColors.navBottomSelectItem,
                ),
                label: Text(
                  AppStrings.logout,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.navBottomSelectItem,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.navBottomSelectItem,
                  side: const BorderSide(color: AppColors.navBottomSelectItem),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuLinkTile extends StatelessWidget {
  const _MenuLinkTile({
    required this.icon,
    required this.label,
    required this.url,
  });

  final IconData icon;
  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.newsTitle, size: 24),
      title: Text(
        label,
        style: const TextStyle(
          color: AppColors.newsTitle,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        Navigator.of(context).pop();
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => WebViewPage(url: url, title: label),
          ),
        );
      },
    );
  }
}
