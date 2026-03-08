import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sem_dsn/core/constants/app_assets.dart';
import 'package:sem_dsn/core/constants/app_font_sizes.dart';
import 'package:sem_dsn/core/constants/app_strings.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';
import 'package:sem_dsn/core/constants/bibliography_data.dart';
import 'package:sem_dsn/models/book.dart';
import 'package:sem_dsn/pages/book_detail/book_detail_page.dart';
import 'package:sem_dsn/providers/books_provider.dart';
import 'package:sem_dsn/widget/bibliography_livre_tile.dart';
import 'package:sem_dsn/widget/bibliography_revue_tile.dart';

/// Hauteur de la barre d’onglets sticky.
const double _kTabBarHeight = 48;

/// Page Bibliographie : titre, onglets Livres | Revues de Presse (sticky), contenu selon l’onglet.
class BibliographiePage extends StatefulWidget {
  const BibliographiePage({super.key});

  @override
  State<BibliographiePage> createState() => _BibliographiePageState();
}

class _BibliographiePageState extends State<BibliographiePage> {
  // --- TABS (caché) : réactiver pour afficher Livres | Revues de Presse ---
  // with SingleTickerProviderStateMixin {
  // late TabController _tabController;
  // @override
  // void initState() {
  //   super.initState();
  //   _tabController = TabController(length: 2, vsync: this);
  // }
  // @override
  // void dispose() {
  //   _tabController.dispose();
  //   super.dispose();
  // }

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

        return RefreshIndicator(
          onRefresh: () => booksProvider.load(),
          child: NestedScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
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
            // --- TABS (caché) ---
            // SliverPersistentHeader(
            //   pinned: true,
            //   delegate: _StickyTabBarDelegate(
            //     child: _BibliographyTabBar(controller: _tabController),
            //   ),
            // ),
          ],
          body: _LivresTabContent(
            loading: loading,
            useApiBooks: useApiBooks,
            books: books,
          ),
          // --- TABS (caché) : TabBarView avec Livres + Revues ---
          // body: TabBarView(
          //   controller: _tabController,
          //   physics: const BouncingScrollPhysics(),
          //   children: [
          //     _LivresTabContent(loading: loading, useApiBooks: useApiBooks, books: books),
          //     const _RevuesTabContent(),
          //   ],
          // ),
          ),
        );
      },
    );
  }
}

/// Contenu de l’onglet Livres (scroll vertical).
class _LivresTabContent extends StatelessWidget {
  const _LivresTabContent({
    required this.loading,
    required this.useApiBooks,
    required this.books,
  });

  final bool loading;
  final bool useApiBooks;
  final List<Book> books;

  @override
  Widget build(BuildContext context) {
    if (loading && !useApiBooks) {
      return const Center(child: CircularProgressIndicator());
    }
    final count = useApiBooks ? books.length : bibliographyBooks.length;
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
      itemCount: count,
      itemBuilder: (context, index) {
        if (useApiBooks) {
          final book = books[index];
          return Padding(
            padding: const EdgeInsets.only(top: 0),
            child: BibliographyLivreTile(
              imagePath: AppAssets.imageOrDefault(book.coverUrl),
              title: book.name,
              description: book.description ?? '',
              year: book.displayDate,
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
          padding: const EdgeInsets.only(top: 16),
          child: BibliographyLivreTile(
            imagePath: AppAssets.imageOrDefault(book.image),
            title: book.title,
            description: book.description,
            year: book.year,
            onTap: () {
              // TODO: ouvrir détail livre
            },
          ),
        );
      },
    );
  }
}

/// Contenu de l’onglet Revues de Presse (scroll vertical). Conservé pour réactiver les tabs.
// ignore: unused_element
class _RevuesTabContent extends StatelessWidget {
  const _RevuesTabContent();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 30),
      itemCount: bibliographyReviews.length,
      itemBuilder: (context, index) {
        final review = bibliographyReviews[index];
        return Padding(
          padding: const EdgeInsets.only(top: 0),
          child: BibliographyRevueTile(
            imagePath: AppAssets.imageOrDefault(review.image),
            title: review.title,
            description: review.description,
            date: review.date,
            onTap: () {
              // TODO: ouvrir détail revue
            },
          ),
        );
      },
    );
  }
}

/// Barre d’onglets Livres | Revues de Presse (style titre + soulignement pour l’actif). Conservé pour réactiver les tabs.
// ignore: unused_element
class _BibliographyTabBar extends StatelessWidget {
  const _BibliographyTabBar({required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final index = controller.index;
        return Container(
          height: _kTabBarHeight,
          color: AppColors.bg,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _TabLabel(
                  label: AppStrings.bibSectionLivres,
                  isSelected: index == 0,
                  onTap: () => controller.animateTo(0),
                ),
              ),
              Expanded(
                child: _TabLabel(
                  label: AppStrings.bibSectionRevuesPresse,
                  isSelected: index == 1,
                  onTap: () => controller.animateTo(1),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TabLabel extends StatelessWidget {
  const _TabLabel({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? AppColors.navBottomSelectItem
                    : AppColors.newsTitle,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            if (isSelected)
              Container(
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.navBottomSelectItem,
                  // borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ignore: unused_element
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  _StickyTabBarDelegate({required this.child});

  final Widget child;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  double get maxExtent => _kTabBarHeight;

  @override
  double get minExtent => _kTabBarHeight;

  @override
  bool shouldRebuild(covariant _StickyTabBarDelegate oldDelegate) {
    return child != oldDelegate.child;
  }
}
