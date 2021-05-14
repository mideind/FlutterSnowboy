/*
 * Copyright (C) 2021 Miðeind ehf.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

library flutter_snowboy;

import 'dart:async';

import 'package:flutter/services.dart';

enum SnowboyStatus {
  instantiated,
  prepared,
  running,
  purged
}

class Snowboy {
  MethodChannel _channel = const MethodChannel('plugin_snowboy');
  Function hotwordHandler;

  Snowboy() {
    // Register handler to receive messages from native plugin
    _channel.setMethodCallHandler(channelMethodCallHandler);
  }

  // Handle messages from the native plugin
  Future<dynamic> channelMethodCallHandler(MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'hotword':
        if (hotwordHandler != null) {
          hotwordHandler();
        }
        break;
      default:
        throw MissingPluginException('notImplemented');
    }
  }

  static void _err(String methodName, String msg) {
    print("Error invoking Snowboy '$methodName' method: $msg");
  }

  // Instantiate Snowboy in the native plugin code, load provided
  // model and other resources, w. configuration. If no model path
  // is provided, defaults to loading a model that recognizes the
  // hotword "Alexa".
  Future<bool> prepare(
      {String modelPath = "",
      double sensitivity = 0.5,
      double audioGain = 1.0,
      bool applyFrontend = false}) async {
    try {
      final bool success = await _channel.invokeMethod(
          'prepareSnowboy', [modelPath, sensitivity, audioGain, applyFrontend]);
      return success;
    } on PlatformException catch (e) {
      _err("prepareSnowboy", e.toString());
      return false;
    }
  }

  // Activate hotword detection
  Future<bool> start(Function hwHandler) async {
    try {
      final bool success = await _channel.invokeMethod('startSnowboy');
      hotwordHandler = hwHandler;
      return success;
    } on PlatformException catch (e) {
      _err("startSnowboy", e.toString());
      return false;
    }
  }

  // Suspend hotword detection
  Future<void> stop() async {
    try {
      await _channel.invokeMethod('stopSnowboy');
    } on PlatformException catch (e) {
      _err("stopSnowboy", e.toString());
    }
  }

  // Dispose of all resources
  Future<void> purge() async {
    try {
      await _channel.invokeMethod('purgeSnowboy');
    } on PlatformException catch (e) {
      _err("purgeSnowboy", e.toString());
    }
  }

  // Get state of Snowboy in native code. Returns SnowboyStatus enum.
  Future<SnowboyStatus> state() async {
    try {
      await _channel.invokeMethod('getSnowboyState');
    } on PlatformException catch (e) {
      _err("getSnowboyState", e.toString());
    }
  }
}
