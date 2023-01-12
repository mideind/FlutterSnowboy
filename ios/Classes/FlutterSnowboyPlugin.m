/*
 * Copyright (C) 2021-2023 Miðeind ehf.
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

#import "FlutterSnowboyPlugin.h"
#import "SnowboyDetector.h"

// Snowboy configuration defaults
#define SNOWBOY_DEFAULT_SENSITIVITY 0.5
#define SNOWBOY_DEFAULT_AUDIO_GAIN 1.0
// Should be false for pmdl, true for umdl
#define SNOWBOY_DEFAULT_APPLY_FRONTEND FALSE

@interface FlutterSnowboyPlugin ()
@property(nonatomic, retain) FlutterMethodChannel *channel;
@end

@implementation FlutterSnowboyPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  // Create a channel to communicate with the Flutter app
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:@"plugin_snowboy"
                                  binaryMessenger:[registrar messenger]];
  // Create an instance of the plugin and register it with the channel
  FlutterSnowboyPlugin *instance = [FlutterSnowboyPlugin new];
  instance.channel = channel;
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call
                  result:(FlutterResult)result {
  // Method call handler for Flutter channel
  if ([call.method isEqualToString:@"prepareSnowboy"]) {
    result([NSNumber numberWithBool:[self prepareSnowboy:call result:result]]);
  } else if ([call.method isEqualToString:@"detectSnowboy"]) {
    [self detectSnowboy:call result:result];
  } else if ([call.method isEqualToString:@"purgeSnowboy"]) {
    [self purgeSnowboy:call result:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (BOOL)prepareSnowboy:(FlutterMethodCall *)call result:(FlutterResult)result {

  // First, validate all arguments

  // Model path
  NSString *modelPath = [call.arguments objectAtIndex:0];
  if ([[NSFileManager defaultManager] fileExistsAtPath:modelPath] == FALSE) {
    NSLog(@"No Snowboy model found at path %@", modelPath);
    return FALSE;
  }

  // Sensitivity
  NSNumber *sensitivity = [call.arguments objectAtIndex:1];
  if (sensitivity == nil) {
    sensitivity = [NSNumber numberWithDouble:SNOWBOY_DEFAULT_SENSITIVITY];
  }

  // Audio gain
  NSNumber *audioGain = [call.arguments objectAtIndex:2];
  if (audioGain == nil) {
    audioGain = [NSNumber numberWithDouble:SNOWBOY_DEFAULT_AUDIO_GAIN];
  }

  // Frontend processing (should only be enabled for umdl models)
  NSNumber *applyFrontend = [call.arguments objectAtIndex:3];
  if (applyFrontend == nil) {
    audioGain = [NSNumber numberWithBool:SNOWBOY_DEFAULT_APPLY_FRONTEND];
  }

  // Initialize detector instance
  return [[SnowboyDetector sharedInstance] prepare:modelPath
                                       sensitivity:[sensitivity doubleValue]
                                         audioGain:[audioGain doubleValue]
                                     applyFrontend:[applyFrontend boolValue]];
}

- (void)detectSnowboy:(FlutterMethodCall *)call result:(FlutterResult)result {
  // Make sure detector is initialized
  if ([[SnowboyDetector sharedInstance] inited] == FALSE) {
    NSLog(@"Attempt to run detector on data prior to initialization!");
    return;
  }

  // Pass audio data to SnowboyDetector instance
  NSArray *args = call.arguments;
  FlutterStandardTypedData *typedData = [args objectAtIndex:0];
  NSData *audioData = [typedData data];
  [[SnowboyDetector sharedInstance] detect:audioData channel:self.channel];
}

- (void)purgeSnowboy:(FlutterMethodCall *)call result:(FlutterResult)result {
  // Release all resources used by detector
  [[SnowboyDetector sharedInstance] purge];
}

@end
