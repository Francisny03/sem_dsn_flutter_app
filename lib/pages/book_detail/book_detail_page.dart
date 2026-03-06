import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sem_dsn/core/constants/app_border_radius.dart';
import 'package:sem_dsn/core/constants/app_strings.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';
import 'package:sem_dsn/models/book.dart';
import 'package:sem_dsn/pages/book_detail/pdf_viewer_page.dart';
import 'package:sem_dsn/widget/image_from_path.dart';

/// Hauteur du hero (cover + zone floutée avec infos).
const double _kExpandedHeight = 400;
const double _kToolbarHeight = 56;

/// Page détail d’un livre : cover floutée + cover nette, titre/date/auteur sur le flou, résumé, bouton « Lire le livre » sticky (PDF en in-app sur iOS).
class BookDetailPage extends StatefulWidget {
  const BookDetailPage({super.key, required this.book});

  final Book book;

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showTitleInAppBar = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    final showTitle = offset > _kExpandedHeight - _kToolbarHeight;
    if (showTitle != _showTitleInAppBar) {
      setState(() => _showTitleInAppBar = showTitle);
    }
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  expandedHeight: _kExpandedHeight,
                  pinned: true,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new),
                    onPressed: () => Navigator.of(context).pop(),
                    color: AppColors.whiteTextColor,
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.share_outlined),
                      onPressed: () => _share(context),
                      color: AppColors.whiteTextColor,
                    ),
                  ],
                  title: _showTitleInAppBar
                      ? Text(
                          book.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.whiteTextColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : const SizedBox.shrink(),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        ImageFromPath(path: book.coverUrl, fit: BoxFit.cover),
                        Positioned.fill(
                          child: ClipRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                              child: Container(color: Colors.black26),
                            ),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 0),
                            child: ClipRRect(
                              borderRadius: AppBorderRadius.r12,
                              child: ImageFromPath(
                                path: book.coverUrl,
                                width: 140,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 24,
                          right: 24,
                          bottom: 24,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                book.name,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.whiteTextColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (book.displayDate.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  '${AppStrings.bibBookDetailDateLabel} : ${book.displayDate}',
                                  style: TextStyle(
                                    color: AppColors.whiteTextColor.withValues(
                                      alpha: 0.95,
                                    ),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 4),
                              Text(
                                '${AppStrings.bibBookDetailAuthorLabel} : ${book.author ?? '–'}',
                                style: TextStyle(
                                  color: AppColors.whiteTextColor.withValues(
                                    alpha: 0.95,
                                  ),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.only(top: 0),
                    decoration: const BoxDecoration(
                      color: AppColors.bg,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if ((book.description ?? '').trim().isNotEmpty)
                            Text(
                              book.description!.trim(),
                              style: const TextStyle(
                                color: AppColors.newsTitle,
                                fontSize: 15,
                                height: 1.5,
                              ),
                            )
                          else
                            const Text(
                              'Aucun résumé disponible.',
                              style: TextStyle(
                                color: AppColors.grayTextColor,
                                fontSize: 15,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (book.fileUrl.isNotEmpty) _buildStickyButton(context),
        ],
      ),
    );
  }

  Widget _buildStickyButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(50, 12, 50, 5),
      decoration: const BoxDecoration(
        color: AppColors.bg,
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black12,
        //     blurRadius: 8,
        //     offset: Offset(0, -2),
        //   ),
        // ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 50,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () =>
                _openPdf(context, widget.book.fileUrl, widget.book.name),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: AppColors.whiteTextColor,
              shape: RoundedRectangleBorder(
                borderRadius: AppBorderRadius.rtotal,
              ),
            ),
            child: Text(
              AppStrings.bibBookDetailReadButton,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  void _share(BuildContext context) {
    if (widget.book.fileUrl.isNotEmpty) {
      Share.share(widget.book.fileUrl, subject: widget.book.name);
    } else {
      Share.share(widget.book.name);
    }
  }

  static void _openPdf(BuildContext context, String url, String title) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PdfViewerPage(pdfUrl: url, title: title),
      ),
    );
  }
}
