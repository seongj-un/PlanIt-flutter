import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_response.dart';
import '../../data/repository/today_plan_repository_impl.dart';
import '../../domain/model/today_plan.dart';
import '../../domain/model/today_plan_progress.dart';
import '../../domain/repository/today_plan_repository.dart';

const _todayPlanErrorMessage = '오늘 플랜을 불러오지 못했어요.';

final todayPlanControllerProvider =
    StateNotifierProvider<TodayPlanController, TodayPlanState>((ref) {
      return TodayPlanController(
        repository: ref.watch(todayPlanRepositoryProvider),
      );
    });

class TodayPlanController extends StateNotifier<TodayPlanState> {
  TodayPlanController({required TodayPlanRepository repository})
    : _repository = repository,
      super(const TodayPlanState());

  final TodayPlanRepository _repository;

  Future<void> load({bool forceRefresh = false}) async {
    if (state.isLoading) {
      return;
    }
    if (state.plan != null && state.progress != null && !forceRefresh) {
      return;
    }

    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      final values = await Future.wait<Object>([
        _repository.getTodayPlan(),
        _repository.getTodayProgress(),
      ]);

      state = state.copyWith(
        isLoading: false,
        plan: values[0] as TodayPlan,
        progress: values[1] as TodayPlanProgress,
        clearErrorMessage: true,
      );
    } on ApiErrorException catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.message,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _todayPlanErrorMessage,
      );
    }
  }

  Future<void> toggleItem({
    required int planItemId,
    required bool completed,
  }) async {
    final plan = state.plan;
    final progress = state.progress;
    if (plan == null || progress == null) {
      return;
    }

    final previousPlan = plan;
    final previousProgress = progress;
    final optimistic = _buildOptimisticToggleState(
      plan: plan,
      progress: progress,
      planItemId: planItemId,
      completed: completed,
    );
    state = state.copyWith(
      plan: optimistic.plan,
      progress: optimistic.progress,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );

    try {
      final result = await _repository.togglePlanItem(
        planItemId: planItemId,
        completed: completed,
      );
      final currentProgress = state.progress;
      if (currentProgress == null) {
        return;
      }
      state = state.copyWith(
        progress: currentProgress.copyWith(
          completedCount: result.completedCount,
          totalCount: result.totalCount,
          sproutCount: previousProgress.sproutCount + result.sproutAwarded,
        ),
        successMessage: result.sproutAwarded == 0
            ? null
            : '새싹 ${result.sproutAwarded > 0 ? '+' : ''}${result.sproutAwarded}',
        clearErrorMessage: true,
      );
    } on ApiErrorException catch (error) {
      state = state.copyWith(
        plan: previousPlan,
        progress: previousProgress,
        errorMessage: error.message,
        clearSuccessMessage: true,
      );
    } catch (_) {
      state = state.copyWith(
        plan: previousPlan,
        progress: previousProgress,
        errorMessage: _todayPlanErrorMessage,
        clearSuccessMessage: true,
      );
    }
  }

  Future<bool> completeTodayPlan() async {
    if (state.isCompleting) {
      return false;
    }

    state = state.copyWith(
      isCompleting: true,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );

    try {
      final result = await _repository.completeTodayPlan();
      final plan = state.plan;
      state = state.copyWith(
        isCompleting: false,
        plan: plan?.copyWith(status: result.completed ? 'COMPLETED' : plan.status),
        successMessage: '오늘 플랜 완료! ${result.streakDays}일 연속 출석',
      );
      return true;
    } on ApiErrorException catch (error) {
      state = state.copyWith(
        isCompleting: false,
        errorMessage: error.message,
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isCompleting: false,
        errorMessage: _todayPlanErrorMessage,
      );
      return false;
    }
  }
}

class TodayPlanState {
  const TodayPlanState({
    this.plan,
    this.progress,
    this.errorMessage,
    this.successMessage,
    this.isLoading = false,
    this.isCompleting = false,
  });

  final TodayPlan? plan;
  final TodayPlanProgress? progress;
  final String? errorMessage;
  final String? successMessage;
  final bool isLoading;
  final bool isCompleting;

  TodayPlanState copyWith({
    TodayPlan? plan,
    TodayPlanProgress? progress,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? successMessage,
    bool clearSuccessMessage = false,
    bool? isLoading,
    bool? isCompleting,
  }) {
    return TodayPlanState(
      plan: plan ?? this.plan,
      progress: progress ?? this.progress,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccessMessage
          ? null
          : (successMessage ?? this.successMessage),
      isLoading: isLoading ?? this.isLoading,
      isCompleting: isCompleting ?? this.isCompleting,
    );
  }
}

class _OptimisticToggleState {
  const _OptimisticToggleState({required this.plan, required this.progress});

  final TodayPlan plan;
  final TodayPlanProgress progress;
}

_OptimisticToggleState _buildOptimisticToggleState({
  required TodayPlan plan,
  required TodayPlanProgress progress,
  required int planItemId,
  required bool completed,
}) {
  final currentItem = plan.items.firstWhere((item) => item.planItemId == planItemId);
  final countDelta = completed == currentItem.completed
      ? 0
      : (completed ? 1 : -1);
  final sproutDelta = countDelta * progress.sproutPerPlanItem;
  final items = plan.items
      .map((item) {
        if (item.planItemId != planItemId) {
          return item;
        }

        return item.copyWith(status: completed ? 'COMPLETED' : 'PENDING');
      })
      .toList(growable: false);

  final toggledItem = items.firstWhere((item) => item.planItemId == planItemId);
  final existingCompleted = progress.completedItems
      .where((item) => item.planItemId != planItemId)
      .toList(growable: false);
  final existingRemaining = progress.remainingItems
      .where((item) => item.planItemId != planItemId)
      .toList(growable: false);
  final progressItem = TodayPlanProgressItem(
    planItemId: toggledItem.planItemId,
    subjectName: toggledItem.subjectName,
    label: toggledItem.examRange,
  );

  return _OptimisticToggleState(
    plan: plan.copyWith(items: items),
    progress: progress.copyWith(
      completedCount: progress.completedCount + countDelta,
      completedItems: completed
          ? [...existingCompleted, progressItem]
          : existingCompleted,
      remainingItems: completed
          ? existingRemaining
          : [...existingRemaining, progressItem],
      sproutCount: progress.sproutCount + sproutDelta,
    ),
  );
}
