import 'package:flutter/material.dart';

import '../../data/db/tables.dart';
import '../../l10n/generated/app_localizations.dart';

/// Un statut ne se signale jamais par la couleur : l'app est monochrome.
/// Il porte un mot et un symbole, ce qui reste lisible en niveaux de gris.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final ArticleStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    final (label, icon) = switch (status) {
      ArticleStatus.pending => (l10n.statusPending, Icons.hourglass_empty),
      ArticleStatus.ready => (l10n.statusReady, Icons.check),
      ArticleStatus.failed => (l10n.statusFailed, Icons.priority_high),
      ArticleStatus.sent => (l10n.statusSent, Icons.send),
    };

    return Semantics(
      label: label,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 4),
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ],
      ),
    );
  }
}
