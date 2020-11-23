
import 'dart:async';

import 'package:flutter/services.dart';

class StreamingSharedPreferences {
  static const MethodChannel _channel =
      const MethodChannel('streaming_shared_preferences');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
