import 'package:flutter/material.dart';
import 'package:sem_dsn/core/constants/app_assets.dart';
import 'package:sem_dsn/core/constants/app_strings.dart';
import 'package:sem_dsn/core/constants/bibliography_data.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';
import 'package:sem_dsn/widget/bibliography_livre_tile.dart';
import 'package:sem_dsn/widget/bibliography_revue_tile.dart';

/// Page de recherche Bibliographie : filtre uniquement les éléments de la bibliographie
/// (livres + revues) par titre, description et date.
class BibliographieSearchPage extends StatefulWidget {
  const BibliographieSearchPage({super.key});

  @override
  State<BibliographieSearchPage> createState() =>
      _BibliographieSearchPageState();
}

class _BibliographieSearchPageState extends State<BibliographieSearchPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  static bool _bookMatches(BibliographyBook book, String query) {
    final q = query.toLowerCase();
    final searchable = '${book.title} ${book.description} ${book.year}'
        .toLowerCase();
    return searchable.contains(q);
  }

  static bool _reviewMatches(BibliographyReview review, String query) {
    final q = query.toLowerCase();
    final searchable = '${review.title} ${review.description} ${review.date}'
        .toLowerCase();
    return searchable.contains(q);
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim();
    final hasQuery = query.isNotEmpty;
    final matchingBooks = hasQuery
        ? bibliographyBooks.where((b) => _bookMatches(b, query)).toList()
        : <BibliographyBook>[];
    final matchingReviews = hasQuery
        ? bibliographyReviews.where((r) => _reviewMatches(r, query)).toList()
        : <BibliographyReview>[];

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 22),
          color: AppColors.blackIcon,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          AppStrings.bibSearchTitle,
          style: const TextStyle(
            color: AppColors.onSurfaceLight,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: AppStrings.bibSearchHint,
                hintStyle: const TextStyle(
                  color: AppColors.grayTextColor,
                  fontSize: 15,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.grayTextColor,
                  size: 22,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        color: AppColors.grayTextColor,
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.filterUnselected,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                if (hasQuery) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      AppStrings.articleSearchResults,
                      style: const TextStyle(
                        color: AppColors.sectionTitle,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      matchingBooks.isEmpty && matchingReviews.isEmpty
                          ? AppStrings.articleSearchNoResults
                          : '${matchingBooks.length + matchingReviews.length} résultat(s)',
                      style: const TextStyle(
                        color: AppColors.grayTextColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (matchingBooks.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        AppStrings.bibSectionLivres,
                        style: const TextStyle(
                          color: AppColors.sectionTitle,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...matchingBooks.map(
                      (book) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: BibliographyLivreTile(
                          imagePath: AppAssets.imageOrDefault(book.image),
                          title: book.title,
                          description: book.description,
                          year: book.year,
                          onLirePlus: () {},
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (matchingReviews.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        AppStrings.bibSectionRevuesPresse,
                        style: const TextStyle(
                          color: AppColors.sectionTitle,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...matchingReviews.map(
                      (review) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: BibliographyRevueTile(
                          imagePath: AppAssets.imageOrDefault(review.image),
                          title: review.title,
                          description: review.description,
                          date: review.date,
                          onLirePlus: () {},
                        ),
                      ),
                    ),
                  ],
                ] else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Saisissez un mot pour rechercher dans les livres et revues (titre, description, date).',
                      style: const TextStyle(
                        color: AppColors.grayTextColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
