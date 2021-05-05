package com.example.flutter_snowboy;

import java.util.*;
import java.io.File;
import androidx.annotation.NonNull;

import android.os.Environment;
import android.os.Handler;
import android.os.Message;
import android.content.Context;
import android.util.Log;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import ai.kitt.snowboy.audio.RecordingThread;
import ai.kitt.snowboy.audio.PlaybackThread;
import ai.kitt.snowboy.Constants;

import ai.kitt.snowboy.audio.AudioDataSaver;
import ai.kitt.snowboy.SnowboyDetect;
import ai.kitt.snowboy.AppResCopy;

import android.media.AudioManager;


/** FlutterSnowboyPlugin */
public class FlutterSnowboyPlugin implements FlutterPlugin, MethodCallHandler {

  // static { System.loadLibrary("snowboy-detect-android"); }

  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private RecordingThread recordingThread;
  private SnowboyDetect detector;
  private Context context;

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

  private static final String ACTIVE_RES = Constants.ACTIVE_RES;
  private static final String ACTIVE_UMDL = Constants.ACTIVE_UMDL;

    private static String strEnvWorkSpace = Constants.DEFAULT_WORK_SPACE;
    private String activeModel = strEnvWorkSpace+ACTIVE_UMDL;
    private String commonRes = strEnvWorkSpace+ACTIVE_RES;

  public void prepareSnowboy() {
    System.loadLibrary("snowboy-detect-android");
    detector = new SnowboyDetect("snowboy/common.res", "snowboy/alexa.umdl");
    // recordingThread = new RecordingThread(handle, new AudioDataSaver());
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "plugin_snowboy");
    channel.setMethodCallHandler(this);
    context = flutterPluginBinding.getApplicationContext();
    System.err.println("Attached to Flutter engine");
    AppResCopy.copyFilesFromAssets(context, "snowboy", strEnvWorkSpace+"/", true);

  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
    System.err.println("Detached from Flutter engine");

  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("prepareSnowboy")) {
      //prepareSnowboy();
      result.success("");
    } else if (call.method.equals("startSnowboy")) {
      recordingThread.startRecording();
      result.success(true);
    } else if (call.method.equals("stopSnowboy")) {
      recordingThread.stopRecording();
      result.success(null);
    } else if (call.method.equals("purgeSnowboy")) {
      recordingThread = null;
      result.success(null);
    } else if (call.method.equals("files")) {
      Log.e("Files", "Context: " + context.toString());
      //String path = Environment.getExternalStorageDirectory().toString();
      String path = context.getFilesDir().getAbsolutePath() + "/snowboy";
      AppResCopy.copyFilesFromAssets(context, Constants.ASSETS_RES_DIR, path, true);
      
      ArrayList fs = new ArrayList();
      fs.add(path);
      fs.add(context.toString());

      // String path = Environment.getExternalStorageDirectory().toString();
      Log.e("Files", "Path: " + path);
      File directory = new File(path);
      fs.add(directory.toString());
      File[] files = directory.listFiles();
            fs.add(files.toString());

      if (files != null) {
      Log.e("Files", "Size: "+ files.length);
      // for (int i = 0; i < files.length; i++)
      // {
      //     Log.e("Files", "FileName:" + files[i].getName());
      // }
      }

      System.loadLibrary("snowboy-detect-android");
      detector = new SnowboyDetect("snowboy/common.res", "snowboy/alexa.umdl");

      result.success(fs);

    } else {
      result.notImplemented();
    }
  }

}
