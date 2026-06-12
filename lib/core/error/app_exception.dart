class AppException implements Exception {
  const AppException({required this.message, this.code, this.cause});

  final String message;
  final String? code;
  final Object? cause;

  @override
  String toString() {
    final buffer = StringBuffer('AppException');

    if (code != null && code!.isNotEmpty) {
      buffer.write('[$code]');
    }

    buffer.write(': $message');

    if (cause != null) {
      buffer.write(' ($cause)');
    }

    return buffer.toString();
  }
}
