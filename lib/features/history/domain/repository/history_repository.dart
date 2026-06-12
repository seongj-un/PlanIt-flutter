import '../model/history_day_detail.dart';
import '../model/history_month.dart';

abstract interface class HistoryRepository {
  Future<HistoryMonth> getMonth(String month);

  Future<HistoryDayDetail> getDayDetail(String date);
}
