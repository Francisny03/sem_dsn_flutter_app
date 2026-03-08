import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sem_dsn/services/articles_api.dart';
import 'package:sem_dsn/services/read_articles_service.dart';
import 'package:sem_dsn/services/selection_service.dart';
import 'package:sem_dsn/widget/article_detail_args.dart';
import 'package:sem_dsn/widget/article_detail_hero_layout.dart';
import 'package:sem_dsn/widget/article_detail_presse_layout.dart';

export 'package:sem_dsn/widget/article_detail_args.dart';

/// Page détail : délègue au layout Hero ou Presse/Réalisation.
/// Gère le scroll (titre dans l'app bar), le partage et le pull-to-refresh (recharge depuis l'API si articleId présent).
class ArticleDetailPage extends StatefulWidget {
  const ArticleDetailPage({super.key, required this.args});

  final ArticleDetailArgs args;

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showTitleInAppBar = false;
  bool _hasMarkedAsRead = false;
  late ArticleDetailArgs _args;
  static const double _imageHeight = 260;

  SelectedArticle get _currentArticle => SelectedArticle(
    title: _args.title,
    date: _args.date,
    imagePath: _args.imagePath,
  );

  @override
  void initState() {
    super.initState();
    _args = widget.args;
    _scrollController.addListener(_onScroll);
  }

  Future<void> _onRefresh() async {
    final id = _args.articleId;
    if (id == null || !mounted) return;
    try {
      final article = await fetchArticleById(id);
      if (!mounted) return;
      setState(() {
        _args = ArticleDetailArgs.fromArticle(
          article,
          _args.tag,
          heroTagOverride: _args.heroTagOverride,
          isHeroOrFeatured: _args.isHeroOrFeatured,
        );
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final topPadding = MediaQuery.paddingOf(context).top;
    final threshold =
        _args.titleInAppBarScrollOffset ??
        (_imageHeight + topPadding) - kToolbarHeight - 20;
    final shouldShow = _scrollController.offset > threshold;
    if (shouldShow != _showTitleInAppBar) {
      setState(() => _showTitleInAppBar = shouldShow);
    }
  }

  void _openOtherNewsArticle(ArticleDetailArgs args) {
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => ArticleDetailPage(args: args)),
    );
  }

  void _shareArticle(BuildContext buttonContext) {
    final text = '${_args.title}\n\n${_args.body}';
    final box = buttonContext.findRenderObject() as RenderBox?;
    Share.share(
      text,
      subject: _args.title,
      sharePositionOrigin: box != null
          ? box.localToGlobal(Offset.zero) & box.size
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectionService = context.watch<SelectionService>();
    if (!_hasMarkedAsRead) {
      _hasMarkedAsRead = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<ReadArticlesService>().markAsRead(_currentArticle);
        }
      });
    }
    final isStarSelected = selectionService.contains(_currentArticle);
    final layout = _args.isHeroOrFeatured
        ? ArticleDetailHeroLayout(
            args: _args,
            scrollController: _scrollController,
            showTitleInAppBar: _showTitleInAppBar,
            isStarSelected: isStarSelected,
            onStarTap: () => selectionService.toggle(_currentArticle),
            onShare: _shareArticle,
            onOtherNewsArticleTap: _openOtherNewsArticle,
          )
        : ArticleDetailPresseLayout(
            args: _args,
            scrollController: _scrollController,
            showTitleInAppBar: _showTitleInAppBar,
            isStarSelected: isStarSelected,
            onStarTap: () => selectionService.toggle(_currentArticle),
            onShare: _shareArticle,
            onOtherNewsArticleTap: _openOtherNewsArticle,
          );
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: layout,
    );
  }
}
