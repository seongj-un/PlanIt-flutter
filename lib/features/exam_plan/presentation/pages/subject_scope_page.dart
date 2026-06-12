import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../core/network/network_providers.dart';
import '../../../plan_generation/domain/model/plan_generation_input.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../domain/model/subject_scope_input.dart';
import '../controllers/exam_plan_controller.dart';

class SubjectScopePage extends ConsumerStatefulWidget {
  const SubjectScopePage({super.key});

  @override
  ConsumerState<SubjectScopePage> createState() => _SubjectScopePageState();
}

class _SubjectScopePageState extends ConsumerState<SubjectScopePage> {
  final List<_SubjectScopeDraft> _drafts = [_SubjectScopeDraft()];

  @override
  void dispose() {
    for (final draft in _drafts) {
      draft.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(subjectScopeControllerProvider);
    final controller = ref.read(subjectScopeControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('과목별 시험 범위')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('과목별 시험 범위', style: theme.textTheme.headlineMedium),
                      const SizedBox(height: 8),
                      Text(
                        '과목명, 시험 범위, 공부 메모를 저장하면 다음 단계에서 플랜 생성을 이어갈 수 있어요.',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      for (var index = 0; index < _drafts.length; index++) ...[
                        _SubjectScopeCard(
                          index: index + 1,
                          draft: _drafts[index],
                          enabled: !state.isSubmitting,
                          onRemove: _drafts.length == 1
                              ? null
                              : () => _removeDraft(index),
                        ),
                        const SizedBox(height: 16),
                      ],
                      OutlinedButton(
                        onPressed: state.isSubmitting ? null : _addDraft,
                        child: const Text('과목 추가'),
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
                        label: '저장하고 계속',
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

  void _addDraft() {
    setState(() {
      _drafts.add(_SubjectScopeDraft());
    });
  }

  void _removeDraft(int index) {
    setState(() {
      _drafts.removeAt(index).dispose();
    });
  }

  Future<void> _submit(SubjectScopeController controller) async {
    final inputs = _drafts
        .map(
          (draft) => SubjectScopeInput(
            subjectName: draft.subjectController.text.trim(),
            examRange: draft.rangeController.text.trim(),
            preferredMethodNote: draft.noteController.text.trim(),
            priority: draft.priority,
          ),
        )
        .toList();

    final success = await controller.submit(inputs);
    if (success && mounted) {
      final planGenerationInput = _buildPlanGenerationInput(inputs);
      if (planGenerationInput == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('기본 학습 정보를 다시 확인해주세요.')),
        );
        return;
      }

      context.go(
        RoutePaths.planGenerationLoading,
        extra: planGenerationInput,
      );
    }
  }

  PlanGenerationInput? _buildPlanGenerationInput(List<SubjectScopeInput> inputs) {
    final userProfile = ref.read(sessionControllerProvider).userProfile;
    final preferredStudyMethod = userProfile?.preferredStudyMethod;
    final dailyMaxStudyHours = userProfile?.usualStudyHoursPerDay;
    if (preferredStudyMethod == null ||
        preferredStudyMethod.isEmpty ||
        dailyMaxStudyHours == null) {
      return null;
    }

    final subjects = inputs
        .map(
          (input) => PlanGenerationSubjectInput(
            subjectName: input.subjectName,
            examRange: input.examRange,
            preferredMethodNote: input.preferredMethodNote,
            difficulty: input.priority,
          ),
        )
        .toList(growable: false);
    final difficultSubjects = inputs
        .where((input) => input.priority == 'HIGH')
        .map((input) => input.subjectName)
        .toList(growable: false);

    return PlanGenerationInput(
      subjects: subjects,
      preferredStudyMethod: preferredStudyMethod,
      difficultSubjects: difficultSubjects,
      dailyMaxStudyHours: dailyMaxStudyHours,
    );
  }
}

class _SubjectScopeCard extends StatefulWidget {
  const _SubjectScopeCard({
    required this.index,
    required this.draft,
    required this.enabled,
    required this.onRemove,
  });

  final int index;
  final _SubjectScopeDraft draft;
  final bool enabled;
  final VoidCallback? onRemove;

  @override
  State<_SubjectScopeCard> createState() => _SubjectScopeCardState();
}

class _SubjectScopeCardState extends State<_SubjectScopeCard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('과목 ${widget.index}', style: theme.textTheme.titleLarge),
                const Spacer(),
                if (widget.onRemove != null)
                  IconButton(
                    onPressed: widget.enabled ? widget.onRemove : null,
                    icon: const Icon(Icons.close),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: widget.draft.subjectController,
              label: '과목명',
              hintText: '예: 수학',
              enabled: widget.enabled,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: widget.draft.rangeController,
              label: '시험 범위',
              hintText: '예: 수열과 극한 1~3단원',
              enabled: widget.enabled,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: widget.draft.noteController,
              label: '공부 메모',
              hintText: '예: 개념 정리 후 대표 문제',
              enabled: widget.enabled,
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
                  selectedValue: widget.draft.priority,
                  enabled: widget.enabled,
                  onSelected: (value) {
                    setState(() {
                      widget.draft.priority = value;
                    });
                  },
                ),
                _PriorityChip(
                  label: '보통',
                  value: 'MEDIUM',
                  selectedValue: widget.draft.priority,
                  enabled: widget.enabled,
                  onSelected: (value) {
                    setState(() {
                      widget.draft.priority = value;
                    });
                  },
                ),
                _PriorityChip(
                  label: '낮음',
                  value: 'LOW',
                  selectedValue: widget.draft.priority,
                  enabled: widget.enabled,
                  onSelected: (value) {
                    setState(() {
                      widget.draft.priority = value;
                    });
                  },
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

class _SubjectScopeDraft {
  _SubjectScopeDraft()
    : subjectController = TextEditingController(),
      rangeController = TextEditingController(),
      noteController = TextEditingController();

  final TextEditingController subjectController;
  final TextEditingController rangeController;
  final TextEditingController noteController;
  String priority = 'MEDIUM';

  void dispose() {
    subjectController.dispose();
    rangeController.dispose();
    noteController.dispose();
  }
}
