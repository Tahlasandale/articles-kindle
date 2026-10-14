import 'package:articles_kindle/data/article_service.dart';
import 'package:articles_kindle/data/db/tables.dart';
import 'package:articles_kindle/data/feeds/feed_parser.dart';
import 'package:articles_kindle/data/feeds/site_discovery_service.dart';
import 'package:articles_kindle/data/net/article_fetcher.dart';
import 'package:articles_kindle/l10n/generated/app_localizations.dart';
import 'package:articles_kindle/state/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/tokens.dart';

/// Trouve les articles d'un site sans s'y abonner : on lit le flux qu'il déclare,
/// on propose la liste, l'utilisateur coche.
final siteDiscoveryProvider = Provider<SiteDiscoveryService>(
  (ref) => SiteDiscoveryService(ref.watch(articleFetcherProvider)),
);

final articleFetcherProvider = Provider<ArticleFetcher>(
  (ref) => DioArticleFetcher(),
);

/// Résultat de la dernière recherche, gardé le temps de l'écran.
final discoveryResultProvider =
    NotifierProvider<DiscoveryController, AsyncValue<DiscoveryResult?>>(
      DiscoveryController.new,
    );

class DiscoveryController extends Notifier<AsyncValue<DiscoveryResult?>> {
  @override
  AsyncValue<DiscoveryResult?> build() => const AsyncData(null);

  Future<void> search(String url) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(siteDiscoveryProvider).discover(url),
    );
  }

  void reset() => state = const AsyncData(null);
}

class SiteDiscoveryScreen extends ConsumerStatefulWidget {
  const SiteDiscoveryScreen({super.key});

  @override
  ConsumerState<SiteDiscoveryScreen> createState() =>
      _SiteDiscoveryScreenState();
}

class _SiteDiscoveryScreenState extends ConsumerState<SiteDiscoveryScreen> {
  final _controller = TextEditingController();
  final _checked = <String>{};

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    final result = ref.watch(discoveryResultProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addSiteTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(Eink.space3),
            child: TextField(
              controller: _controller,
              autofocus: true,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                hintText: l10n.addSiteHint,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => ref
                      .read(discoveryResultProvider.notifier)
                      .search(_controller.text),
                ),
              ),
              onSubmitted: (value) =>
                  ref.read(discoveryResultProvider.notifier).search(value),
            ),
          ),
          Expanded(
            child: result.when(
              loading: () => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: Eink.space3),
                    Text(l10n.addSiteFinding),
                  ],
                ),
              ),
              error: (error, _) => _Message(text: '$error'),
              data: (data) => switch (data) {
                null => _Message(text: l10n.addSiteHint),
                DiscoveryFound(:final siteName, :final items) => _Found(
                  siteName: siteName,
                  items: items,
                  checked: _checked,
                  onToggle: (item, value) => setState(() {
                    if (value) {
                      _checked.add(item.url);
                    } else {
                      _checked.remove(item.url);
                    }
                  }),
                  onAdd: () => _addSelected(items),
                ),
                DiscoveryNoFeed() => _Message(text: l10n.addSiteNoFeed),
                DiscoveryMediaOnly() => _Message(text: l10n.addSiteNoFeed),
                DiscoveryUnreachable(:final reason) => _Message(text: reason),
                DiscoveryInvalid(:final reason) => _Message(text: reason),
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addSelected(List<FeedItem> items) async {
    final service = ref.read(articleServiceProvider);
    final chosen = items.where((i) => _checked.contains(i.url)).toList();

    var added = 0;
    var duplicates = 0;
    for (final item in chosen) {
      final result = await service.addUrl(item.url, origin: ArticleOrigin.site);
      if (result is ArticleAdded) added++;
      if (result is ArticleAlreadyKnown) duplicates++;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '$added${duplicates > 0 ? ' (+$duplicates doublons)' : ''}',
          ),
        ),
      );
    if (added > 0 && mounted) Navigator.of(context).maybePop();
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Eink.space6),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _Found extends StatelessWidget {
  const _Found({
    required this.siteName,
    required this.items,
    required this.checked,
    required this.onToggle,
    required this.onAdd,
  });

  final String siteName;
  final List<FeedItem> items;
  final Set<String> checked;
  final void Function(FeedItem, bool) onToggle;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Eink.space3),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  siteName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TextButton(
                onPressed: onAdd,
                child: Text(l10n.addSiteAddSelected),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = items[index];
              return CheckboxListTile(
                value: checked.contains(item.url),
                onChanged: (value) => onToggle(item, value ?? false),
                title: Text(item.title),
                subtitle: Text(
                  item.url,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                controlAffinity: ListTileControlAffinity.leading,
              );
            },
          ),
        ),
      ],
    );
  }
}
