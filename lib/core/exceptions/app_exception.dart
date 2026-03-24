// ignore_for_file: public_member_api_docs, sort_constructors_first
class AppException implements Exception {
  final String message;

  AppException({required this.message});

  @override
  String toString() => message;
}
