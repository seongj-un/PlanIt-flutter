import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../presentation/controllers/exam_plan_controller.dart';

class ExamPlanPage extends ConsumerStatefulWidget {
  const ExamPlanPage({super.key});

  @override
  ConsumerState<ExamPlanPage> createState() => _ExamPlanPageState();
}

class _ExamPlanPageState extends ConsumerState<ExamPlanPage> {
  late final TextEditingController _labelController;
  late final TextEditingController _dateController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(examPlanControllerProvider);
    _labelController = TextEditingController(
      text: state.initialTargetExamLabel,
    );
    _dateController = TextEditingController(text: state.initialExamDate);
  }

  @override
  void dispose() {
    _labelController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(examPlanControllerProvider);
    final controller = ref.read(examPlanControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('시험 계획 입력')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('목표 시험 정보', style: theme.textTheme.headlineMedium),
                      const SizedBox(height: 8),
                      Text(
                        '시험 종류와 날짜를 저장하면 다음 단계에서 과목별 범위를 입력합니다.',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      _ExamTypeField(
                        selectedValue: state.targetExamType,
                        errorText: state.targetExamTypeError,
                        onSelected: state.isSubmitting
                            ? null
                            : controller.setTargetExamType,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _labelController,
                        label: '시험 이름',
                        hintText: '예: 수능, 6월 모의평가',
                        errorText: state.targetExamLabelError,
                        enabled: !state.isSubmitting,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _dateController,
                        label: '시험 날짜',
                        hintText: '2026-11-19',
                        keyboardType: TextInputType.datetime,
                        errorText: state.examDateError,
                        enabled: !state.isSubmitting,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today_outlined),
                          tooltip: '날짜 선택',
                          onPressed: state.isSubmitting ? null : _pickExamDate,
                        ),
                      ),
                      if (state.formError != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          state.formError!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      PrimaryButton(
                        label: '다음',
                        isLoading: state.isSubmitting,
                        onPressed: () => _submit(controller),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickExamDate() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1);
    final lastDate = DateTime(now.year + 10);
    var initialDate = DateTime.tryParse(_dateController.text.trim()) ?? now;
    if (initialDate.isBefore(firstDate)) {
      initialDate = firstDate;
    } else if (initialDate.isAfter(lastDate)) {
      initialDate = lastDate;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked == null) {
      return;
    }

    final year = picked.year.toString().padLeft(4, '0');
    final month = picked.month.toString().padLeft(2, '0');
    final day = picked.day.toString().padLeft(2, '0');
    _dateController.text = '$year-$month-$day';
  }

  Future<void> _submit(ExamPlanController controller) async {
    final success = await controller.submit(
      targetExamLabel: _labelController.text,
      examDate: _dateController.text,
    );

    if (success && mounted) {
      context.go(RoutePaths.subjectScope);
    }
  }
}

class _ExamTypeField extends StatelessWidget {
  const _ExamTypeField({
    required this.selectedValue,
    required this.onSelected,
    this.errorText,
  });

  final String? selectedValue;
  final ValueChanged<String>? onSelected;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const options = [
      _ChoiceOption(label: '학교 시험', value: 'SCHOOL_EXAM'),
      _ChoiceOption(label: '모의고사', value: 'MOCK_EXAM'),
      _ChoiceOption(label: '수능', value: 'CSAT'),
      _ChoiceOption(label: '자격증', value: 'CERTIFICATE'),
      _ChoiceOption(label: '기타', value: 'ETC'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('시험 종류', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in options)
              ChoiceChip(
                label: Text(option.label),
                selected: selectedValue == option.value,
                onSelected: onSelected == null
                    ? null
                    : (_) => onSelected!(option.value),
              ),
          ],
        ),
        if (errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            errorText!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}

class _ChoiceOption {
  const _ChoiceOption({required this.label, required this.value});

  final String label;
  final String value;
}
