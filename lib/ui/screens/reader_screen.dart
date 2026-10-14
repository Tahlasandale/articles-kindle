import 'package:articles_kindle/data/db/database.dart';
import 'package:articles_kindle/l10n/generated/app_localizations.dart';
import 'package:articles_kindle/state/providers.dart';
import 'package:articles_kindle/ui/screens/to_read_screen.dart';
import 'package:articles_kindle/ui/theme/tokens.dart';
import 'package:articles_kindle/ui/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({super.key, required this.articleId});

  final int articleId;

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  WebViewController? _controller;
  int? _loadedArticleId;
  Brightness? _loadedBrightness;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    final brightness = Theme.of(context).brightness;

    return FutureBuilder<ArticleRow?>(
      future: ref.watch(articleServiceProvider).findById(widget.articleId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            _controller == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.readerTitle)),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final article = snapshot.data;
        final title = article?.title ?? l10n.readerTitle;
        final html = article?.contentHtml;

        if (article == null || html == null || html.trim().isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: Text(title),
              actions: const [
                ThemeButton(),
                SizedBox(width: Eink.space2),
              ],
            ),
            body: EmptyState(
              title: l10n.statusFailed,
              body: l10n.readerNoContent,
            ),
          );
        }

        if (_controller == null ||
            _loadedArticleId != widget.articleId ||
            _loadedBrightness != brightness) {
          _controller = WebViewController()
            ..setBackgroundColor(
              brightness == Brightness.dark
                  ? Eink.darkBackground
                  : Eink.background,
            )
            ..setJavaScriptMode(JavaScriptMode.unrestricted);

          final styledHtml = _wrapHtml(
            title: article.title ?? '',
            contentHtml: html,
            isDark: brightness == Brightness.dark,
          );
          _controller!.loadHtmlString(styledHtml);
          _loadedArticleId = widget.articleId;
          _loadedBrightness = brightness;
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            actions: const [
              ThemeButton(),
              SizedBox(width: Eink.space2),
            ],
          ),
          body: WebViewWidget(controller: _controller!),
        );
      },
    );
  }

  String _wrapHtml({
    required String title,
    required String contentHtml,
    required bool isDark,
  }) {
    final bg = isDark ? '#000000' : '#FFFFFF';
    final ink = isDark ? '#F2F2F2' : '#000000';
    final secondary = isDark ? '#9A9A9A' : '#555555';
    final border = isDark ? '#F2F2F2' : '#000000';

    return '''<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    body {
      font-family: 'Libron', Georgia, serif;
      background-color: $bg;
      color: $ink;
      margin: 16px;
      line-height: 1.6;
      font-size: 17px;
    }
    h1, h2, h3, h4 {
      font-family: 'Libron', Georgia, serif;
      font-weight: 700;
      line-height: 1.25;
      color: $ink;
    }
    h1 {
      font-size: 22px;
      border-bottom: 2px solid $border;
      padding-bottom: 8px;
      margin-bottom: 16px;
    }
    p {
      margin-top: 0;
      margin-bottom: 1em;
    }
    img {
      max-width: 100%;
      height: auto;
      filter: grayscale(100%);
      border: 1px solid $border;
      display: block;
      margin: 16px auto;
    }
    a {
      color: $ink;
      text-decoration: underline;
    }
    blockquote {
      border-left: 2px solid $border;
      margin-left: 0;
      padding-left: 12px;
      color: $secondary;
      font-style: italic;
    }
    pre, code {
      font-family: monospace;
      font-size: 14px;
      background-color: transparent;
      border: 1px solid $border;
      padding: 2px 4px;
    }
    pre {
      padding: 8px;
      overflow-x: auto;
    }
  </style>
</head>
<body>
  ${title.isNotEmpty ? '<h1>${_escape(title)}</h1>' : ''}
  $contentHtml
</body>
</html>''';
  }

  String _escape(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;');
  }
}
