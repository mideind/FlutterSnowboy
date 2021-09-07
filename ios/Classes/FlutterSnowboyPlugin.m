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

// Snowboy default configuration
#define SNOWBOY_DEFAULT_SENSITIVITY     "0.5"
#define SNOWBOY_DEFAULT_AUDIO_GAIN      1.0
#define SNOWBOY_DEFAULT_APPLY_FRONTEND  false  // Should be false for pmdl, true for umdl


@implementation FlutterSnowboyPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    FlutterMethodChannel *channel = [FlutterMethodChannel methodChannelWithName:@"flutter_snowboy"
                                                                binaryMessenger:[registrar messenger]];
    FlutterSnowboyPlugin *instance = [FlutterSnowboyPlugin new];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([call.method isEqualToString:@"prepareSnowboy"]) {
        [self prepareSnowboy:call result:result];
    } else if ([call.method isEqualToString:@"detectSnowboy"]) {
        [self detectSnowboy:call result:result];
    } else if ([call.method isEqualToString:@"purgeSnowboy"]) {
        [self purgeSnowboy:call result:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (BOOL)prepareSnowboy:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *modelPath = call.arguments[@"modelPath"];
    NSNumber *sensitivity = call.arguments[@"sensitivity"];
    NSNumber *audioGain = call.arguments[@"audioGain"];
    NSNumber *applyFrontend = call.arguments[@"applyFrontend"];

    return [[SnowboyDetector sharedInstance] prepare:modelPath
                                         sensitivity:[sensitivity doubleValue]
                                           audioGain:[audioGain doubleValue]
                                       applyFrontend:[applyFrontend boolValue]];
}

- (BOOL)detectSnowboy:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSArray *args = call.arguments;
    FlutterStandardTypedData *data = [args objectAtIndex:0];
    return YES;
}

- (BOOL)purgeSnowboy:(FlutterMethodCall *)call result:(FlutterResult)result {
    return YES;
}

@end
