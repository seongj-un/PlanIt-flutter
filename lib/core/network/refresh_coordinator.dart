class RefreshCoordinator {
  Future<void>? _inFlight;

  Future<void> run(Future<void> Function() refreshAction) {
    final inFlight = _inFlight;
    if (inFlight != null) {
      return inFlight;
    }

    final future = refreshAction();
    _inFlight = future.whenComplete(() {
      _inFlight = null;
    });

    return _inFlight!;
  }
}
