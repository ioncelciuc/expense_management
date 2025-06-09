class Response {
  final bool success;
  final String? message;
  final Object? obj;

  Response({
    required this.success,
    this.message,
    this.obj,
  });
}
