import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sem_dsn/core/constants/app_font_sizes.dart';
import 'package:sem_dsn/core/constants/app_strings.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';
import 'package:sem_dsn/core/constants/bibliography_data.dart';
import 'package:sem_dsn/pages/book_detail/book_detail_page.dart';
import 'package:sem_dsn/providers/books_provider.dart';
import 'package:sem_dsn/widget/bibliography_livre_tile.dart';
import 'package:sem_dsn/widget/bibliography_revue_tile.dart';

/// Page Bibliographie : titre, section Livres (API ou fallback statique), section Revues de Presse.
class BibliographiePage extends StatelessWidget {
  const BibliographiePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BooksProvider>(
      builder: (context, booksProvider, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          booksProvider.loadIfNeeded();
        });
        final books = booksProvider.books;
        final loading = booksProvider.loading;
        final useApiBooks = books.isNotEmpty;

        return CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
            if (loading && !useApiBooks)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (useApiBooks) {
                      final book = books[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: BibliographyLivreTile(
                          imagePath: book.coverUrl,
                          title: book.name,
                          year: book.year,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => BookDetailPage(book: book),
                              ),
                            );
                          },
                        ),
                      );
                    }
                    final book = bibliographyBooks[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: BibliographyLivreTile(
                        imagePath: book.image,
                        title: book.title,
                        description: book.description,
                        year: book.year,
                        onTap: () {
                          // TODO: ouvrir détail livre
                        },
                      ),
                    );
                  },
                  childCount: useApiBooks
                      ? books.length
                      : bibliographyBooks.length,
                ),
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
                    onTap: () {
                      // TODO: ouvrir détail revue
                    },
                  ),
                );
              }, childCount: bibliographyReviews.length),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        );
      },
    );
  }
}
