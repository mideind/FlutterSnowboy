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

package com.example.flutter_snowboy;

import java.util.*;
import java.io.File;

import androidx.annotation.NonNull;

import android.os.Handler;
import android.os.Message;
import android.content.Context;
import android.util.Log;
import android.media.AudioManager;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import ai.kitt.snowboy.Constants;
import ai.kitt.snowboy.AppResCopy;
import ai.kitt.snowboy.audio.RecordingThread;


public class FlutterSnowboyPlugin implements FlutterPlugin, MethodCallHandler {

    // The MethodChannel that will the communication between Flutter and native Android
    // This local reference serves to register the plugin with the Flutter Engine and unregister it
    // when the Flutter Engine is detached from the Activity
    private MethodChannel channel;

    private RecordingThread recordingThread;
    private Context context;

    // Handler invoked when hotword is detected
    public Handler handle = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            //System.err.println("Handler invoked!");

            channel.invokeMethod("hotword", null, new Result() {
                @Override
                public void success(Object o) {
                }

                @Override
                public void error(String s, String s1, Object o) {
                }

                @Override
                public void notImplemented() {
                }
            });

            // MsgEnum message = MsgEnum.getMsgEnum(msg.what);
            // switch(message) {
            //     case MSG_ACTIVE:
            //         break;
            //     case MSG_INFO:
            //         break;
            //     case MSG_VAD_SPEECH:
            //         break;
            //     case MSG_VAD_NOSPEECH:
            //         break;
            //     case MSG_ERROR:
            //         break;
            //     default:
            //         super.handleMessage(msg);
            //         break;
            //  }
        }
    };

    // Instantiate a Snowboy recording and detection thread
    public void prepareSnowboy(@NonNull MethodCall call, @NonNull Result result) {
        String rsrcPath = context.getFilesDir().getAbsolutePath() + "/" + Constants.ASSETS_DIRNAME;
        String commonPath = rsrcPath + "/" + Constants.COMMON_RES_FILENAME;
        String modelPath = rsrcPath + "/" + Constants.DEFAULT_MODEL_FILENAME;

        try {
            // Copy assets required by Snowboy to filesystem
            AppResCopy.copyFilesFromAssets(context, Constants.ASSETS_DIRNAME, rsrcPath, true);
            // Create detection thread
            recordingThread = new RecordingThread(handle, commonPath, modelPath, "0.5", 1.0, false);
        } catch (Exception e) {
            e.printStackTrace();
            result.success(false);
        }

        result.success(true);
    }

    public void startSnowboy(@NonNull MethodCall call, @NonNull Result result) {
        try {
            if (recordingThread != null) {
                recordingThread.startRecording();
            }
        } catch (Exception e) {
            e.printStackTrace();
            result.success(false);
        }
        result.success(true);
    }

    public void stopSnowboy(@NonNull MethodCall call, @NonNull Result result) {
        try {
            if (recordingThread != null) {
                recordingThread.stopRecording();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        result.success(null);
    }

    public void purgeSnowboy(@NonNull MethodCall call, @NonNull Result result) {
        recordingThread = null;
        result.success(null);
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "plugin_snowboy");
        channel.setMethodCallHandler(this);
        context = flutterPluginBinding.getApplicationContext();
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("prepareSnowboy")) {
            prepareSnowboy(call, result);
        } else if (call.method.equals("startSnowboy")) {
            startSnowboy(call, result);
        } else if (call.method.equals("stopSnowboy")) {
            stopSnowboy(call, result);
        } else if (call.method.equals("purgeSnowboy")) {
            purgeSnowboy(call, result);
        } else {
            result.notImplemented();
        }
    }

}
