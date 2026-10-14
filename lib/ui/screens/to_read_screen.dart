import 'package:articles_kindle/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/article_service.dart';
import '../../data/db/database.dart';
import '../../data/db/tables.dart';
import '../../state/providers.dart';
import '../theme/tokens.dart';
import '../widgets/article_card.dart';
import '../widgets/empty_state.dart';

class ToReadScreen extends ConsumerStatefulWidget {
  const ToReadScreen({super.key});

  @override
  ConsumerState<ToReadScreen> createState() => _ToReadScreenState();
}

class _ToReadScreenState extends ConsumerState<ToReadScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    final articles = ref.watch(articlesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tabToRead),
        actions: const [
          _ThemeButton(),
          SizedBox(width: Eink.space2),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddSheet,
        tooltip: l10n.toReadAddUrl,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(Eink.space3),
            child: TextField(
              onChanged: (value) => setState(() => _query = value.trim()),
              decoration: InputDecoration(
                hintText: l10n.toReadSearchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() => _query = ''),
                      ),
              ),
            ),
          ),
          Expanded(
            child: articles.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) =>
                  EmptyState(title: l10n.statusFailed, body: '$error'),
              data: (rows) {
                final filtered = _filter(rows);
                if (filtered.isEmpty) {
                  return _query.isEmpty
                      ? EmptyState(
                          title: l10n.toReadEmptyTitle,
                          body: l10n.toReadEmptyBody,
                          action: FilledButton(
                            onPressed: _openAddSheet,
                            child: Text(l10n.toReadAddUrl),
                          ),
                        )
                      : EmptyState(
                          title: l10n.tabToRead,
                          body: l10n.toReadSearchEmpty,
                        );
                }
                return _ArticleList(articles: filtered);
              },
            ),
          ),
        ],
      ),
    );
  }

  List<ArticleRow> _filter(List<ArticleRow> rows) {
    if (_query.isEmpty) return rows;
    final needle = _query.toLowerCase();
    return rows
        .where(
          (a) =>
              (a.title ?? '').toLowerCase().contains(needle) ||
              a.url.toLowerCase().contains(needle) ||
              (a.siteName ?? '').toLowerCase().contains(needle),
        )
        .toList();
  }

  Future<void> _openAddSheet() async {
    final choice = await showModalBottomSheet<_AddChoice>(
      context: context,
      showDragHandle: false,
      builder: (context) {
        final l10n = L10n.of(context)!;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.link),
                title: Text(l10n.toReadAddUrl),
                onTap: () => Navigator.of(context).pop(_AddChoice.url),
              ),
              ListTile(
                leading: const Icon(Icons.travel_explore),
                title: Text(l10n.toReadAddSite),
                onTap: () => Navigator.of(context).pop(_AddChoice.site),
              ),
              const SizedBox(height: Eink.space2),
            ],
          ),
        );
      },
    );

    if (!mounted || choice == null) return;

    switch (choice) {
      case _AddChoice.url:
        await _showAddUrlDialog();
      case _AddChoice.site:
        await context.push('/site');
    }
  }

  Future<void> _showAddUrlDialog() async {
    final controller = TextEditingController();
    final l10n = L10n.of(context)!;

    final url = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.addUrlTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.url,
          inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
          decoration: InputDecoration(hintText: l10n.addUrlHint),
          onSubmitted: (value) => Navigator.of(context).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final data = await Clipboard.getData('text/plain');
              if (data?.text != null) controller.text = data!.text!.trim();
            },
            child: Text(l10n.addUrlPaste),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: Text(l10n.addUrlAdd),
          ),
        ],
      ),
    );

    controller.dispose();
    if (!mounted || url == null || url.trim().isEmpty) return;
    await _add(url);
  }

  Future<void> _add(String url) async {
    final service = ref.read(articleServiceProvider);
    final result = await service.addUrl(url, origin: ArticleOrigin.manual);
    if (!mounted) return;

    final l10n = L10n.of(context)!;
    final message = switch (result) {
      ArticleAdded() => l10n.statusPending,
      ArticleAlreadyKnown() => l10n.addUrlDuplicate,
      ArticleInvalid() => l10n.addUrlInvalid,
    };
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

enum _AddChoice { url, site }

class _ArticleList extends ConsumerWidget {
  const _ArticleList({required this.articles});

  final List<ArticleRow> articles;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(articleServiceProvider);

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        Eink.space3,
        0,
        Eink.space3,
        Eink.space8,
      ),
      itemCount: articles.length,
      separatorBuilder: (_, _) => const SizedBox(height: Eink.space3),
      itemBuilder: (context, index) {
        final article = articles[index];
        return Dismissible(
          key: ValueKey(article.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: Eink.space4),
            child: const Icon(Icons.delete_outline),
          ),
          onDismissed: (_) => service.delete(article.id),
          child: ArticleCard(
            title: article.title ?? article.url,
            source: article.siteName ?? Uri.tryParse(article.url)?.host ?? '',
            status: ArticleStatusView.values.byName(article.status),
            selected: article.status != ArticleStatus.sent.name
                ? article.selected
                : null,
            onTap: () =>
                service.setSelected([article.id], selected: !article.selected),
          ),
        );
      },
    );
  }
}

class _ThemeButton extends ConsumerWidget {
  const _ThemeButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = L10n.of(context)!;
    final theme = ref.watch(currentSettingsProvider).themeMode;
    final icon = switch (theme) {
      ThemeMode.system => Icons.brightness_auto,
      ThemeMode.light => Icons.light_mode,
      ThemeMode.dark => Icons.dark_mode,
    };
    return IconButton(
      tooltip: l10n.themeToggleTooltip,
      icon: Icon(icon),
      onPressed: () => ref.read(settingsProvider.notifier).cycleTheme(),
    );
  }
}

/// Bouton de thème partagé par les écrans qui n'ont pas de barre d'application.
class ThemeButton extends ConsumerWidget {
  const ThemeButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => const _ThemeButton();
}
