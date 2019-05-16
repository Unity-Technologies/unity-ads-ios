#import "USRVVolumeChange.h"
#import <AVFoundation/AVFoundation.h>

@implementation USRVVolumeChange

static NSMutableArray<id<USRVVolumeChangeDelegate>> *delegates;
static void *volumeChangeContext = &volumeChangeContext;
static USRVVolumeChange *observer = NULL;

+ (void)startObserving {
    if (observer) {
        return;
    }
    
    observer = [[USRVVolumeChange alloc] init];
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

+ (void)registerDelegate:(id<USRVVolumeChangeDelegate>)delegate {
    if (!delegates) {
        delegates = [[NSMutableArray alloc] init];
    }
    
    if (![delegates containsObject:delegate]) {
        [USRVVolumeChange startObserving];
        [delegates addObject:delegate];
    }
}

+ (void)unregisterDelegate:(id<USRVVolumeChangeDelegate>)delegate {
    if (delegates) {
        [delegates removeObject:delegate];
    }
    
    if (!delegates || [delegates count] == 0) {
        [USRVVolumeChange stopObserving];
    }
}

+ (void)clearAllDelegates {
    if (delegates) {
        [delegates removeAllObjects];
        delegates = NULL;
    }
    
    [USRVVolumeChange stopObserving];
}

+ (void)triggerDelegates:(float)newVolume {
    if (delegates) {
        for (id<USRVVolumeChangeDelegate> delegate in delegates) {
            if ([delegate respondsToSelector:@selector(onVolumeChanged:)]) {
                [delegate onVolumeChanged:newVolume];
            }
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == volumeChangeContext) {
        CGFloat newVolume = [change[NSKeyValueChangeNewKey] floatValue];
        [USRVVolumeChange triggerDelegates:newVolume];
    }
}

@end
