/*
 * This file is part of the Embla iOS app
 * Copyright (c) 2019-2021 Miðeind ehf.
 * Author: Sveinbjorn Thordarson
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
    Singleton wrapper class around OpenEars' Pocketsphinx local speech recognition
    used for hotword activation ("Hæ Embla"/"Hey Embla"). Currently uses an English
    language acoustic model with custom phonemes. Going forward, this should
    probably be replaced with a robust local neural network trained on a large set
    of activation phrase recordings. Reliability is currently much poorer than Siri's.
*/

#import "Common.h"
#import "SnowboyDetector.h"
#import "snowboy-detect.h"

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
