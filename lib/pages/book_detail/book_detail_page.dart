import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sem_dsn/core/constants/app_assets.dart';
import 'package:sem_dsn/core/constants/app_border_radius.dart';
import 'package:sem_dsn/core/constants/app_strings.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';
import 'package:sem_dsn/models/book.dart';
import 'package:sem_dsn/pages/book_detail/pdf_viewer_page.dart';
import 'package:sem_dsn/providers/books_provider.dart';
import 'package:sem_dsn/widget/image_from_path.dart';
import 'package:url_launcher/url_launcher.dart';

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
  late Book _book;

  @override
  void initState() {
    super.initState();
    _book = widget.book;
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

  Future<void> _onRefresh() async {
    await context.read<BooksProvider>().load();
    if (!mounted) return;
    final updated = context.read<BooksProvider>().getBookById(widget.book.id);
    if (updated != null) setState(() => _book = updated);
  }

  @override
  Widget build(BuildContext context) {
    final book = _book;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
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
                          ImageFromPath(
                            path: AppAssets.imageOrDefault(book.coverUrl),
                            fit: BoxFit.cover,
                          ),
                          Positioned.fill(
                            child: ClipRect(
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 24,
                                  sigmaY: 24,
                                ),
                                child: Container(color: Colors.black26),
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Spacer(),
                              ClipRRect(
                                borderRadius: AppBorderRadius.r12,
                                child: ImageFromPath(
                                  path: AppAssets.imageOrDefault(book.coverUrl),
                                  width: 140,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  24,
                                  0,
                                  24,
                                  24,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      book.name,
                                      textAlign: TextAlign.center,
                                      maxLines: 3,
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
                                        textAlign: TextAlign.center,
                                        '${AppStrings.bibBookDetailDateLabel} : ${book.displayDate}',
                                        style: TextStyle(
                                          color: AppColors.whiteTextColor
                                              .withValues(alpha: 0.95),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 4),
                                    Text(
                                      textAlign: TextAlign.center,
                                      '${AppStrings.bibBookDetailAuthorLabel} : ${book.author ?? '–'}',
                                      style: TextStyle(
                                        color: AppColors.whiteTextColor
                                            .withValues(alpha: 0.95),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
                            if (_showAchetezSur(book)) ...[
                              const SizedBox(height: 20),
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    color: AppColors.newsTitle,
                                    fontSize: 15,
                                    height: 1.5,
                                  ),
                                  children: [
                                    TextSpan(
                                      text:
                                          '${AppStrings.bibBookDetailAchetezSur} : ',
                                    ),
                                    TextSpan(
                                      text:
                                          (book.vendorName ?? '').trim().isEmpty
                                          ? _displayPurchaseUrl(
                                              book.purchaseUrl!,
                                            )
                                          : (book.vendorName ?? '').trim(),
                                      style: const TextStyle(
                                        color: AppColors.primaryColor,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () =>
                                            _openPurchaseUrl(book.purchaseUrl!),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_book.fileUrl.isNotEmpty) _buildStickyButton(context),
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
            onPressed: () => _openPdf(context, _book.fileUrl, _book.name),
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
    if (_book.fileUrl.isNotEmpty) {
      Share.share(_book.fileUrl, subject: _book.name);
    } else {
      Share.share(_book.name);
    }
  }

  static void _openPdf(BuildContext context, String url, String title) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PdfViewerPage(pdfUrl: url, title: title),
      ),
    );
  }

  /// "Achetez sur" s'affiche si et seulement si l'URL existe et qu'il y a un vendor_name.
  bool _showAchetezSur(Book book) {
    final url = (book.purchaseUrl ?? '').trim();
    final vendor = (book.vendorName ?? '').trim();
    return url.isNotEmpty && vendor.isNotEmpty;
  }

  String _displayPurchaseUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.isNotEmpty ? uri.host : url;
    } catch (_) {
      return url;
    }
  }

  Future<void> _openPurchaseUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
