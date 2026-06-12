enum PlanGenerationJobStatus { pending, running, completed, failed }

class PlanGenerationStatus {
  const PlanGenerationStatus({
    required this.jobId,
    required this.status,
    this.estimatedSeconds,
    this.progressPercent,
    this.message,
    this.planDate,
    this.planId,
    this.dashboardAvailable,
  });

  final String jobId;
  final PlanGenerationJobStatus status;
  final int? estimatedSeconds;
  final int? progressPercent;
  final String? message;
  final String? planDate;
  final int? planId;
  final bool? dashboardAvailable;

  bool get isCompleted => status == PlanGenerationJobStatus.completed;
  bool get isFailed => status == PlanGenerationJobStatus.failed;
  bool get isInProgress =>
      status == PlanGenerationJobStatus.pending ||
      status == PlanGenerationJobStatus.running;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is PlanGenerationStatus &&
        other.jobId == jobId &&
        other.status == status &&
        other.estimatedSeconds == estimatedSeconds &&
        other.progressPercent == progressPercent &&
        other.message == message &&
        other.planDate == planDate &&
        other.planId == planId &&
        other.dashboardAvailable == dashboardAvailable;
  }

  @override
  int get hashCode => Object.hash(
    jobId,
    status,
    estimatedSeconds,
    progressPercent,
    message,
    planDate,
    planId,
    dashboardAvailable,
  );
}
