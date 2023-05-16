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

package is.mideind.flutter_snowboy;

import ai.kitt.snowboy.AppResCopy;
import ai.kitt.snowboy.Constants;
import android.content.Context;
import android.media.AudioManager;
import android.os.Handler;
import android.os.Message;
import android.os.Looper;
import android.util.Log;
import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import is.mideind.flutter_snowboy.Detector;
import java.io.File;
import java.util.*;

public class FlutterSnowboyPlugin implements FlutterPlugin, MethodCallHandler {
  // The MethodChannel that handles communication between Flutter and native
  // Android. This local reference serves to register the plugin with the
  // Flutter Engine and unregister it when the Flutter Engine is detached from
  // the Activity.
  private MethodChannel channel;

  private Context context;
  private Detector detector;

  // Handler invoked when hotword is detected
  public Handler handle = new Handler(Looper.getMainLooper()) {
    @Override
    public void handleMessage(Message msg) {
      // System.err.println("Handler invoked!");

      channel.invokeMethod("hotword", null, new Result() {
        // Boilerplate
        @Override
        public void success(Object o) {}

        @Override
        public void error(String s, String s1, Object o) {}

        @Override
        public void notImplemented() {}
      });
    }
  };

  public void prepareSnowboy(@NonNull MethodCall call, @NonNull Result result) {
    // Copy assets required by Snowboy to filesystem
    String rsrcPath = context.getFilesDir().getAbsolutePath() + "/" +
                      Constants.ASSETS_DIRNAME;
    String commonPath = rsrcPath + "/" + Constants.COMMON_RES_FILENAME;

    try {
      AppResCopy.copyFilesFromAssets(context, Constants.ASSETS_DIRNAME,
                                     rsrcPath, true);

      ArrayList args = call.arguments();

      String modelPath = (String)args.get(0);

      // Basic sanity check
      if (modelPath == null || modelPath.trim().isEmpty()) {
        System.out.println("Invalid model path: '" + modelPath + "'");
        result.success(false);
        return;
      }

      // Make sure model exists at path
      File modelFile = new File(modelPath);
      if (!modelFile.exists()) {
        System.out.println("No model at path: '" + modelPath + "'");
        result.success(false);
        return;
      }

      System.out.println("Final model path: '" + modelPath + "'");

      String sensitivity = args.get(1) + "";
      double audioGain = (double)args.get(2);
      boolean applyFrontend = (boolean)args.get(3);

      detector = new Detector(handle, commonPath, modelPath, sensitivity,
                              audioGain, applyFrontend);

    } catch (Exception e) {
      e.printStackTrace();
      result.success(false);
    }

    result.success(true);
  }

  public void detectSnowboy(@NonNull MethodCall call, @NonNull Result result) {
    try {
      // Retrieve first argument from Flutter. This should be audio data.
      ArrayList args = call.arguments();
      byte[] bytes = (byte[])args.get(0);
      // Feed bytes into detector
      detector.detect(bytes);
    } catch (Exception e) {
      e.printStackTrace();
      result.success(false);
    }
    result.success(true);
  }

  public void purgeSnowboy(@NonNull MethodCall call, @NonNull Result result) {
    // Dispose of any resources used by detector.
    detector = null;
    result.success(null);
  }

  @Override
  public void
  onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    // Called when the Flutter plugin is attached to the Flutter Engine.
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(),
                                "plugin_snowboy");
    channel.setMethodCallHandler(this);
    context = flutterPluginBinding.getApplicationContext();
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    // Forward Flutter method calls to native code
    if (call.method.equals("prepareSnowboy")) {
      prepareSnowboy(call, result);
    } else if (call.method.equals("detectSnowboy")) {
      detectSnowboy(call, result);
    } else if (call.method.equals("purgeSnowboy")) {
      purgeSnowboy(call, result);
    } else {
      result.notImplemented();
    }
  }
}
