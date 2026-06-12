class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    this.email,
    required this.onboardingCompleted,
  });

  final int id;
  final String name;
  final String? email;
  final bool onboardingCompleted;
}
