enum FailureKind {
  network,
  unauthenticated,
  validation,
  notFound,
  rateLimited,
  unexpected,
}

class AppFailure implements Exception {
  const AppFailure(this.message, {this.kind = FailureKind.unexpected});
  final String message;
  final FailureKind kind;
  @override
  String toString() => message;
}

String failureMessage(Object error) =>
    error is AppFailure ? error.message : 'Terjadi kendala. Silakan coba lagi.';
