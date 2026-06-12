import '../../domain/model/plan_generation_input.dart';

class PlanGenerationRequestDto {
  const PlanGenerationRequestDto({
    required this.subjects,
    required this.preferredStudyMethod,
    required this.difficultSubjects,
    required this.dailyMaxStudyHours,
  });

  factory PlanGenerationRequestDto.fromDomain(PlanGenerationInput input) {
    return PlanGenerationRequestDto(
      subjects: input.subjects
          .map(PlanGenerationSubjectRequestDto.fromDomain)
          .toList(growable: false),
      preferredStudyMethod: input.preferredStudyMethod,
      difficultSubjects: input.difficultSubjects,
      dailyMaxStudyHours: input.dailyMaxStudyHours,
    );
  }

  final List<PlanGenerationSubjectRequestDto> subjects;
  final String preferredStudyMethod;
  final List<String> difficultSubjects;
  final int dailyMaxStudyHours;

  Map<String, Object?> toJson() {
    return {
      'subjects': subjects.map((subject) => subject.toJson()).toList(),
      'preferredStudyMethod': preferredStudyMethod,
      'difficultSubjects': difficultSubjects,
      'dailyMaxStudyHours': dailyMaxStudyHours,
    };
  }
}

class PlanGenerationSubjectRequestDto {
  const PlanGenerationSubjectRequestDto({
    required this.subjectName,
    required this.examRange,
    required this.preferredMethodNote,
    required this.difficulty,
  });

  factory PlanGenerationSubjectRequestDto.fromDomain(
    PlanGenerationSubjectInput input,
  ) {
    return PlanGenerationSubjectRequestDto(
      subjectName: input.subjectName,
      examRange: input.examRange,
      preferredMethodNote: input.preferredMethodNote,
      difficulty: input.difficulty,
    );
  }

  final String subjectName;
  final String examRange;
  final String preferredMethodNote;
  final String difficulty;

  Map<String, Object?> toJson() {
    return {
      'subjectName': subjectName,
      'examRange': examRange,
      'preferredMethodNote': preferredMethodNote,
      'difficulty': difficulty,
    };
  }
}
