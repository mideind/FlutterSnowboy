package com.example.flutter_snowboy;

import androidx.annotation.NonNull;

import android.os.Handler;
import android.os.Message;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import ai.kitt.snowboy.audio.RecordingThread;
import ai.kitt.snowboy.audio.PlaybackThread;

import ai.kitt.snowboy.audio.AudioDataSaver;

import android.media.AudioManager;


/** FlutterSnowboyPlugin */
public class FlutterSnowboyPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private RecordingThread recordingThread;

  public FlutterSnowboyPlugin() {

  }

  public Handler handle = new Handler() {
        @Override
        public void handleMessage(Message msg) {
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


  public void prepareSnowboy() {
    recordingThread = new RecordingThread(handle, new AudioDataSaver());
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
      prepareSnowboy();
      result.success(true);
    } else if (call.method.equals("startSnowboy")) {
      recordingThread.startRecording();
      result.success(true);
    } else if (call.method.equals("stopSnowboy")) {
      recordingThread.stopRecording();
      result.success(null);
    } else if (call.method.equals("purgeSnowboy")) {
      recordingThread = null;
      result.success(null);
    } else {
      result.notImplemented();
    }
  }

}
