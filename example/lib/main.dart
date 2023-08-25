/*
 * flutter_snowboy - Flutter package wrapper for Snowboy hotword detection.
 *
 * Copyright 2021-2023 Miðeind ehf.
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

// Example application demonstrating use of the Flutter Snowboy plugin.

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:audiofileplayer/audiofileplayer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter_sound/flutter_sound.dart';

import 'package:flutter_snowboy/flutter_snowboy.dart';

const kSampleRate = 16000;
const kNumChannels = 1;

void main() {
  runApp(SnowboyExampleApp());
}

class SnowboyExampleApp extends StatefulWidget {
  @override
  _SnowboyExampleAppState createState() => _SnowboyExampleAppState();
}

class _SnowboyExampleAppState extends State<SnowboyExampleApp> {
  bool running = false;
  int numDetected = 0;
  String status = "Snowboy is not running";
  String buttonTitle = 'Start detection';

  late Snowboy detector;

  FlutterSoundRecorder _micRecorder = FlutterSoundRecorder();
  StreamController? _recordingDataController;
  StreamSubscription? _recordingDataSubscription;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    final String modelPath = await copyModelToFilesystem("hi_embla.pmdl");
    // Create detector object and prepare it
    detector = Snowboy();
    await detector.prepare(modelPath);
    detector.hotwordHandler = hotwordHandler;
    await configureAudioSession();
  }

  Future<void> configureAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.defaultToSpeaker |
              AVAudioSessionCategoryOptions.allowBluetooth,
      //     AVAudioSessionCategoryOptions.duckOthers,
      // avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionMode: AVAudioSessionMode.defaultMode,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));
    await session.setActive(true);
  }

  // Copy model from asset bundle to temp directory on the filesystem
  static Future<String> copyModelToFilesystem(String filename) async {
    final String dir = (await getTemporaryDirectory()).path;
    final String finalPath = "$dir/$filename";
    if (await File(finalPath).exists() == true) {
      // Don't overwrite existing file
      return finalPath;
    }
    ByteData bytes = await rootBundle.load("assets/$filename");
    final buffer = bytes.buffer;
    await File(finalPath).writeAsBytes(
        buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
    return finalPath;
  }

  // Function to invoke when hotword is detected
  void hotwordHandler() {
    // Increment counter
    setState(() {
      numDetected += 1;
    });
    // Play sound
    Audio.load('assets/ding.wav')
      ..play()
      ..dispose();
  }

  Future<void> startDetection() async {
    // Prep recording session
    await _micRecorder.openRecorder();

    // Create recording stream
    _recordingDataController = StreamController<Food>();
    _recordingDataSubscription =
        _recordingDataController?.stream.listen((buffer) {
      // When we get data, feed it into Snowboy detector
      if (buffer is FoodData) {
        Uint8List copy = new Uint8List.fromList(buffer.data!);
        // print("Got audio data (${buffer.data.lengthInBytes} bytes");
        detector.detect(copy);
      }
    });

    // Start recording
    await _micRecorder.startRecorder(
        toStream: _recordingDataController!.sink as StreamSink<Food>,
        codec: Codec.pcm16,
        numChannels: kNumChannels,
        sampleRate: kSampleRate);
  }

  Future<void> stopDetection() async {
    await _micRecorder.stopRecorder();
    await _micRecorder.closeRecorder();
    await _recordingDataSubscription?.cancel();
    await _recordingDataController?.close();
  }

  void toggleHotwordDetection() async {
    String s;
    String t;
    bool r;

    if (running == false) {
      await startDetection();
      s = "Snowboy is running\nSay 'Hi Embla' to trigger hotword handler.";
      t = "Stop detection";
      r = true;
    } else {
      await stopDetection();
      s = "Snowboy is not running";
      t = "Start detection";
      r = false;
    }
    setState(() {
      status = s;
      running = r;
      buttonTitle = t;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Snowboy example'),
        ),
        body: Center(
          child: Column(children: <Widget>[
            Text("\n"),
            MaterialButton(
              minWidth: double.infinity,
              child: Text(buttonTitle,
                  style: TextStyle(
                    fontSize: 30.0,
                  )),
              onPressed: toggleHotwordDetection,
            ),
            Text("\n" + status,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.0,
                )),
            Text('\nHotword heard $numDetected times',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.0,
                )),
          ]),
        ),
      ),
    );
  }
}
