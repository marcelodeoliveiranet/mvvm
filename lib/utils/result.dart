sealed class Result<T> {
  const Result();

  factory Result.ok(T value) = Ok._;

  factory Result.error(Exception error) = Failure._;
}

final class Ok<T> extends Result<T> {
  const Ok._(this.value);

  final T value;

  @override
  String toString() => 'Result<$T>.ok($value)';
}

final class Failure<T> extends Result<T> {
  const Failure._(this.error);

  final Exception error;

  @override
  String toString() => 'Result<$T>.error($error)';
}
