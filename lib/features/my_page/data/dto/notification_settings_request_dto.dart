class NotificationSettingsRequestDto {
  const NotificationSettingsRequestDto({
    required this.dailyReminderEnabled,
    required this.dailyReminderTime,
  });

  final bool dailyReminderEnabled;
  final String dailyReminderTime;

  Map<String, Object?> toJson() {
    return {
      'dailyReminderEnabled': dailyReminderEnabled,
      'dailyReminderTime': dailyReminderTime,
    };
  }
}
