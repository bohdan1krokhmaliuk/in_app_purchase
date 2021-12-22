import 'package:flutter/services.dart';

class Result<T> {
  const Result.success(final T value)
      : _exception = null,
        _value = value;

  const Result.failed(final PlatformException exception)
      : _exception = exception,
        _value = null;

  final T? _value;
  final PlatformException? _exception;

  T? get valueOrNull => _value;
  PlatformException? get exceptionOrNull => _exception;

  bool get hasValue => _value != null;
  bool get hasException => _exception != null;

  T get value {
    assert(
      _value != null,
      'Please don\'t call this getter unless you are sure that value is not null',
    );

    return _value!;
  }

  PlatformException get exception {
    assert(
      _exception != null,
      'Please don\'t call this getter unless you are sure that exception is not null',
    );

    return _exception!;
  }
}
