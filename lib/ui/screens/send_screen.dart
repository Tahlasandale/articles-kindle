import 'dart:io';

import 'package:articles_kindle/data/mail/kindle_mailer.dart';
import 'package:articles_kindle/l10n/generated/app_localizations.dart';
import 'package:articles_kindle/state/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final sendState = ref.watch(sendControllerProvider);
    final settings = ref.watch(currentSettingsProvider);

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
              _SendBar(
                busy: sendState.isBusy,
                step: sendState.step,
                onSend: () => _send(context, ref, settings.sizeLimitMb),
                onTest: () => _testSend(context, ref),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _testSend(BuildContext context, WidgetRef ref) async {
    final l10n = L10n.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    await ref.read(sendControllerProvider.notifier).sendTest();
    final outcome = ref.read(sendControllerProvider).outcome;
    final message = switch (outcome) {
      SendSucceeded() => l10n.sendTestSuccess,
      SendFailed(:final reason) => reason,
      null => null,
    };
    if (message == null || !context.mounted) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// La taille est estimée avant tout envoi : Amazon refuse au-delà de 50 Mo, et
  /// on préfère le dire que voir le livre revenir.
  Future<void> _send(
    BuildContext context,
    WidgetRef ref,
    int sizeLimitMb,
  ) async {
    final l10n = L10n.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final mailer = ref.read(mailerProvider);
    final estimate = await mailer.estimate();
    final size = estimate.bytes / 1000000;

    if (size > sizeLimitMb && context.mounted) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.sendTooLargeTitle),
          content: Text(l10n.sendTooLargeBody('${size.toStringAsFixed(1)} Mo')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.sendButton),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    await ref.read(sendControllerProvider.notifier).send();
    final outcome = ref.read(sendControllerProvider).outcome;
    final message = switch (outcome) {
      SendSucceeded() => l10n.sendSuccess,
      SendFailed(:final reason) => reason,
      null => null,
    };
    if (message == null || !context.mounted) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _SendBar extends StatelessWidget {
  const _SendBar({
    required this.busy,
    required this.step,
    required this.onSend,
    required this.onTest,
  });

  final bool busy;
  final SendStep step;
  final VoidCallback onSend;
  final VoidCallback onTest;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(Eink.space3),
      child: Column(
        children: [
          Text(
            l10n.sendReorderHint,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          if (busy) ...[
            const SizedBox(height: Eink.space2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: Eink.space2),
                Text(switch (step) {
                  SendStep.building => l10n.sendStepBuild,
                  SendStep.sending => l10n.sendStepMail,
                  SendStep.done => '',
                }, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ],
          const SizedBox(height: Eink.space2),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: busy ? null : onSend,
                  child: Text(l10n.sendButton),
                ),
              ),
              const SizedBox(width: Eink.space2),
              OutlinedButton(
                onPressed: busy ? null : onTest,
                child: Text(l10n.sendTestButton),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Taille lisible : « 1,2 Mo ». Isolée pour être réutilisée par l'historique.
String formatBytes(int bytes) {
  if (bytes < 1000) return '$bytes o';
  if (bytes < 1000000) return '${(bytes / 1000).toStringAsFixed(0)} ko';
  return '${(bytes / 1000000).toStringAsFixed(1)} Mo';
}

/// Le dossier temporaire des EPUB : il est vidé après chaque envoi.
Directory get epubCacheDirectory => Directory.systemTemp;
