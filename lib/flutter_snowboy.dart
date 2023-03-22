/*
 * Copyright (C) 2021-2023 Miðeind ehf.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * https://www.apache.org/licenses/LICENSE-2.0
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

const kDefaultSensitivity = 0.5;
const kDefaultAudioGain = 1.0;

class Snowboy {
  MethodChannel _channel = const MethodChannel('plugin_snowboy');
  Function? hotwordHandler;

  Snowboy() {
    // Register handler to receive messages from native plugin
    _channel.setMethodCallHandler(channelMethodCallHandler);
  }

  // Handle messages from the native plugin
  Future<dynamic> channelMethodCallHandler(MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'hotword':
        if (hotwordHandler != null) {
          hotwordHandler!();
        }
        break;
      default:
        throw MissingPluginException('notImplemented');
    }
  }

  void _err(String methodName, String msg) {
    print("Error invoking Snowboy '$methodName' method: $msg");
  }

  /// Instantiate Snowboy in the native plugin code, load provided
  /// model and other resources, w. configuration.
  Future<bool> prepare(String modelPath,
      {double sensitivity = kDefaultSensitivity,
      double audioGain = kDefaultAudioGain,
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

  /// Detect hotword in the provided audio data
  Future<void> detect(Uint8List data) async {
    try {
      await _channel.invokeMethod('detectSnowboy', [data]);
    } on PlatformException catch (e) {
      _err("detectSnowboy", e.toString());
    }
  }

  /// Dispose of all resources
  Future<void> purge() async {
    try {
      await _channel.invokeMethod('purgeSnowboy');
    } on PlatformException catch (e) {
      _err("purgeSnowboy", e.toString());
    }
  }
}
