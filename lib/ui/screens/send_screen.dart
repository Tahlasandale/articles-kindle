import 'package:articles_kindle/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/providers.dart';
import '../theme/tokens.dart';
import '../widgets/article_card.dart';
import '../widgets/empty_state.dart';
import 'to_read_screen.dart';

class SendScreen extends ConsumerWidget {
  const SendScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = L10n.of(context)!;
    final queue = ref.watch(sendQueueProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tabSend),
        actions: const [
          ThemeButton(),
          SizedBox(width: Eink.space2),
        ],
      ),
      body: queue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            EmptyState(title: l10n.statusFailed, body: '$error'),
        data: (articles) {
          if (articles.isEmpty) {
            return EmptyState(title: l10n.sendTitle, body: l10n.sendNothing);
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(Eink.space3),
                child: Text(
                  l10n.sendSummary(articles.length, '—'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Expanded(
                child: ReorderableListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: Eink.space3),
                  itemCount: articles.length,
                  onReorderItem: (oldIndex, newIndex) async {
                    final ids = [for (final a in articles) a.id];
                    final moved = ids.removeAt(oldIndex);
                    ids.insert(newIndex, moved);
                    await ref.read(articleServiceProvider).reorder(ids);
                    ref.invalidate(sendQueueProvider);
                  },
                  itemBuilder: (context, index) {
                    final article = articles[index];
                    return Padding(
                      key: ValueKey(article.id),
                      padding: const EdgeInsets.only(bottom: Eink.space3),
                      child: ReorderableDragStartListener(
                        index: index,
                        child: ArticleCard(
                          title: article.title ?? article.url,
                          source: article.siteName ?? '',
                          status: ArticleStatusView.ready,
                          trailingText: '${index + 1}',
                          trailing: const Icon(Icons.drag_handle),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(Eink.space3),
                child: Column(
                  children: [
                    Text(
                      l10n.sendReorderHint,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: Eink.space2),
                    FilledButton(
                      onPressed: articles.isEmpty ? null : () {},
                      child: Text(l10n.sendButton),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
