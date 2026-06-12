import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_response.dart';
import '../../data/repository/dashboard_repository_impl.dart';
import '../../domain/model/dashboard_summary.dart';
import '../../domain/repository/dashboard_repository.dart';

const _dashboardErrorMessage = '대시보드를 불러오지 못했어요.';

final dashboardControllerProvider =
    StateNotifierProvider<DashboardController, DashboardState>((ref) {
      return DashboardController(
        repository: ref.watch(dashboardRepositoryProvider),
      );
    });

class DashboardController extends StateNotifier<DashboardState> {
  DashboardController({required DashboardRepository repository})
    : _repository = repository,
      super(const DashboardState());

  final DashboardRepository _repository;

  Future<void> load({bool forceRefresh = false}) async {
    if (state.isLoading) {
      return;
    }
    if (state.summary != null && !forceRefresh) {
      return;
    }

    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      final summary = await _repository.getDashboardSummary();
      state = state.copyWith(
        isLoading: false,
        summary: summary,
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
        errorMessage: _dashboardErrorMessage,
      );
    }
  }
}

class DashboardState {
  const DashboardState({
    this.summary,
    this.errorMessage,
    this.isLoading = false,
  });

  final DashboardSummary? summary;
  final String? errorMessage;
  final bool isLoading;

  DashboardState copyWith({
    DashboardSummary? summary,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool? isLoading,
  }) {
    return DashboardState(
      summary: summary ?? this.summary,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
