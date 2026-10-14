import 'package:articles_kindle/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../state/providers.dart';
import '../theme/tokens.dart';
import '../widgets/article_card.dart';
import 'to_read_screen.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = L10n.of(context)!;
    final deliveries = ref.watch(deliveriesProvider);
    final sent = ref.watch(sentArticlesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tabHistory),
        actions: const [
          ThemeButton(),
          SizedBox(width: Eink.space2),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Eink.space3,
          Eink.space3,
          Eink.space3,
          Eink.space8,
        ),
        children: [
          Text(
            l10n.tabSend.toUpperCase(),
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: Eink.space2),
          deliveries.when(
            loading: () => const SizedBox.shrink(),
            error: (error, _) => Text('$error'),
            data: (rows) => rows.isEmpty
                ? Text(
                    l10n.historyEmpty,
                    style: Theme.of(context).textTheme.bodySmall,
                  )
                : Column(
                    children: [
                      for (final delivery in rows)
                        Padding(
                          padding: const EdgeInsets.only(bottom: Eink.space2),
                          child: _DeliveryRow(delivery: delivery),
                        ),
                    ],
                  ),
          ),
          const SizedBox(height: Eink.space6),
          Text(
            l10n.statusSent.toUpperCase(),
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: Eink.space2),
          sent.when(
            loading: () => const SizedBox.shrink(),
            error: (error, _) => Text('$error'),
            data: (rows) => rows.isEmpty
                ? Text(
                    l10n.historyEmpty,
                    style: Theme.of(context).textTheme.bodySmall,
                  )
                : Column(
                    children: [
                      for (final article in rows)
                        Padding(
                          padding: const EdgeInsets.only(bottom: Eink.space2),
                          child: ArticleCard(
                            title: article.title ?? article.url,
                            source: article.siteName ?? '',
                            status: ArticleStatusView.sent,
                            trailing: OutlinedButton(
                              onPressed: () async {
                                await ref.read(articleServiceProvider).requeue([
                                  article.id,
                                ]);
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    SnackBar(
                                      content: Text(l10n.historyQueuedAgain),
                                    ),
                                  );
                              },
                              child: Text(l10n.historyQueuedAgainAction),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
          const SizedBox(height: Eink.space6),
          OutlinedButton.icon(
            onPressed: () => _confirmPurge(context, ref),
            icon: const Icon(Icons.delete_sweep_outlined),
            label: Text(l10n.historyPurge),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmPurge(BuildContext context, WidgetRef ref) async {
    final l10n = L10n.of(context)!;
    final sentRows = ref.read(sentArticlesProvider).value ?? [];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.historyPurge),
        content: Text(l10n.historyPurgeConfirm(sentRows.length)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.historyPurge),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(articleServiceProvider).purgeSentContent();
  }
}

class _DeliveryRow extends StatelessWidget {
  const _DeliveryRow({required this.delivery});

  final dynamic delivery;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    final date = DateFormat('dd/MM/yyyy HH:mm').format(delivery.sentAt);
    final size = '${(delivery.fileSize / 1000000).toStringAsFixed(1)} Mo';

    final text = delivery.success
        ? l10n.historySentOn(date, delivery.articleCount, size)
        : l10n.historyFailed(date, delivery.error ?? '');

    return Row(
      children: [
        Icon(delivery.success ? Icons.check : Icons.priority_high, size: 16),
        const SizedBox(width: Eink.space2),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    );
  }
}
