#import "USRVDevice.h"
#import "USRVMuteSwitch.h"
#import "USRVMuteSwitchDetectionAiff.h"
#import "USRVWebViewApp.h"
#import "USRVWebViewEventCategory.h"

@interface USRVMuteSwitch ()
@property (nonatomic, assign) CFTimeInterval startTime;
@property (nonatomic, assign) bool fileCreated;
@end

/**
 * Function called once audio playback completes
 */
static void soundCompletionCallback(SystemSoundID soundId, void *myself) {
    AudioServicesRemoveSystemSoundCompletion(soundId);
    AudioServicesDisposeSystemSoundID(soundId);
    [[USRVMuteSwitch sharedInstance] playbackComplete];
}

@implementation USRVMuteSwitch

+ (USRVMuteSwitch *)sharedInstance {
    static USRVMuteSwitch *muteSwitch;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        muteSwitch = [[USRVMuteSwitch alloc] init];
    });
    return muteSwitch;
}

- (id)init {
    self = [super init];

    if (self) {
    }

    return self;
}

- (NSString *)getMuteDetectionFilePath {
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent: @"MuteSwitchDetection.aiff"];
}

- (bool)writeToMuteDetectionPath: (NSString *)filePath {
    NSLog(@"MuteSwitch: Attempting to write bytes to file");

    @try {
        NSData *muteFileData = [[NSData alloc] initWithBytesNoCopy: MuteSwitchDetection_aiff
                                                            length: MuteSwitchDetection_aiff_len
                                                      freeWhenDone: NO];
        [muteFileData writeToFile: filePath
                       atomically: YES];
    } @catch (NSException *exception) {
        NSLog(@"MuteSwitch: File creation failed.");
        self.fileCreated = NO;
        return NO;
    }

    NSLog(@"MuteSwitch: File creation successful");
    self.fileCreated = YES;
    return YES;
}

- (void)playbackComplete {
    CFTimeInterval soundDurationInMs = (CACurrentMediaTime() * 1000) - self.startTime;
    int mutedMaximumDurationThresholdInMs = 100;

    // Return mute state to true if sound playback duration is less than 100ms
    if (soundDurationInMs < mutedMaximumDurationThresholdInMs) {
        [[USRVMuteSwitch sharedInstance] sendMuteState: YES];
    } else {
        [[USRVMuteSwitch sharedInstance] sendMuteState: NO];
    }
}

- (void)sendMuteState: (bool)muteState {
    NSLog(@"MuteSwitch: Device mute state detected to be %@", muteState ? @"true" : @"false");

    if ([USRVWebViewApp getCurrentApp]) {
        [[USRVWebViewApp getCurrentApp] sendEvent: @"MUTE_STATE_RECEIVED"
                                         category: USRVNSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryDeviceInfo)
                                           param1: [NSNumber numberWithBool: muteState], nil];
    }
}

- (void)detectMuteSwitch {
    if ([USRVDevice isSimulator]) {
        [[USRVMuteSwitch sharedInstance] sendMuteState: NO];
        return;
    }

    CFURLRef cfUrlpath = NULL;
    NSString *filePath = [self getMuteDetectionFilePath];

    // Sets the updated CFURLRef if the file has been created yet. Otherwise attempts to create the file
    if (self.fileCreated || [self writeToMuteDetectionPath: filePath]) {
        cfUrlpath = (__bridge CFURLRef)[NSURL URLWithString: filePath];
    }

    if (cfUrlpath == NULL) {
        [[USRVMuteSwitch sharedInstance] sendMuteState: NO];
        return;
    }

    SystemSoundID soundId;

    AudioServicesCreateSystemSoundID(cfUrlpath, &soundId);
    AudioServicesAddSystemSoundCompletion(soundId, NULL, NULL, soundCompletionCallback, NULL);

    // Mark the starting time and begin sound playback
    self.startTime = CACurrentMediaTime() * 1000;
    AudioServicesPlaySystemSound(soundId);

    return;
} /* detectMuteSwitch */

@end
