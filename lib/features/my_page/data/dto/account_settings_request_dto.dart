class AccountSettingsRequestDto {
  const AccountSettingsRequestDto({
    required this.name,
    required this.password,
  });

  final String name;
  final String password;

  Map<String, Object?> toJson() {
    return {'name': name, 'password': password};
  }
}
