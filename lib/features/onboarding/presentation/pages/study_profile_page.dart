import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../controllers/study_profile_controller.dart';

class StudyProfilePage extends ConsumerStatefulWidget {
  const StudyProfilePage({super.key});

  @override
  ConsumerState<StudyProfilePage> createState() => _StudyProfilePageState();
}

class _StudyProfilePageState extends ConsumerState<StudyProfilePage> {
  late final TextEditingController _ageController;
  late final TextEditingController _studyHoursController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(studyProfileControllerProvider);
    _ageController = TextEditingController(text: state.initialAgeText);
    _studyHoursController = TextEditingController(
      text: state.initialStudyHoursText,
    );
  }

  @override
  void dispose() {
    _ageController.dispose();
    _studyHoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(studyProfileControllerProvider);
    final controller = ref.read(studyProfileControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('기본 학습 정보')),
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
                      Text('기본 학습 정보', style: theme.textTheme.headlineMedium),
                      const SizedBox(height: 8),
                      Text(
                        '학습 패턴을 알려주시면 이후 시험 계획을 더 자연스럽게 이어서 입력할 수 있어요.',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      AppTextField(
                        controller: _ageController,
                        label: '나이',
                        hintText: '18',
                        errorText: state.ageError,
                        keyboardType: TextInputType.number,
                        enabled: !state.isSubmitting,
                      ),
                      const SizedBox(height: 16),
                      _ChipField(
                        label: '학교 단계',
                        errorText: state.schoolLevelError,
                        children: [
                          _ChoiceOption(label: '중학생', value: 'MIDDLE_SCHOOL'),
                          _ChoiceOption(label: '고등학교', value: 'HIGH_SCHOOL'),
                          _ChoiceOption(label: '재수생', value: 'RETAKER'),
                          _ChoiceOption(label: '기타', value: 'ETC'),
                        ],
                        selectedValue: state.schoolLevel,
                        onSelected: state.isSubmitting
                            ? null
                            : controller.setSchoolLevel,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _studyHoursController,
                        label: '하루 공부 시간',
                        hintText: '4',
                        errorText: state.studyHoursError,
                        keyboardType: TextInputType.number,
                        enabled: !state.isSubmitting,
                      ),
                      const SizedBox(height: 16),
                      _ChipField(
                        label: '선호 학습 방식',
                        errorText: state.preferredMethodError,
                        children: [
                          _ChoiceOption(label: '개념 먼저', value: 'CONCEPT_FIRST'),
                          _ChoiceOption(label: '문제 먼저', value: 'PROBLEM_FIRST'),
                          _ChoiceOption(label: '균형 있게', value: 'BALANCED'),
                        ],
                        selectedValue: state.preferredStudyMethod,
                        onSelected: state.isSubmitting
                            ? null
                            : controller.setPreferredStudyMethod,
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

  Future<void> _submit(StudyProfileController controller) async {
    final success = await controller.submit(
      ageText: _ageController.text,
      usualStudyHoursText: _studyHoursController.text,
    );

    if (success && mounted) {
      context.go(RoutePaths.examPlan);
    }
  }
}

class _ChipField extends StatelessWidget {
  const _ChipField({
    required this.label,
    required this.children,
    required this.selectedValue,
    required this.onSelected,
    this.errorText,
  });

  final String label;
  final List<_ChoiceOption> children;
  final String? selectedValue;
  final ValueChanged<String>? onSelected;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final child in children)
              ChoiceChip(
                label: Text(child.label),
                selected: selectedValue == child.value,
                onSelected: onSelected == null
                    ? null
                    : (_) => onSelected!(child.value),
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
