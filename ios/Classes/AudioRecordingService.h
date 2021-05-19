/*
 * This file is part of the Embla iOS app
 * Copyright (c) 2019-2021 Miðeind ehf.
 * Author: Sveinbjorn Thordarson
 * Adapted from Apache 2-licensed code Copyright (C) 2016 Google Inc.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
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
