import 'package:flutter/material.dart';
import 'package:sem_dsn/core/constants/app_strings.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';

/// Affiche un message "Vous n'êtes pas connecté..." avec un bouton Actualiser au centre.
/// Utilisé après le placeholder quand le chargement a échoué (ex. pas d'internet).
class NoConnectionView extends StatelessWidget {
  const NoConnectionView({
    super.key,
    required this.onRetry,
    this.padding,
    this.minHeight,
  });

  final VoidCallback onRetry;
  final EdgeInsetsGeometry? padding;
  final double? minHeight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: minHeight ?? 160),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.noConnectionMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.grayTextColor,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: onRetry,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: AppColors.filterSelectedTextColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                ),
                child: const Text(AppStrings.noConnectionButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
