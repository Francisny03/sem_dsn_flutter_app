import 'package:flutter/material.dart';
import 'package:sem_dsn/core/constants/app_font_sizes.dart';
import 'package:sem_dsn/core/constants/app_strings.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';
import 'package:sem_dsn/core/constants/bibliography_data.dart';
import 'package:sem_dsn/widget/bibliography_livre_tile.dart';
import 'package:sem_dsn/widget/bibliography_revue_tile.dart';

/// Page Bibliographie : titre, section Livres, section Revues de Presse.
class BibliographiePage extends StatelessWidget {
  const BibliographiePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Text(
              AppStrings.navBibliographie,
              style: const TextStyle(
                color: AppColors.navBottomSelectItem,
                fontSize: AppFontSizes.menuTitle,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              AppStrings.bibSectionLivres,
              style: const TextStyle(
                color: AppColors.sectionTitle,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final book = bibliographyBooks[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: BibliographyLivreTile(
                imagePath: book.image,
                title: book.title,
                description: book.description,
                year: book.year,
                onLirePlus: () {
                  // TODO: ouvrir détail livre
                },
              ),
            );
          }, childCount: bibliographyBooks.length),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              AppStrings.bibSectionRevuesPresse,
              style: const TextStyle(
                color: AppColors.sectionTitle,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final review = bibliographyReviews[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: BibliographyRevueTile(
                imagePath: review.image,
                title: review.title,
                description: review.description,
                date: review.date,
                onLirePlus: () {
                  // TODO: ouvrir détail revue
                },
              ),
            );
          }, childCount: bibliographyReviews.length),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}
