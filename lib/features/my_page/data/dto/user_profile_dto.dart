import '../../../../core/error/app_exception.dart';
import '../../domain/model/user_profile.dart';

class UserProfileDto {
  const UserProfileDto({
    required this.id,
    required this.name,
    required this.email,
    required this.onboardingCompleted,
    this.targetExamType,
    this.targetExamLabel,
    this.examDate,
    this.usualStudyHoursPerDay,
    this.preferredStudyMethod,
    this.sproutCount,
    this.attendanceStreakDays,
  });

  factory UserProfileDto.fromJson(Object? json) {
    if (json is! Map) {
      throw const AppException(
        code: 'INVALID_API_RESPONSE',
        message: 'User profile payload must be a JSON object.',
      );
    }

    final map = Map<String, Object?>.from(json);
    final id = map['id'];
    final name = map['name'];
    final email = map['email'];
    final onboardingCompleted = map['onboardingCompleted'];

    if (id is! int ||
        name is! String ||
        name.isEmpty ||
        email is! String ||
        email.isEmpty ||
        onboardingCompleted is! bool) {
      throw const AppException(
        code: 'INVALID_API_RESPONSE',
        message: 'User profile payload is missing required fields.',
      );
    }

    return UserProfileDto(
      id: id,
      name: name,
      email: email,
      targetExamType: _readOptionalString(map, 'targetExamType'),
      targetExamLabel: _readOptionalString(map, 'targetExamLabel'),
      examDate: _readOptionalDate(map, 'examDate'),
      usualStudyHoursPerDay: _readOptionalInt(map, 'usualStudyHoursPerDay'),
      preferredStudyMethod: _readOptionalString(map, 'preferredStudyMethod'),
      sproutCount: _readOptionalInt(map, 'sproutCount'),
      attendanceStreakDays: _readOptionalInt(map, 'attendanceStreakDays'),
      onboardingCompleted: onboardingCompleted,
    );
  }

  final int id;
  final String name;
  final String email;
  final String? targetExamType;
  final String? targetExamLabel;
  final DateTime? examDate;
  final int? usualStudyHoursPerDay;
  final String? preferredStudyMethod;
  final int? sproutCount;
  final int? attendanceStreakDays;
  final bool onboardingCompleted;

  UserProfile toDomain() {
    return UserProfile(
      id: id,
      name: name,
      email: email,
      targetExamType: targetExamType,
      targetExamLabel: targetExamLabel,
      examDate: examDate,
      usualStudyHoursPerDay: usualStudyHoursPerDay,
      preferredStudyMethod: preferredStudyMethod,
      sproutCount: sproutCount,
      attendanceStreakDays: attendanceStreakDays,
      onboardingCompleted: onboardingCompleted,
    );
  }

  static DateTime? _readOptionalDate(Map<String, Object?> map, String key) {
    final value = map[key];
    if (value == null) {
      return null;
    }
    if (value is! String || value.isEmpty) {
      throw AppException(
        code: 'INVALID_API_RESPONSE',
        message: 'User profile field $key has an unexpected type.',
      );
    }

    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      throw AppException(
        code: 'INVALID_API_RESPONSE',
        message: 'User profile field $key is not a valid ISO date.',
      );
    }

    return parsed;
  }

  static int? _readOptionalInt(Map<String, Object?> map, String key) {
    final value = map[key];
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.toInt();
    }

    throw AppException(
      code: 'INVALID_API_RESPONSE',
      message: 'User profile field $key has an unexpected type.',
    );
  }

  static String? _readOptionalString(Map<String, Object?> map, String key) {
    final value = map[key];
    if (value == null) {
      return null;
    }
    if (value is String) {
      return value.isEmpty ? null : value;
    }

    throw AppException(
      code: 'INVALID_API_RESPONSE',
      message: 'User profile field $key has an unexpected type.',
    );
  }
}
