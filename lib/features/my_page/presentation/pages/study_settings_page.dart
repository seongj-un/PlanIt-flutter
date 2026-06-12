import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../controllers/my_page_controller.dart';

class StudySettingsPage extends ConsumerStatefulWidget {
  const StudySettingsPage({super.key});

  @override
  ConsumerState<StudySettingsPage> createState() => _StudySettingsPageState();
}

class _StudySettingsPageState extends ConsumerState<StudySettingsPage> {
  late final TextEditingController _studyHoursController;
  String _preferredStudyMethod = 'BALANCED';

  @override
  void initState() {
    super.initState();
    final userProfile = ref.read(myPageControllerProvider).userProfile;
    _studyHoursController = TextEditingController(
      text: userProfile?.usualStudyHoursPerDay?.toString() ?? '',
    );
    _preferredStudyMethod = userProfile?.preferredStudyMethod ?? 'BALANCED';
  }

  @override
  void dispose() {
    _studyHoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myPageControllerProvider);

    return AppScaffold(
      title: '공부 설정',
      body: ListView(
        children: [
          AppTextField(
            controller: _studyHoursController,
            label: '하루 공부 시간',
            hintText: '5',
            keyboardType: TextInputType.number,
            enabled: !state.isSaving,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MethodChip(
                label: '개념 먼저',
                value: 'CONCEPT_FIRST',
                selectedValue: _preferredStudyMethod,
                onSelected: (value) => setState(() => _preferredStudyMethod = value),
              ),
              _MethodChip(
                label: '문제 먼저',
                value: 'PROBLEM_FIRST',
                selectedValue: _preferredStudyMethod,
                onSelected: (value) => setState(() => _preferredStudyMethod = value),
              ),
              _MethodChip(
                label: '균형 있게',
                value: 'BALANCED',
                selectedValue: _preferredStudyMethod,
                onSelected: (value) => setState(() => _preferredStudyMethod = value),
              ),
            ],
          ),
          if (state.errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              state.errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
          const SizedBox(height: 20),
          PrimaryButton(
            label: '저장',
            isLoading: state.isSaving,
            onPressed: () async {
              final success = await ref.read(myPageControllerProvider.notifier).saveStudySettings(
                usualStudyHoursPerDayText: _studyHoursController.text,
                preferredStudyMethod: _preferredStudyMethod,
              );
              if (!context.mounted || !success) return;
              context.go(RoutePaths.myPage);
            },
          ),
        ],
      ),
    );
  }
}

class _MethodChip extends StatelessWidget {
  const _MethodChip({
    required this.label,
    required this.value,
    required this.selectedValue,
    required this.onSelected,
  });

  final String label;
  final String value;
  final String selectedValue;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selectedValue == value,
      onSelected: (isSelected) {
        if (isSelected) {
          onSelected(value);
        }
      },
    );
  }
}
