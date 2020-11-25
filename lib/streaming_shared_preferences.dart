import 'package:flutter/services.dart';

typedef ValueObserver = void Function(String value);

class StreamingSharedPreferences {
  static const MethodChannel _channel =
      const MethodChannel('streaming_shared_preferences');

  final Map<String, ValueObserver> _observers = {};
  final Map<String, String> _lastValues = {};
  Duration _duration = Duration(milliseconds: 250);
  bool _isRunning = false;
  String _prefsName = null;
  void setPrefsName(String name) {
    assert(name != null);
    _prefsName = name;
  }

  void setInterval(Duration duration) {
    if (_duration == null || _duration.inMilliseconds == 0) return;
    _duration = duration;
  }

  Future<String> _getLatestValue(String key) {
    return _channel.invokeMethod<String>('getValue', {
      'key': key,
      'name': _prefsName,
    }).catchError((err) {
      print(err);
      return null;
    });
  }

  Future<bool> setValue(String key, String value) {
    assert(key != null && value != null);
    return _channel.invokeMethod('setValue', {
      'key': key,
      'value': value,
      'name': _prefsName,
    });
  }

  void addObserver(String key, ValueObserver observer) {
    assert(key != null && observer != null && !_isRunning);
    _observers.putIfAbsent(key, () => observer);
  }

  void run() {
    if (!_isRunning) {
      _isRunning = true;
      Future.doWhile(() async {
        await Future.forEach(
          _observers.keys,
          (element) async {
            String value = await _getLatestValue(element);
            if (value == _lastValues[element]) return;
            _lastValues[element] = value;
            _observers[element]?.call(value);
          },
        );
        await Future.delayed(_duration);
        return _isRunning;
      });
    }
  }

  void removeObservers(String key) {
    assert(!_isRunning);
    _observers.remove(key);
    if (_observers.length == 0) {
      _isRunning = false;
    }
  }
}
