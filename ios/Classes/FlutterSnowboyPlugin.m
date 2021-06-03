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

#import "FlutterSnowboyPlugin.h"
#import "SnowboyDetector.h"

@implementation FlutterSnowboyPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel methodChannelWithName:@"flutter_snowboy"
                                                                binaryMessenger:[registrar messenger]];
    FlutterSnowboyPlugin* instance = [FlutterSnowboyPlugin new];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([call.method isEqualToString:@"prepareSnowboy"]) {
        // TODO: Pass params to prepare: function
        // [self prepare:modelName sensitivity:sensitivity audioGain:audioGain applyFrontend:applyFrontend]
        result(NULL);
    } else if ([call.method isEqualToString:@"startSnowboy"]) {
        result([self start]);
    } else if ([call.method isEqualToString:@"stopSnowboy"]) {
        result([self stop]);
    } else if ([call.method isEqualToString:@"purgeSnowboy"]) {
        result([self purge]);
    } else if ([call.method isEqualToString:@"getSnowboyState"]) {
        result([self state]);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (BOOL)prepare:(NSString *)modelName sensitivity:(NSNumber *)sensitivity
audioGain:(NSNumber *)audioGain applyFrontend:(BOOL)applyFrontend {
    [[SnowboyDetector sharedInstance] setUpDetector];
}

- (void)start:(void (^nullability)(void))hotwordHandler {
    [[SnowboyDetector sharedInstance] startListening];
}

- (void)stop {
    [[SnowboyDetector sharedInstance] stopListening];
}

- (void)purge {
    [[SnowboyDetector sharedInstance] purge];
}

- (int)state {
    return [[SnowboyDetector sharedInstance] state];
}

@end
