import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sem_dsn/core/constants/app_font_sizes.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';
import 'package:sem_dsn/models/article_source.dart';
import 'package:url_launcher/url_launcher.dart';

/// Section affichée en fin d’article : liste des sources (nom + URL en colonne).
class ArticleSourcesSection extends StatelessWidget {
  const ArticleSourcesSection({super.key, required this.sources});

  final List<ArticleSource> sources;

  @override
  Widget build(BuildContext context) {
    if (sources.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Source(s)',
            style: TextStyle(
              color: AppColors.sectionTitle,
              fontSize: AppFontSizes.sectionTitle,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...sources.map(
            (source) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: source.name.isEmpty
                  ? const SizedBox.shrink()
                  : source.url.isNotEmpty
                      ? _buildLink(context, source.name, source.url)
                      : Text(
                          source.name,
                          style: const TextStyle(
                            color: AppColors.newsTitle,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLink(BuildContext context, String name, String url) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: Colors.blue,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.underline,
        ),
        text: name,
        recognizer: TapGestureRecognizer()..onTap = () => _openUrl(url),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
