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
  String buttonTitle  = 'Start detection';
  FlutterSnowboy detector;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    // try {
    // } on PlatformException {
    // }

    detector = FlutterSnowboy();

    await detector.prepare("path/to/model");
  }

  void hotwordHandler() {
    Audio.load('assets/ding.wav')..play()..dispose();
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
