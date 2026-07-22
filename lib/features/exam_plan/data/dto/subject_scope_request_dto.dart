import '../../domain/model/subject_scope_input.dart';

class SubjectScopeRequestDto {
  const SubjectScopeRequestDto({
    required this.subjectName,
    required this.examRange,
    required this.preferredMethodNote,
    required this.priority,
  });

  factory SubjectScopeRequestDto.fromDomain(SubjectScopeInput input) {
    return SubjectScopeRequestDto(
      subjectName: input.subjectName,
      examRange: input.examRange,
      preferredMethodNote: input.preferredMethodNote,
      priority: input.priority,
    );
  }

  final String subjectName;
  final String examRange;
  final String preferredMethodNote;
  final String priority;

  // Fallback used when the free-text range has no parseable page numbers.
  static const String _fallbackUnitType = 'CUSTOM';
  static const int _fallbackUnits = 10;

  Map<String, Object?> toJson() {
    final resolved = _resolveUnitsFromRange(examRange);
    return {
      'subjectName': subjectName,
      'rawRangeText': examRange,
      'preferredMethodNote': preferredMethodNote,
      // Client priority (LOW/MEDIUM/HIGH) maps 1:1 to backend DifficultyLevel.
      'difficulty': priority,
      'unitType': resolved.unitType,
      'totalUnits': resolved.units,
      'remainingUnits': resolved.units,
    };
  }

  // Parse the free-text range (e.g. "1쪽~200쪽", "수열과 극한 12~63쪽") into an
  // exact page count so plan generation schedules by real pages, not a fixed
  // placeholder. The two page numbers may be separated from the tilde by unit
  // words like "쪽"/"페이지" (e.g. "1쪽~200쪽"), so allow non-digit characters
  // between each number and the separator. "1쪽~200쪽" -> 199 (end - start,
  // matching "1~101쪽 = 100쪽"); a lone number like "200쪽" -> 200. No numbers
  // -> CUSTOM/10 fallback.
  static _ResolvedUnits _resolveUnitsFromRange(String range) {
    final rangeMatch =
        RegExp(r'(\d+)[^\d~\-–—]*[~\-–—][^\d~\-–—]*(\d+)').firstMatch(range);
    if (rangeMatch != null) {
      final start = int.parse(rangeMatch.group(1)!);
      final end = int.parse(rangeMatch.group(2)!);
      final span = (end - start).abs();
      if (span > 0) {
        return _ResolvedUnits('PAGE', span);
      }
    }

    final singleMatch = RegExp(r'(\d+)').firstMatch(range);
    if (singleMatch != null) {
      final value = int.parse(singleMatch.group(1)!);
      if (value > 0) {
        return _ResolvedUnits('PAGE', value);
      }
    }

    return const _ResolvedUnits(_fallbackUnitType, _fallbackUnits);
  }
}

class _ResolvedUnits {
  const _ResolvedUnits(this.unitType, this.units);

  final String unitType;
  final int units;
}
