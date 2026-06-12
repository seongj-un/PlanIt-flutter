import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_text_field.dart';

class TodayPlanFormItem extends StatelessWidget {
  const TodayPlanFormItem({
    required this.index,
    required this.subjectController,
    required this.examRangeController,
    required this.studyMethodController,
    required this.priority,
    required this.enabled,
    required this.onPriorityChanged,
    this.onRemove,
    super.key,
  });

  final int index;
  final TextEditingController subjectController;
  final TextEditingController examRangeController;
  final TextEditingController studyMethodController;
  final String priority;
  final bool enabled;
  final ValueChanged<String> onPriorityChanged;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('항목 $index', style: theme.textTheme.titleLarge),
                const Spacer(),
                if (onRemove != null)
                  IconButton(
                    onPressed: enabled ? onRemove : null,
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: subjectController,
              label: '과목',
              hintText: '예: 수학',
              enabled: enabled,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: examRangeController,
              label: '시험 범위',
              hintText: '예: 수열과 극한 3장 이상',
              enabled: enabled,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: studyMethodController,
              label: '학습 방법',
              hintText: '예: 대표 문제 15문제',
              enabled: enabled,
            ),
            const SizedBox(height: 12),
            Text('우선순위', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _PriorityChip(
                  label: '높음',
                  value: 'HIGH',
                  selectedValue: priority,
                  enabled: enabled,
                  onSelected: onPriorityChanged,
                ),
                _PriorityChip(
                  label: '보통',
                  value: 'MEDIUM',
                  selectedValue: priority,
                  enabled: enabled,
                  onSelected: onPriorityChanged,
                ),
                _PriorityChip(
                  label: '낮음',
                  value: 'LOW',
                  selectedValue: priority,
                  enabled: enabled,
                  onSelected: onPriorityChanged,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  const _PriorityChip({
    required this.label,
    required this.value,
    required this.selectedValue,
    required this.enabled,
    required this.onSelected,
  });

  final String label;
  final String value;
  final String selectedValue;
  final bool enabled;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selectedValue == value,
      onSelected: enabled ? (_) => onSelected(value) : null,
    );
  }
}
