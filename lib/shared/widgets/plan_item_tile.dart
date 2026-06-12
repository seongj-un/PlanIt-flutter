import 'package:flutter/material.dart';

class PlanItemTile extends StatelessWidget {
  const PlanItemTile({
    required this.subjectName,
    required this.primaryText,
    this.secondaryText,
    this.statusLabel,
    this.isCompleted = false,
    this.trailing,
    this.onTap,
    super.key,
  });

  final String subjectName;
  final String primaryText;
  final String? secondaryText;
  final String? statusLabel;
  final bool isCompleted;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? theme.colorScheme.secondary.withValues(alpha: 0.15)
                    : theme.colorScheme.primary.withValues(alpha: 0.10),
              ),
              child: Icon(
                isCompleted ? Icons.check_rounded : Icons.menu_book_rounded,
                color: isCompleted
                    ? theme.colorScheme.secondary
                    : theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(subjectName, style: theme.textTheme.titleMedium),
                      if (statusLabel != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            statusLabel!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(primaryText, style: theme.textTheme.bodyLarge),
                  if (secondaryText != null) ...[
                    const SizedBox(height: 4),
                    Text(secondaryText!, style: theme.textTheme.bodyMedium),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 12),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
