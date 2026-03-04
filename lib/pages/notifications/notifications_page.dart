import 'package:flutter/material.dart';
import 'package:sem_dsn/core/constants/app_font_sizes.dart';
import 'package:sem_dsn/core/constants/app_strings.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';

/// Une notification : texte "Nouvel article dans [section]", titre de l'article, heure.
class NotificationItem {
  const NotificationItem({
    required this.sectionName,
    required this.articleTitle,
    required this.time,
    required this.dateGroup,
  });

  /// Nom de la section (ex. Campagne, Actualités) affiché en gras.
  final String sectionName;
  final String articleTitle;

  /// Heure affichée à droite (ex. "10h30", "14h00").
  final String time;

  /// Groupe de date : "today" | "yesterday" | "YYYY-MM-DD" ou libellé affiché.
  final String dateGroup;
}

/// Données de démo pour les notifications.
List<NotificationItem> _demoNotifications = [
  NotificationItem(
    sectionName: 'Campagne',
    articleTitle: "Début de la campagne présidentielle 2026",
    time: "09h15",
    dateGroup: "today",
  ),
  NotificationItem(
    sectionName: 'Actualités',
    articleTitle:
        "Denis Sassou-Nguesso annonce sa candidature à l'élection présidentielle",
    time: "08h42",
    dateGroup: "today",
  ),
  NotificationItem(
    sectionName: 'Réalisations',
    articleTitle: "Les tours jumelles de Mpila",
    time: "18h20",
    dateGroup: "yesterday",
  ),
  NotificationItem(
    sectionName: 'Discours',
    articleTitle:
        "Interview du Président de la République, accordée à l'occasion de l'inauguration du complexe scolaire",
    time: "16h00",
    dateGroup: "yesterday",
  ),
  NotificationItem(
    sectionName: 'Campagne',
    articleTitle: "6ème congrès ordinaire du Parti congolais du travail (PCT)",
    time: "11h00",
    dateGroup: "28 Février 2026",
  ),
];

String _dateGroupLabel(String dateGroup) {
  switch (dateGroup) {
    case "today":
      return AppStrings.notificationsToday;
    case "yesterday":
      return AppStrings.notificationsYesterday;
    default:
      return dateGroup;
  }
}

/// Page Notifications : titre rouge gras italique, sections Aujourd'hui / Hier / date, notifs texte + heure.
/// Au scroll, le titre passe dans l'AppBar (titleSpacing: 0).
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showTitleInAppBar = false;

  static const double _titleScrollThreshold = 40;

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
    final show = _scrollController.offset > _titleScrollThreshold;
    if (show != _showTitleInAppBar) {
      setState(() => _showTitleInAppBar = show);
    }
  }

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<NotificationItem>>{};
    for (final n in _demoNotifications) {
      grouped.putIfAbsent(n.dateGroup, () => []).add(n);
    }
    const order = ["today", "yesterday"];
    final orderedKeys = grouped.keys.toList()
      ..sort((a, b) {
        final ia = order.indexOf(a);
        final ib = order.indexOf(b);
        if (ia != -1 && ib != -1) return ia.compareTo(ib);
        if (ia != -1) return -1;
        if (ib != -1) return 1;
        return 0;
      });

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
        title: _showTitleInAppBar
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  AppStrings.notificationsTitle,
                  style: const TextStyle(
                    color: AppColors.onSurfaceLight,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            : null,
        centerTitle: true,
      ),
      body: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Text(
                AppStrings.notificationsTitle,
                style: const TextStyle(
                  color: AppColors.navBottomSelectItem,
                  fontSize: AppFontSizes.menuTitle,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
          ...orderedKeys.map((dateKey) {
            final items = grouped[dateKey]!;
            return SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      _dateGroupLabel(dateKey),
                      style: const TextStyle(
                        color: AppColors.sectionTitle,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...items.map(
                    (n) => _NotificationTile(
                      sectionName: n.sectionName,
                      articleTitle: n.articleTitle,
                      time: n.time,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          }),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.sectionName,
    required this.articleTitle,
    required this.time,
  });

  final String sectionName;
  final String articleTitle;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: AppColors.newsTitle,
                      fontSize: 14,
                      height: 1.35,
                    ),
                    children: [
                      TextSpan(
                        text: '${AppStrings.notificationsNewArticleIn} ',
                        style: const TextStyle(fontWeight: FontWeight.normal),
                      ),
                      TextSpan(
                        text: sectionName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  articleTitle,
                  style: const TextStyle(
                    color: AppColors.grayTextColor,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              time,
              style: const TextStyle(color: AppColors.newsDate, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
