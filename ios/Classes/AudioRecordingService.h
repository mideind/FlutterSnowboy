/*
 * Copyright (C) 2021 Miðeind ehf.
 * Adapted from Apache 2-licensed code Copyright (C) 2016 Google Inc.
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
#import <Foundation/Foundation.h>

@protocol AudioRecordingServiceDelegate <NSObject>

- (void)processSampleData:(NSData *)data;

@end

@interface AudioRecordingService : NSObject

@property(nonatomic, weak) id<AudioRecordingServiceDelegate> delegate;

+ (instancetype)sharedInstance;

- (OSStatus)prepare;
- (OSStatus)prepareWithSampleRate:(double)sampleRate;
- (OSStatus)start;
- (OSStatus)stop;

@end
