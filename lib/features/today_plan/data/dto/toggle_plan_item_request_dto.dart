class TogglePlanItemRequestDto {
  const TogglePlanItemRequestDto({required this.completed});

  final bool completed;

  Map<String, Object?> toJson() {
    return {'completed': completed};
  }
}
