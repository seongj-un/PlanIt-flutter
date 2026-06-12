import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_response.dart';
import '../../data/repository/history_repository_impl.dart';
import '../../domain/model/history_day_detail.dart';
import '../../domain/model/history_month.dart';
import '../../domain/repository/history_repository.dart';

const _historyErrorMessage = '학습 기록을 불러오지 못했어요.';

final historyInitialMonthProvider = Provider<String>((ref) {
  final now = DateTime.now();
  return _formatMonth(now.year, now.month);
});

final historyControllerProvider =
    StateNotifierProvider<HistoryController, HistoryState>((ref) {
      return HistoryController(
        repository: ref.watch(historyRepositoryProvider),
        initialMonth: ref.watch(historyInitialMonthProvider),
      );
    });

class HistoryController extends StateNotifier<HistoryState> {
  HistoryController({
    required HistoryRepository repository,
    required String initialMonth,
  }) : _repository = repository,
       super(HistoryState(currentMonth: initialMonth));

  final HistoryRepository _repository;

  Future<void> load({bool forceRefresh = false}) async {
    if (state.isLoading) {
      return;
    }
    if (state.month != null && !forceRefresh) {
      return;
    }

    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      final month = await _repository.getMonth(state.currentMonth);
      state = state.copyWith(
        isLoading: false,
        month: month,
        clearErrorMessage: true,
      );
    } on ApiErrorException catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
    } catch (_) {
      state = state.copyWith(isLoading: false, errorMessage: _historyErrorMessage);
    }
  }

  Future<void> changeMonth(String month) async {
    state = state.copyWith(currentMonth: month, month: null);
    await load(forceRefresh: true);
  }

  Future<void> selectDate(String date) async {
    state = state.copyWith(
      selectedDate: date,
      isDetailLoading: true,
      clearErrorMessage: true,
    );

    try {
      final detail = await _repository.getDayDetail(date);
      state = state.copyWith(
        detail: detail,
        isDetailLoading: false,
        clearErrorMessage: true,
      );
    } on ApiErrorException catch (error) {
      state = state.copyWith(
        isDetailLoading: false,
        errorMessage: error.message,
      );
    } catch (_) {
      state = state.copyWith(
        isDetailLoading: false,
        errorMessage: _historyErrorMessage,
      );
    }
  }
}

class HistoryState {
  const HistoryState({
    required this.currentMonth,
    this.month,
    this.selectedDate,
    this.detail,
    this.errorMessage,
    this.isLoading = false,
    this.isDetailLoading = false,
  });

  final String currentMonth;
  final HistoryMonth? month;
  final String? selectedDate;
  final HistoryDayDetail? detail;
  final String? errorMessage;
  final bool isLoading;
  final bool isDetailLoading;

  HistoryState copyWith({
    String? currentMonth,
    HistoryMonth? month,
    String? selectedDate,
    HistoryDayDetail? detail,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool? isLoading,
    bool? isDetailLoading,
  }) {
    return HistoryState(
      currentMonth: currentMonth ?? this.currentMonth,
      month: month ?? this.month,
      selectedDate: selectedDate ?? this.selectedDate,
      detail: detail ?? this.detail,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      isLoading: isLoading ?? this.isLoading,
      isDetailLoading: isDetailLoading ?? this.isDetailLoading,
    );
  }
}

String formatPreviousMonth(String currentMonth) {
  final date = DateTime.parse('$currentMonth-01');
  final previous = DateTime(date.year, date.month - 1);
  return _formatMonth(previous.year, previous.month);
}

String formatNextMonth(String currentMonth) {
  final date = DateTime.parse('$currentMonth-01');
  final next = DateTime(date.year, date.month + 1);
  return _formatMonth(next.year, next.month);
}

String _formatMonth(int year, int month) {
  return '$year-${month.toString().padLeft(2, '0')}';
}
