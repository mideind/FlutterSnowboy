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

// Example application demonstrating use of the Flutter Snowboy plugin.

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_snowboy/flutter_snowboy.dart';
import 'package:audiofileplayer/audiofileplayer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool running = false;
  int numDetected = 0;
  String status = "Snowboy is not running";
  String buttonTitle = 'Start detection';
  Snowboy detector;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      detector = Snowboy();
      await detector.prepare(modelPath: "path/to/model");
    } on PlatformException {}
  }

  void hotwordHandler() {
    Audio.load('assets/ding.wav')
      ..play()
      ..dispose();
    setState(() {
      numDetected += 1;
    });
  }

  void buttonPressed() {
    String s;
    String t;
    bool r;

    if (running == false) {
      detector.start(hotwordHandler);
      s = "Snowboy is running";
      t = "Stop detection";
      r = true;
    } else {
      detector.stop();
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
          title: const Text('Flutter Snowboy example app'),
        ),
        body: Center(
          child: Column(children: <Widget>[
            MaterialButton(
              minWidth: double.infinity,
              child: Text(buttonTitle,
                  style: TextStyle(
                    fontSize: 30.0,
                  )),
              onPressed: buttonPressed,
            ),
            Text(status,
                style: TextStyle(
                  fontSize: 20.0,
                )),
            Text('Hotword heard $numDetected times',
                style: TextStyle(
                  fontSize: 20.0,
                )),
          ]),
        ),
      ),
    );
  }
}
