#import "UADSVolumeChange.h"
#import <AVFoundation/AVFoundation.h>

@implementation UADSVolumeChange

static NSMutableArray<id<UADSVolumeChangeDelegate>> *delegates;
static void *volumeChangeContext = &volumeChangeContext;
static UADSVolumeChange *observer = NULL;

+ (void)startObserving {
    if (observer) {
        return;
    }
    
    observer = [[UADSVolumeChange alloc] init];
    [[AVAudioSession sharedInstance] addObserver:observer forKeyPath:@"outputVolume" options:NSKeyValueObservingOptionNew context:volumeChangeContext];
}

+ (void)stopObserving {
    if (observer) {
        @try {
            [[AVAudioSession sharedInstance] removeObserver:observer forKeyPath:@"outputVolume"];
        }
        @catch (NSException * __unused exception) {
        }
        
        observer = NULL;
    }
}

+ (void)registerDelegate:(id<UADSVolumeChangeDelegate>)delegate {
    if (!delegates) {
        delegates = [[NSMutableArray alloc] init];
    }
    
    if (![delegates containsObject:delegate]) {
        [UADSVolumeChange startObserving];
        [delegates addObject:delegate];
    }
}

+ (void)unregisterDelegate:(id<UADSVolumeChangeDelegate>)delegate {
    if (delegates) {
        [delegates removeObject:delegate];
    }
    
    if (!delegates || [delegates count] == 0) {
        [UADSVolumeChange stopObserving];
    }
}

+ (void)clearAllDelegates {
    if (delegates) {
        [delegates removeAllObjects];
        delegates = NULL;
    }
    
    [UADSVolumeChange stopObserving];
}

+ (void)triggerDelegates:(float)newVolume {
    if (delegates) {
        for (id<UADSVolumeChangeDelegate> delegate in delegates) {
            if ([delegate respondsToSelector:@selector(onVolumeChanged:)]) {
                [delegate onVolumeChanged:newVolume];
            }
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == volumeChangeContext) {
        CGFloat newVolume = [change[NSKeyValueChangeNewKey] floatValue];
        [UADSVolumeChange triggerDelegates:newVolume];
    }
}

@end
