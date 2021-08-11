[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Build](https://github.com/mideind/flutter_snowboy/actions/workflows/main.yml/badge.svg)]()

# Flutter Snowboy plugin

*This is __alpha__ quality software. Caveat emptor!*

This repository contains the source code to a Flutter Snowboy package.
[Snowboy](https://github.com/seasalt-ai/snowboy) is a cross-platform
DNN-based hotword detection toolkit.

The plugin currently only supports Android but iOS support is under way.

## Models

The Flutter Snowboy package requires a working Snowboy detection model. To train
your own model, clone [this repo](https://github.com/seasalt-ai/snowboy) and
follow the instructions.

## How to use

### Initialize

```dart
import 'package:flutter_snowboy/flutter_snowboy.dart';

...

// Instantiate
var detector = Snowboy();

// Load model and other resources.
// This is a moderately expensive operation since it involves file I/O.
var success = detector.prepare("/absolute/path/to/model.pmdl");

```

### Start

```dart
void hwHandler() {
    print("Hotword detected");
}

detector.hotwordHandler = hwHandler;

// ... get audio data as UInt8List

detector.detect(data);

// ... and hwHandler() gets called when the hotword is detected.
```

## Contributing

All contributions are welcome. If you would like to lend and hand, feel free to
fork this repository and open pull requests to your heart's content.

## License

flutter_snowboy is Copyright (C) 2021 [Miðeind ehf.](https://mideind.is)  
Snowboy is Copyright (C) 2016-2020 KITT.AI

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0) or [here](LICENSE.txt)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
