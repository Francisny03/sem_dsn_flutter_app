import 'package:flutter/material.dart';
import 'package:sem_dsn/core/constants/app_strings.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';
import 'package:sem_dsn/core/constants/app_border_radius.dart';
import 'package:sem_dsn/core/constants/phototheque_data.dart';
import 'package:sem_dsn/pages/phototheque/phototheque_category_page.dart';

/// Page de recherche dans la Photothèque : champ de recherche + grille de catégories/résultats.
class PhotothequeSearchPage extends StatefulWidget {
  const PhotothequeSearchPage({super.key});

  @override
  State<PhotothequeSearchPage> createState() => _PhotothequeSearchPageState();
}

class _PhotothequeSearchPageState extends State<PhotothequeSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  List<({String image, String title, int count})> get _filteredCategories {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return photothequeCategories;
    return photothequeCategories
        .where((c) => c.title.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 22),
          color: AppColors.blackIcon,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          AppStrings.photothequeSearchTitle,
          style: const TextStyle(
            color: AppColors.onSurfaceLight,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: AppStrings.photothequeSearchHint,
                  hintStyle: const TextStyle(
                    color: AppColors.grayTextColor,
                    fontSize: 15,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.grayTextColor,
                    size: 22,
                  ),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          color: AppColors.grayTextColor,
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
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
                    vertical: 14,
                  ),
                ),
              ),
            ),
            Expanded(
              child: _filteredCategories.isEmpty
                  ? Center(
                      child: Text(
                        AppStrings.photothequeNoResults,
                        style: const TextStyle(
                          color: AppColors.grayTextColor,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.85,
                          ),
                      itemCount: _filteredCategories.length,
                      itemBuilder: (context, index) {
                        final cat = _filteredCategories[index];
                        return _PhotothequeCategoryCard(
                          imagePath: cat.image,
                          title: cat.title,
                          imageCount: cat.count,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => PhotothequeCategoryPage(
                                  title: cat.title,
                                  imagePaths: photothequeCategoryImagePaths,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotothequeCategoryCard extends StatelessWidget {
  const _PhotothequeCategoryCard({
    required this.imagePath,
    required this.title,
    required this.imageCount,
    required this.onTap,
  });

  final String imagePath;
  final String title;
  final int imageCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorderRadius.r12,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: AppBorderRadius.r12,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.filterUnselected,
                    child: const Icon(Icons.image_not_supported),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.newsTitle,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              '$imageCount ${AppStrings.photothequeImagesCount}',
              style: const TextStyle(color: AppColors.newsDate, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
