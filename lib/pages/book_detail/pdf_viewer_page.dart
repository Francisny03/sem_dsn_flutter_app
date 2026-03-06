import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

/// Page de lecture PDF dans l’app (Syncfusion).
class PdfViewerPage extends StatelessWidget {
  const PdfViewerPage({super.key, required this.pdfUrl, this.title});

  final String pdfUrl;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          title ?? 'PDF',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SfPdfViewer.network(
        pdfUrl,
        onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
          // Optionnel : afficher un message d’erreur (snackbar ou body de remplacement).
        },
      ),
    );
  }
}
