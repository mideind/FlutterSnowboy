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

#import "Common.h"
#import "SnowboyDetector.h"
#import <Snowboy/Snowboy.h>

// Snowboy detector configuration
#define SNOWBOY_MODEL_NAME      @"hae_embla"
#define SNOWBOY_SENSITIVITY     "0.5"
#define SNOWBOY_AUDIO_GAIN      1.0
#define SNOWBOY_APPLY_FRONTEND  false  // Should be false for pmdl, true for umdl

@interface SnowboyDetector()
{
    snowboy::SnowboyDetect* _snowboyDetect;
}
@property (weak) id <HotwordDetectorDelegate>delegate;
@property (readonly) BOOL isListening;
@property BOOL inited;

@end

@implementation SnowboyDetector

+ (instancetype)sharedInstance {
    static SnowboyDetector *instance = nil;
    if (!instance) {
        instance = [self new];
    }
    return instance;
}

- (BOOL)startListening {
    // TODO: Maybe re-initialise every time listening is resumed?
    if (!self.inited) {
        DLog(@"Initing Snowboy hotword detector");
        _snowboyDetect = NULL;
        
        NSString *commonPath = [[NSBundle mainBundle] pathForResource:@"common" ofType:@"res"];
        NSString *modelPath = [[NSBundle mainBundle] pathForResource:SNOWBOY_MODEL_NAME ofType:@"umdl"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:commonPath] ||
            ![[NSFileManager defaultManager] fileExistsAtPath:modelPath]) {
            DLog(@"Unable to init Snowboy, bundle resources missing");
            return FALSE;
        }
        
        // Create and configure Snowboy C++ detector object
        _snowboyDetect = new snowboy::SnowboyDetect(std::string([commonPath UTF8String]),
                                                    std::string([modelPath UTF8String]));
        _snowboyDetect->SetSensitivity(SNOWBOY_SENSITIVITY);
        _snowboyDetect->SetAudioGain(SNOWBOY_AUDIO_GAIN);
        _snowboyDetect->ApplyFrontend(SNOWBOY_APPLY_FRONTEND);
        
        [[AudioRecordingService sharedInstance] prepare];
        
        // Start listening
        self.inited = TRUE;
    }
    
    [self _startListening];
    
    _isListening = TRUE;
    
    return TRUE;
}

- (void)_startListening {
    [[AudioRecordingService sharedInstance] setDelegate:self];
    [[AudioRecordingService sharedInstance] start];
}

- (void)stopListening {
    [[AudioRecordingService sharedInstance] stop];
    _isListening = FALSE;
}

- (void)processSampleData:(NSData *)data {
    dispatch_async(dispatch_get_main_queue(),^{
        const int16_t *bytes = (int16_t *)[data bytes];
        const int len = (int)[data length]/2; // 16-bit audio
        int result = _snowboyDetect->RunDetection((const int16_t *)bytes, len);
        if (result == 1) {
            DLog(@"Snowboy: Hotword detected");
            if (self.delegate) {
                [self.delegate didHearHotword:SNOWBOY_MODEL_NAME];
            }
        }
    });
}

@end
