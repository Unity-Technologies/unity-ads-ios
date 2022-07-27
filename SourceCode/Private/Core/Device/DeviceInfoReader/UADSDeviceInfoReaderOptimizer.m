#import "UADSDeviceInfoReaderOptimizer.h"
#import "WKWebView+UserAgent.h"
#import <AVFoundation/AVFoundation.h>
#import "UADSUserAgentStorage.h"
#import "UADSServiceProvider.h"
@interface UADSDeviceInfoReaderOptimizer ()
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) UADSUserAgentStorage *userAgentReader;
@end

@implementation UADSDeviceInfoReaderOptimizer
- (instancetype)init {
    SUPER_INIT;
    self.queue = dispatch_queue_create("com.unity3d.ads.UADSDeviceInfoReaderOptimizer", DISPATCH_QUEUE_SERIAL);
    return self;
}

- (void)startOptimization {
    dispatch_async(_queue, ^{
        [self optimize];
    });
}

- (void)optimize {
    [self prepareUserAgent];
    [self prepareAudioSession];
}

- (void)prepareUserAgent {
    dispatch_on_main_sync(^{
        [self.userAgentReader generateAndSaveIfNeed];
    });
}

- (void)prepareAudioSession {
    [AVAudioSession sharedInstance];
}

@end
