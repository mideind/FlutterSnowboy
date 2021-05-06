/*
  Copyright (c) 2021 Miðeind ehf.
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification,
  are permitted provided that the following conditions are met:

  1. Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

  2. Redistributions in binary form must reproduce the above copyright notice, this
  list of conditions and the following disclaimer in the documentation and/or other
  materials provided with the distribution.

  3. Neither the name of the copyright holder nor the names of its contributors may
  be used to endorse or promote products derived from this software without specific
  prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
  IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
  NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
  POSSIBILITY OF SUCH DAMAGE.
*/

library flutter_snowboy;

import 'dart:async';

import 'package:flutter/services.dart';

class FlutterSnowboy {
  static const MethodChannel _channel = const MethodChannel('plugin_snowboy');

  static void err(String method, String msg) {
    print("Error invoking Snowboy '{method}' method: " + msg);
  }

  static Future<bool> prepare(String modelPath,
      [double sensitivity, double audioGain, bool applyFrontend]) async {
    // Initialize Snowboy, load model
    try {
      final bool success = await _channel
          .invokeMethod('prepareSnowboy', [modelPath, sensitivity, audioGain, applyFrontend]);
      return success;
    } on PlatformException catch (e) {
      err("prepare", e.toString());
      return false;
    }
  }

  static Future<bool> start(Function hotwordHandler) async {
    // Activate hotword detection
    try {
      final bool success = await _channel.invokeMethod('startSnowboy');
      return success;
    } on PlatformException catch (e) {
      err("start", e.toString());
      return false;
    }
  }

  static Future<void> stop() async {
    // Suspend hotword detection
    try {
      await _channel.invokeMethod('stopSnowboy');
    } on PlatformException catch (e) {
      err("stop", e.toString());
    }
  }

  static Future<void> purge() async {
    // Dispose of all resources
    try {
      await _channel.invokeMethod('purgeSnowboy');
    } on PlatformException catch (e) {
      err("purge", e.toString());
    }
  }

}
