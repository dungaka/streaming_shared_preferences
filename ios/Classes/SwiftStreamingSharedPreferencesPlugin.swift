import Flutter
import UIKit

public class SwiftStreamingSharedPreferencesPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "streaming_shared_preferences", binaryMessenger: registrar.messenger())
    let instance = SwiftStreamingSharedPreferencesPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let key: String? = (call.arguments as? [String: Any])?["key"] as? String
    let name: String? = (call.arguments as? [String: Any])?["name"] as? String
    let value: String? = (call.arguments as? [String: Any])?["value"] as? String

    if call.method == "getValue" {
        if name == nil {
            result(UserDefaults.standard.string(forKey: key!))
        }else{
            result(UserDefaults.init(suiteName: name)?.string(forKey: key!))
        }
    }
    if call.method == "setValue" {
        if name == nil {
            UserDefaults.standard.setValue(value, forKey: key!)
        }else{
            UserDefaults.init(suiteName: name)?.setValue(value, forKey: key!)
        }
        result(true)
    }
  }
}
