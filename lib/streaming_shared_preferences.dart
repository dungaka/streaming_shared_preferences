import 'package:flutter/services.dart';

typedef ValueObserver = void Function(String value);

class StreamingSharedPreferences {
  static const MethodChannel _channel =
      const MethodChannel('streaming_shared_preferences');

  static final Map<String, ValueObserver> _observers = {};
  static final Map<String, String> _lastValues = {};
  static Duration _duration = Duration(milliseconds: 250);
  static bool _isRunning = false;
  static String _prefsName = null;
  static void setPrefsName(String name) {
    assert(name != null);
    _prefsName = name;
  }

  static void setInterval(Duration duration) {
    if (_duration == null || _duration.inMilliseconds == 0) return;
    _duration = duration;
  }

  static Future<String> _getLatestValue(String key) {
    return _channel.invokeMethod<String>('getValue', {
      'key': key,
      'name': _prefsName,
    }).catchError((err) {
      print(err);
      return null;
    });
  }

  static Future<bool> setValue(String key, String value) {
    assert(key != null && value != null);
    return _channel.invokeMethod('setValue', {
      'key': key,
      'value': value,
      'name': _prefsName,
    });
  }

  static void addObserver(String key, ValueObserver observer) {
    assert(key != null && observer != null);
    _observers.putIfAbsent(key, () => observer);
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

  static void removeObservers(String key) {
    _observers.remove(key);
    if (_observers.length == 0) {
      _isRunning = false;
    }
  }
}
