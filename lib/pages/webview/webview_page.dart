import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

/// Page affichant une URL dans une WebView intégrée (l’utilisateur reste dans l’app).
class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key, required this.url, required this.title});

  final String url;
  final String title;

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: _buildWebView(),
    );
  }

  Widget _buildWebView() {
    if (Platform.isAndroid) {
      PlatformWebViewWidgetCreationParams params =
          PlatformWebViewWidgetCreationParams(
            controller: _controller.platform,
            layoutDirection: TextDirection.ltr,
            gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
          );
      params =
          AndroidWebViewWidgetCreationParams.fromPlatformWebViewWidgetCreationParams(
            params,
            displayWithHybridComposition: true,
          );
      return WebViewWidget.fromPlatformCreationParams(params: params);
    }
    return WebViewWidget(controller: _controller);
  }
}
