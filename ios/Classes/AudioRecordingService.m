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

/*
    Singleton wrapper class for Core Audio recording sessions.
*/

#import <AVFoundation/AVFoundation.h>
#import "AudioRecordingService.h"
#import "Common.h"

@interface AudioRecordingService ()
{
    AudioComponentInstance remoteIOUnit;
    BOOL audioComponentInitialized;
}
@end

@implementation AudioRecordingService

+ (instancetype)sharedInstance {
    static AudioRecordingService *instance = nil;
    if (!instance) {
        instance = [self new];
    }
    return instance;
}

- (void)dealloc {
    if (remoteIOUnit) {
        AudioComponentInstanceDispose(remoteIOUnit);
    }
}

#pragma mark - CoreAudio Callback

// Generate clean error message using 4 char codes if appropriate
static OSStatus CheckError(OSStatus error, const char *operation) {
    if (error == noErr) {
        return error;
    }
    char errorString[20];
    // See if it appears to be a 4-char-code
    *(UInt32 *)(errorString + 1) = CFSwapInt32HostToBig(error);
    if (isprint(errorString[1]) && isprint(errorString[2]) && isprint(errorString[3]) && isprint(errorString[4])) {
        errorString[0] = errorString[5] = '\'';
        errorString[6] = '\0';
    } else {
        // No, format it as an integer
        sprintf(errorString, "%d", (int)error);
    }
    fprintf(stderr, "Error: %s (%s)\n", operation, errorString);
    return error;
}

// Callback invoked when audio data is received from the input source
static OSStatus RecordingCallback(void *inRefCon,
                                  AudioUnitRenderActionFlags *ioActionFlags,
                                  const AudioTimeStamp *inTimeStamp,
                                  UInt32 inBusNumber,
                                  UInt32 inNumberFrames,
                                  AudioBufferList *ioData) {
    OSStatus status;
    
    AudioRecordingService *audioController = (__bridge AudioRecordingService *)inRefCon;
    
    int channelCount = 1;
    
    // Build the AudioBufferList structure
    AudioBufferList *bufferList = (AudioBufferList *)malloc(sizeof(AudioBufferList));
    bufferList->mNumberBuffers = channelCount;
    bufferList->mBuffers[0].mNumberChannels = channelCount;
    bufferList->mBuffers[0].mDataByteSize = inNumberFrames * 2; // 16-bit audio
    bufferList->mBuffers[0].mData = NULL;
    
    // Get the recorded samples
    status = AudioUnitRender(audioController->remoteIOUnit, ioActionFlags, inTimeStamp, inBusNumber, inNumberFrames, bufferList);
    if (status != noErr) {
        free(bufferList);
        return status;
    }
    
    // Create NSData object from audio buffer and send to delegate
    NSData *data = [[NSData alloc] initWithBytesNoCopy:bufferList->mBuffers[0].mData
                                                length:bufferList->mBuffers[0].mDataByteSize
                                          freeWhenDone:NO];
    free(bufferList);
    
    // Notify delegate on main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        [audioController.delegate processSampleData:data];
    });
    
    return noErr;
}

#pragma mark - Initialization

- (OSStatus)prepare {
    return [self prepareWithSampleRate:REC_SAMPLE_RATE];
}

// Configure audio recording session
- (OSStatus)prepareWithSampleRate:(double)specifiedSampleRate {
    OSStatus status = noErr;
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    
    // Set up audio session for recording and playback.
    [session setMode:AVAudioSessionModeDefault error:nil];
    NSError *error;
    AVAudioSessionCategoryOptions opts = \
    AVAudioSessionCategoryOptionDefaultToSpeaker
    |AVAudioSessionCategoryOptionAllowBluetooth
    |AVAudioSessionCategoryOptionAllowBluetoothA2DP;
    
    BOOL ok = [session setCategory:AVAudioSessionCategoryPlayAndRecord
                       withOptions:opts
                             error:&error];
    if (!ok) {
        DLog(@"Failed to change audio session category: %@", [error localizedDescription]);
    }
    [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
    
    // Buffer configuration breaks audio via Bluetooth and should not be set!
    // [session setPreferredIOBufferDuration:10 error:&error];
    
    double sampleRate = session.sampleRate;
    DLog(@"Hardware sample rate = %f, using specified rate = %f", sampleRate, specifiedSampleRate);
    sampleRate = specifiedSampleRate;
    if (!audioComponentInitialized) {
        audioComponentInitialized = YES;
        // Describe the RemoteIO unit
        AudioComponentDescription audioComponentDescription;
        audioComponentDescription.componentType = kAudioUnitType_Output;
        audioComponentDescription.componentSubType = kAudioUnitSubType_RemoteIO;
        audioComponentDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
        audioComponentDescription.componentFlags = 0;
        audioComponentDescription.componentFlagsMask = 0;
        
        // Get the RemoteIO unit
        AudioComponent remoteIOComponent = AudioComponentFindNext(NULL, &audioComponentDescription);
        status = AudioComponentInstanceNew(remoteIOComponent, &(self->remoteIOUnit));
        if (CheckError(status, "Couldn't get RemoteIO unit instance")) {
            return status;
        }
    }
    
    UInt32 oneFlag = 1;
//    AudioUnitElement bus0 = 0;
    AudioUnitElement bus1 = 1;
    
    // Configure the RemoteIO unit for input
    status = AudioUnitSetProperty(self->remoteIOUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, bus1,
                                  &oneFlag, sizeof(oneFlag));
    if (CheckError(status, "Couldn't enable RemoteIO input")) {
        return status;
    }
    
    AudioStreamBasicDescription asbd;
    memset(&asbd, 0, sizeof(asbd));
    asbd.mSampleRate = sampleRate;
    asbd.mFormatID = kAudioFormatLinearPCM;
    asbd.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    asbd.mBytesPerPacket = 2;
    asbd.mFramesPerPacket = 1;
    asbd.mBytesPerFrame = 2;
    asbd.mChannelsPerFrame = 1;
    asbd.mBitsPerChannel = 16;
    
    // Set format for output (bus 0) on the RemoteIO's input scope
//    status = AudioUnitSetProperty(self->remoteIOUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, bus0,
//                                  &asbd, sizeof(asbd));
//    if (CheckError(status, "Couldn't set the ASBD for RemoteIO on input scope/bus 0")) {
//        return status;
//    }
    
    // Set format for mic input (bus 1) on RemoteIO's output scope
    status = AudioUnitSetProperty(self->remoteIOUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, bus1,
                                  &asbd, sizeof(asbd));
    if (CheckError(status, "Couldn't set the ASBD for RemoteIO on output scope/bus 1")) {
        return status;
    }
    
    // Set the recording callback
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = RecordingCallback;
    callbackStruct.inputProcRefCon = (__bridge void *)self;
    status = AudioUnitSetProperty(self->remoteIOUnit, kAudioOutputUnitProperty_SetInputCallback, kAudioUnitScope_Global,
                                  bus1, &callbackStruct, sizeof(callbackStruct));
    if (CheckError(status, "Couldn't set RemoteIO's render callback on bus 0")) {
        return status;
    }
    
    // Initialize the RemoteIO unit
    status = AudioUnitInitialize(self->remoteIOUnit);
    if (CheckError(status, "Couldn't initialize the RemoteIO unit")) {
        return status;
    }
    
    return status;
}

#pragma mark -

// Start recording session
- (OSStatus)start {
    return AudioOutputUnitStart(self->remoteIOUnit);
}

// Stop recording session
- (OSStatus)stop {
    return AudioOutputUnitStop(self->remoteIOUnit);
}

@end
