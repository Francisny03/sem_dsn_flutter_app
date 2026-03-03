import 'package:flutter/material.dart';
import 'package:sem_dsn/core/constants/app_strings.dart';

/// Titre affiché dans l'app (SEM DSN).
class AppTitle extends StatelessWidget {
  const AppTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      AppStrings.appTitle,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
    );
  }
}
