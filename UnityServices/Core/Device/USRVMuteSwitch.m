#import "USRVMuteSwitch.h"
#import "USRVWebViewApp.h"
#import "USRVWebViewEventCategory.h"

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

- (void)detectMuteSwitch {
#if TARGET_IPHONE_SIMULATOR
    // The simulator doesn't support detection and can cause a crash so always return not muted
    if ([USRVWebViewApp getCurrentApp]) {
        [[USRVWebViewApp getCurrentApp] sendEvent:@"MUTE_STATE_RECEIVED"
                                         category:USRVNSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryDeviceInfo)
                                           param1:[NSNumber numberWithBool:NO], nil];
    }
    return;
#else
    CFStringRef state;
    UInt32 propertySize = sizeof(CFStringRef);
    AudioSessionInitialize(NULL, NULL, NULL, NULL);
    AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &propertySize, &state);
    BOOL muteState = YES;
    if(CFStringGetLength(state) > 0) {
        muteState = NO;
    }
    if ([USRVWebViewApp getCurrentApp]) {
        [[USRVWebViewApp getCurrentApp] sendEvent:@"MUTE_STATE_RECEIVED"
                                         category:USRVNSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryDeviceInfo)
                                           param1:[NSNumber numberWithBool:muteState], nil];
    }
    return;
#endif
}

@end
