class ApiFieldError {
  const ApiFieldError({required this.field, required this.reason});

  factory ApiFieldError.fromJson(Map<String, Object?> json) {
    return ApiFieldError(
      field: json['field'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
    );
  }

  final String field;
  final String reason;

  Map<String, Object?> toJson() {
    return <String, Object?>{'field': field, 'reason': reason};
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is ApiFieldError &&
        other.field == field &&
        other.reason == reason;
  }

  @override
  int get hashCode => Object.hash(field, reason);
}
