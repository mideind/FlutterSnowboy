package com.example.flutter_snowboy;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** FlutterSnowboyPlugin */
public class FlutterSnowboyPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;

  public FlutterSnowboyPlugin() {

  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "plugin_snowboy");
    channel.setMethodCallHandler(this);
    System.out.println("Attached to Flutter engine");

  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
    System.out.println("Detached from Flutter engine");

  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("prepareSnowboy")) {
      result.success(true);
    } else if (call.method.equals("startSnowboy")) {
      result.success(true);
    } else if (call.method.equals("stopSnowboy")) {
      result.success(null);
    } else if (call.method.equals("purgeSnowboy")) {
      result.success(null);
    } else {
      result.notImplemented();
    }
  }

}
