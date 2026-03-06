import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:sem_dsn/core/constants/app_border_radius.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';

/// Carte de lecture avec bord arrondi en haut (topLeft, topRight).
/// Utilisée sous l'image dans la page détail article (Hero et Presse/Réalisation).
class ArticleContentCard extends StatelessWidget {
  const ArticleContentCard({
    super.key,
    required this.title,
    required this.date,
    required this.tag,
    required this.body,
    this.bodyHtml,
    this.showTagTitleDate = true,
    this.heroCapDrawnAbove = false,
  });

  final String title;
  final String date;
  final String tag;
  final String body;

  /// Si défini, affiché à la place de [body] (HTML rendu).
  final String? bodyHtml;

  /// false = Hero/À la une : afficher uniquement le corps (sans tag, titre, date).
  final bool showTagTitleDate;

  /// true = la calotte arrondie est déjà dessinée au-dessus (dans l'image Hero) : pas de bord arrondi ni ombre en haut.
  final bool heroCapDrawnAbove;

  static const double _paddingTopHero = 28;
  static const double _paddingTopDefault = 28;

  @override
  Widget build(BuildContext context) {
    final paddingTop = showTagTitleDate ? _paddingTopDefault : _paddingTopHero;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, paddingTop, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: heroCapDrawnAbove
            ? BorderRadius.zero
            : const BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
        boxShadow: heroCapDrawnAbove
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showTagTitleDate) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.heroTag,
                borderRadius: AppBorderRadius.rtotal,
              ),
              child: Text(
                tag,
                style: const TextStyle(
                  color: AppColors.whiteTextColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.newsTitle,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (date.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                date,
                style: const TextStyle(color: AppColors.newsDate, fontSize: 14),
              ),
            ],
            const SizedBox(height: 20),
          ],
          if (bodyHtml != null && bodyHtml!.isNotEmpty)
            Html(
              data: bodyHtml!.replaceAll('&nbsp;', ' '),
              shrinkWrap: true,
              style: {
                'body': Style(
                  margin: Margins.zero,
                  padding: HtmlPaddings.zero,
                  color: AppColors.newsTitle,
                  fontSize: FontSize(15),
                  lineHeight: const LineHeight(1.5),
                ),
                'p': Style(margin: Margins.only(bottom: 12)),
                'strong': Style(fontWeight: FontWeight.w700),
              },
            )
          else
            Text(
              body,
              style: const TextStyle(
                color: AppColors.newsTitle,
                fontSize: 15,
                height: 1.5,
              ),
            ),
        ],
      ),
    );
  }
}
