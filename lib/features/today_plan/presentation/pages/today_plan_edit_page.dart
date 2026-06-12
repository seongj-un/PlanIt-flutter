import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../shared/widgets/app_loading_view.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../domain/model/today_plan.dart';
import '../controllers/today_plan_controller.dart';
import '../controllers/today_plan_edit_controller.dart';
import '../widgets/today_plan_form_item.dart';

class TodayPlanEditPage extends ConsumerStatefulWidget {
  const TodayPlanEditPage({required this.initialPlan, super.key});

  final TodayPlan? initialPlan;

  @override
  ConsumerState<TodayPlanEditPage> createState() => _TodayPlanEditPageState();
}

class _TodayPlanEditPageState extends ConsumerState<TodayPlanEditPage> {
  final List<_TodayPlanDraft> _drafts = [];
  final List<int> _deletedPlanItemIds = [];

  @override
  void initState() {
    super.initState();
    final plan = widget.initialPlan;
    if (plan != null) {
      _drafts.addAll(
        plan.items.map(_TodayPlanDraft.fromItem).toList(growable: false),
      );
    }
    if (_drafts.isEmpty) {
      _drafts.add(_TodayPlanDraft.empty());
    }
  }

  @override
  void dispose() {
    for (final draft in _drafts) {
      draft.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(todayPlanEditControllerProvider);

    if (widget.initialPlan == null) {
      return const AppScaffold(
        title: '오늘 플랜 수정',
        body: AppLoadingView(
          title: '수정할 플랜을 찾을 수 없어요',
          message: '상세 화면에서 다시 진입해주세요.',
          isLoading: false,
        ),
      );
    }

    return AppScaffold(
      title: '오늘 플랜 수정',
      body: ListView(
        children: [
          for (var index = 0; index < _drafts.length; index++) ...[
            TodayPlanFormItem(
              index: index + 1,
              subjectController: _drafts[index].subjectController,
              examRangeController: _drafts[index].examRangeController,
              studyMethodController: _drafts[index].studyMethodController,
              priority: _drafts[index].priority,
              enabled: !state.isSubmitting,
              onPriorityChanged: (value) {
                setState(() {
                  _drafts[index].priority = value;
                });
              },
              onRemove: _drafts.length == 1
                  ? null
                  : () => _removeDraft(index),
            ),
            const SizedBox(height: 12),
          ],
          OutlinedButton(
            onPressed: state.isSubmitting ? null : _addDraft,
            child: const Text('항목 추가'),
          ),
          if (state.formError != null) ...[
            const SizedBox(height: 16),
            Text(
              state.formError!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
          const SizedBox(height: 20),
          PrimaryButton(
            label: '저장',
            isLoading: state.isSubmitting,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  void _addDraft() {
    setState(() {
      _drafts.add(_TodayPlanDraft.empty());
    });
  }

  void _removeDraft(int index) {
    setState(() {
      final draft = _drafts.removeAt(index);
      if (draft.planItemId != null) {
        _deletedPlanItemIds.add(draft.planItemId!);
      }
      draft.dispose();
    });
  }

  Future<void> _submit() async {
    final items = _drafts
        .map(
          (draft) => TodayPlanEditableItem(
            planItemId: draft.planItemId,
            subjectName: draft.subjectController.text.trim(),
            examRange: draft.examRangeController.text.trim(),
            studyMethod: draft.studyMethodController.text.trim(),
            priority: draft.priority,
          ),
        )
        .toList(growable: false);

    final success = await ref.read(todayPlanEditControllerProvider.notifier).submit(
      items: items,
      deletedPlanItemIds: _deletedPlanItemIds,
    );

    if (!success || !mounted) {
      return;
    }

    await ref.read(todayPlanControllerProvider.notifier).load(forceRefresh: true);
    if (mounted) {
      context.go(RoutePaths.todayPlanDetail);
    }
  }
}

class _TodayPlanDraft {
  _TodayPlanDraft({
    required this.subjectController,
    required this.examRangeController,
    required this.studyMethodController,
    required this.priority,
    this.planItemId,
  });

  factory _TodayPlanDraft.empty() {
    return _TodayPlanDraft(
      subjectController: TextEditingController(),
      examRangeController: TextEditingController(),
      studyMethodController: TextEditingController(),
      priority: 'MEDIUM',
    );
  }

  factory _TodayPlanDraft.fromItem(TodayPlanItem item) {
    return _TodayPlanDraft(
      planItemId: item.planItemId,
      subjectController: TextEditingController(text: item.subjectName),
      examRangeController: TextEditingController(text: item.examRange),
      studyMethodController: TextEditingController(text: item.studyMethod),
      priority: item.priority,
    );
  }

  final int? planItemId;
  final TextEditingController subjectController;
  final TextEditingController examRangeController;
  final TextEditingController studyMethodController;
  String priority;

  void dispose() {
    subjectController.dispose();
    examRangeController.dispose();
    studyMethodController.dispose();
  }
}
