import 'package:flutter_test/flutter_test.dart';
import 'package:planit_flutter/features/history/domain/model/history_day_detail.dart';
import 'package:planit_flutter/features/history/domain/model/history_month.dart';
import 'package:planit_flutter/features/history/domain/repository/history_repository.dart';
import 'package:planit_flutter/features/history/presentation/controllers/history_controller.dart';

void main() {
  test('loads a month and then selects a day detail', () async {
    final repository = _FakeHistoryRepository();
    final controller = HistoryController(
      repository: repository,
      initialMonth: '2026-06',
    );

    await controller.load();
    await controller.selectDate('2026-06-01');
    await controller.changeMonth('2026-07');

    expect(repository.requestedMonths, ['2026-06', '2026-07']);
    expect(repository.requestedDates, ['2026-06-01']);
    expect(controller.state.currentMonth, '2026-07');
    expect(controller.state.month?.stats.completedPlans, 42);
    expect(controller.state.selectedDate, '2026-06-01');
    expect(controller.state.detail?.items.single.subjectName, '수학');
  });
}

class _FakeHistoryRepository implements HistoryRepository {
  final List<String> requestedMonths = [];
  final List<String> requestedDates = [];

  @override
  Future<HistoryDayDetail> getDayDetail(String date) async {
    requestedDates.add(date);
    return const HistoryDayDetail(
      date: '2026-06-01',
      completedCount: 4,
      totalCount: 5,
      items: [
        HistoryDayDetailItem(
          subjectName: '수학',
          examRange: '미분과 적분 1단원',
          studyMethod: '개념 정리 후 10문제',
          completed: true,
        ),
      ],
    );
  }

  @override
  Future<HistoryMonth> getMonth(String month) async {
    requestedMonths.add(month);
    return const HistoryMonth(
      month: '2026-06',
      stats: HistoryMonthStats(completedPlans: 42, incompletePlans: 8),
      days: [
        HistoryDaySummary(
          date: '2026-06-01',
          completedCount: 4,
          totalCount: 5,
          completed: true,
          subjects: ['수학', '영어', '국어', '과학'],
        ),
        HistoryDaySummary(
          date: '2026-06-02',
          completedCount: 2,
          totalCount: 4,
          completed: false,
          subjects: ['국어', '과학'],
        ),
      ],
    );
  }
}
