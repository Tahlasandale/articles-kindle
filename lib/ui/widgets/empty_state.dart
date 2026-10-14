import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// État vide : une explication et un geste, pas un écran blanc.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.body,
    this.action,
  });

  final String title;
  final String body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Eink.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.article_outlined, size: 40),
            const SizedBox(height: Eink.space4),
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: Eink.space2),
            Text(
              body,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: Eink.space4),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
