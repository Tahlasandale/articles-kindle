import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../theme/tokens.dart';

/// Carte d'article : liseré net, coins droits, une vignette à gauche quand elle
/// existe, un mot et un symbole pour le statut.
class ArticleCard extends StatelessWidget {
  const ArticleCard({
    super.key,
    required this.title,
    required this.source,
    required this.status,
    this.selected,
    this.onTap,
    this.onLongPress,
    this.trailing,
    this.trailingText,
    this.subtitle,
  });

  final String title;
  final String source;
  final ArticleStatusView status;
  final bool? selected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget? trailing;
  final String? trailingText;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = L10n.of(context)!;

    final titleText = title.trim().isEmpty ? l10n.statusPending : title;

    return Card(
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(Eink.space3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (selected != null)
                Padding(
                  padding: const EdgeInsets.only(right: Eink.space3),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: selected,
                      onChanged: (_) => onTap?.call(),
                    ),
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titleText,
                      style: theme.textTheme.titleMedium,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: Eink.space1),
                    Text(
                      subtitle ?? source,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: Eink.space2),
                    StatusLine(status: status),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}

/// Vue du statut, indépendante de la base : le widget ne connaît que l'affichage.
enum ArticleStatusView { pending, ready, failed, sent }

class StatusLine extends StatelessWidget {
  const StatusLine({super.key, required this.status, this.detail});

  final ArticleStatusView status;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    final theme = Theme.of(context);
    final (label, icon) = switch (status) {
      ArticleStatusView.pending => (l10n.statusPending, Icons.hourglass_empty),
      ArticleStatusView.ready => (l10n.statusReady, Icons.check),
      ArticleStatusView.failed => (l10n.statusFailed, Icons.priority_high),
      ArticleStatusView.sent => (l10n.statusSent, Icons.send),
    };

    return Wrap(
      spacing: Eink.space2,
      runSpacing: Eink.space1,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14),
            const SizedBox(width: 4),
            Text(label.toUpperCase(), style: theme.textTheme.labelLarge),
          ],
        ),
        if (detail != null && detail!.isNotEmpty)
          Text(
            detail!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}
