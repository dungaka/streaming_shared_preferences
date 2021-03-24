import 'package:flutter/services.dart';

typedef ValueObserver = void Function(String value);

class StreamingSharedPreferences {
  static const MethodChannel _channel = const MethodChannel('streaming_shared_preferences');

  final Map<String, ValueObserver> _observers = {};
  final Map<String, String> _lastValues = {};
  Duration? _duration = Duration(milliseconds: 150);
  bool _isRunning = false;
  String? _prefsName;

  void setPrefsName(String? name) {
    assert(name != null);
    _prefsName = name;
  }

  void setInterval(Duration duration) {
    if (duration.inMilliseconds == 0) return;
    _duration = duration;
  }

  Future<String> _getLatestValue(String? key) {
    return _channel.invokeMethod<String>('getValue', {
      'key': key,
      'name': _prefsName,
    }).catchError((err) {
      print(err);
      return "";
    });
  }

  Future<bool> setValue(String? key, String? value) {
    assert(key != null && value != null);
    return _channel.invokeMethod('setValue', {
      'key': key,
      'value': value,
      'name': _prefsName,
    }).catchError((err) => false);
  }

  void addObserver(String key, ValueObserver observer) {
    _observers.putIfAbsent(key, () => observer);
  }

  void run() {
    if (!_isRunning) {
      _isRunning = true;
      Future.doWhile(() async {
        await Future.forEach(
          _observers.keys,
          (element) async {
            try {
              String value = await _getLatestValue(element as String);
              if (value == _lastValues[element]) return;
              _lastValues[element] = value;
              _observers[element]?.call(value);
            } catch (err) {
              print(err);
            }
          },
        );
        await Future.delayed(_duration!);
        return _isRunning;
      });
    }
  }

  void removeObservers(String key) {
    if (_isRunning) return;
    _observers.remove(key);
    if (_observers.length == 0) {
      _isRunning = false;
    }
  }
}
