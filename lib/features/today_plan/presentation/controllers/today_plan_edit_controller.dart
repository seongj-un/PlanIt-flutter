import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_response.dart';
import '../../data/repository/today_plan_repository_impl.dart';
import '../../domain/model/today_plan.dart';
import '../../domain/repository/today_plan_repository.dart';

const _todayPlanEditErrorMessage = '오늘 플랜 저장에 실패했어요.';

final todayPlanEditControllerProvider =
    StateNotifierProvider<TodayPlanEditController, TodayPlanEditState>((ref) {
      return TodayPlanEditController(
        repository: ref.watch(todayPlanRepositoryProvider),
      );
    });

class TodayPlanEditController extends StateNotifier<TodayPlanEditState> {
  TodayPlanEditController({required TodayPlanRepository repository})
    : _repository = repository,
      super(const TodayPlanEditState());

  final TodayPlanRepository _repository;

  Future<bool> submit({
    required List<TodayPlanEditableItem> items,
    required List<int> deletedPlanItemIds,
  }) async {
    if (items.isEmpty) {
      state = const TodayPlanEditState(formError: '학습 항목을 하나 이상 입력해주세요.');
      return false;
    }

    final hasBlankField = items.any(
      (item) =>
          item.subjectName.trim().isEmpty ||
          item.examRange.trim().isEmpty ||
          item.studyMethod.trim().isEmpty ||
          item.priority.trim().isEmpty,
    );
    if (hasBlankField) {
      state = const TodayPlanEditState(
        formError: '각 항목의 과목, 범위, 방법, 우선순위를 모두 입력해주세요.',
      );
      return false;
    }

    state = const TodayPlanEditState(isSubmitting: true);

    try {
      await _repository.updateTodayPlan(
        items: items,
        deletedPlanItemIds: deletedPlanItemIds,
      );
      state = const TodayPlanEditState(isSuccess: true);
      return true;
    } on ApiErrorException catch (error) {
      state = TodayPlanEditState(formError: error.message);
      return false;
    } catch (_) {
      state = const TodayPlanEditState(formError: _todayPlanEditErrorMessage);
      return false;
    }
  }
}

class TodayPlanEditState {
  const TodayPlanEditState({
    this.formError,
    this.isSubmitting = false,
    this.isSuccess = false,
  });

  final String? formError;
  final bool isSubmitting;
  final bool isSuccess;
}
