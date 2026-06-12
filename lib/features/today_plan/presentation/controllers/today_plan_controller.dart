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
}

class TodayPlanState {
  const TodayPlanState({
    this.plan,
    this.progress,
    this.errorMessage,
    this.isLoading = false,
  });

  final TodayPlan? plan;
  final TodayPlanProgress? progress;
  final String? errorMessage;
  final bool isLoading;

  TodayPlanState copyWith({
    TodayPlan? plan,
    TodayPlanProgress? progress,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool? isLoading,
  }) {
    return TodayPlanState(
      plan: plan ?? this.plan,
      progress: progress ?? this.progress,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
