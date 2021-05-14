[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

# Flutter Snowboy plugin

*This plugin is a work in progress. Things may not work.*

This repository contains the source code to a Flutter Snowboy package.
[Snowboy](https://github.com/seasalt-ai/snowboy) is a cross-platform
DNN-based hotword detection toolkit.

Currently only supports Android.

## Models

The Flutter Snowboy package ships with a default hotword model, "Alexa". To 
train your own model, clone [this repo](https://github.com/seasalt-ai/snowboy)
and follow the instructions.

## How to use

### Initialize

```dart
import 'package:flutter_snowboy/flutter_snowboy.dart';

...

// Instantiate
var detector = Snowboy();

// Load model and other resources.
// This is a moderately expensive operation since it involves file I/O.
var success = detector.prepare(modelPath="/absolute/path/to/model.pmdl");

// If you just want to load the default "Alexa" model:
var success = detector.prepare();
```

### Start

```dart
void hotwordHandler() {
    print("Hotword detected");
}

var started = detector.start(hotwordHandler);
```

### Stop

```dart
detector.stop();

// If you're done using it, you should clean
// up Snowboy-related resources.
detector.purge();
```

### Get state

```dart
/*
enum SnowboyStatus {
  instantiated,
  prepared,
  running,
  purged,
  error
}
*/

SnowboyState s = detector.state();
if (s != SnowboyState.prepared) {
    detector.prepare();
}
detector.start();

```

## License

Copyright (C) 2021 Miðeind ehf.  
Copyright (C) 2016-2020 KITT.AI

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0) or [here](LICENSE.txt)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
