/*
 * Copyright (C) 2021-2022 Miðeind ehf.
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

#import <Flutter/Flutter.h>
#import <Foundation/Foundation.h>

typedef void (^SnowboyDetectorBlock)(void);

@interface SnowboyDetector : NSObject

+ (instancetype)sharedInstance;
- (BOOL)prepare:(NSString *)modelPath
      sensitivity:(double)sensitivity
        audioGain:(double)audioGain
    applyFrontend:(BOOL)applyFrontend;
- (void)detect:(NSData *)audioData channel:(FlutterMethodChannel *)channel;
- (void)purge;
- (BOOL)inited;

@end
