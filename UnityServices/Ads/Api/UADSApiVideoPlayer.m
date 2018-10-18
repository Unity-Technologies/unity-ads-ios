#import "UADSApiVideoPlayer.h"
#import "USRVWebViewCallback.h"
#import "UADSApiAdUnit.h"
#import "UADSVideoPlayerHandler.h"

typedef NS_ENUM(NSInteger, UnityAdsVideoPlayerError) {
    kUnityAdsVideoViewNull,
    kUnityAdsVideoViewReflectionError
};

NSString *NSStringFromVideoPlayerError(UnityAdsVideoPlayerError error) {
    switch (error) {
        case kUnityAdsVideoViewNull:
            return @"VIDEOVIEW_NULL";
        case kUnityAdsVideoViewReflectionError:
            return @"REFLECTION_ERROR";
    }
}

@implementation UADSApiVideoPlayer

+ (void)WebViewExposed_setProgressEventInterval:(NSNumber *)milliseconds callback:(USRVWebViewCallback *)callback {
    if ([UADSApiVideoPlayer getVideoPlayer]) {
        [[UADSApiVideoPlayer getVideoPlayer] setProgressEventInterval:[milliseconds intValue]];
        [callback invoke:nil];
    }
    else {
        [callback error:NSStringFromVideoPlayerError(kUnityAdsVideoViewNull) arg1:nil];
    }
}

+ (void)WebViewExposed_getProgressEventInterval:(USRVWebViewCallback *)callback {
    if ([UADSApiVideoPlayer getVideoPlayer]) {
        [callback invoke:[NSNumber numberWithInt:[[UADSApiVideoPlayer getVideoPlayer] progressInterval]], nil];
    }
    else {
        [callback error:NSStringFromVideoPlayerError(kUnityAdsVideoViewNull) arg1:nil];
    }
}

+ (void)WebViewExposed_prepare:(NSString *)url initialVolume:(NSNumber *)initialVolume timeout:(NSNumber *)timeout callback:(USRVWebViewCallback *)callback {
    if ([UADSApiVideoPlayer getVideoPlayer]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UADSApiVideoPlayer getVideoPlayer] prepare:url initialVolume:[initialVolume floatValue] timeout:[timeout integerValue]];
        });
        
        [callback invoke:nil];
    }
    else {
        [callback error:NSStringFromVideoPlayerError(kUnityAdsVideoViewNull) arg1:nil];
    }
}

+ (void)WebViewExposed_play:(USRVWebViewCallback *)callback {
    if ([UADSApiVideoPlayer getVideoPlayer]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UADSApiVideoPlayer getVideoPlayer] play];
        });

        [callback invoke:nil];
    }
    else {
        [callback error:NSStringFromVideoPlayerError(kUnityAdsVideoViewNull) arg1:nil];
    }
}

+ (void)WebViewExposed_pause:(USRVWebViewCallback *)callback {
    if ([UADSApiVideoPlayer getVideoPlayer]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UADSApiVideoPlayer getVideoPlayer] pause];
        });

        [callback invoke:nil];
    }
    else {
        [callback error:NSStringFromVideoPlayerError(kUnityAdsVideoViewNull) arg1:nil];
    }
}

+ (void)WebViewExposed_stop:(USRVWebViewCallback *)callback {
    if ([UADSApiVideoPlayer getVideoPlayer]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UADSApiVideoPlayer getVideoPlayer] pause];
            Float64 t_ms = 0;
            CMTime time = CMTimeMakeWithSeconds(t_ms, 30);
            [[UADSApiVideoPlayer getVideoPlayer] seekToTime:time completionHandler:^(BOOL finished) {
            }];
        });

        [callback invoke:nil];
    }
    else {
        [callback error:NSStringFromVideoPlayerError(kUnityAdsVideoViewNull) arg1:nil];
    }
}

+ (void)WebViewExposed_seekTo:(NSNumber *)time callback:(USRVWebViewCallback *)callback {
    if ([UADSApiVideoPlayer getVideoPlayer]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UADSApiVideoPlayer getVideoPlayer] seekTo:[time longValue]];
        });

        [callback invoke:nil];
    }
    else {
        [callback error:NSStringFromVideoPlayerError(kUnityAdsVideoViewNull) arg1:nil];
    }
}

+ (void)WebViewExposed_setVolume:(NSNumber *)volume callback:(USRVWebViewCallback *)callback {
    if ([UADSApiVideoPlayer getVideoPlayer]) {
        [[UADSApiVideoPlayer getVideoPlayer] setVolume:[volume floatValue]];
        [callback invoke:nil];
    }
    else {
        [callback error:NSStringFromVideoPlayerError(kUnityAdsVideoViewNull) arg1:nil];
    }
}

+ (void)WebViewExposed_getVolume:(USRVWebViewCallback *)callback {
    if ([UADSApiVideoPlayer getVideoPlayer]) {
        [callback invoke:[NSNumber numberWithFloat:[[UADSApiVideoPlayer getVideoPlayer] volume]], nil];
    }
    else {
        [callback error:NSStringFromVideoPlayerError(kUnityAdsVideoViewNull) arg1:nil];
    }
}

+ (void)WebViewExposed_getCurrentPosition:(USRVWebViewCallback *)callback {
    if ([UADSApiVideoPlayer getVideoPlayer]) {
        [callback invoke:[NSNumber numberWithLong:[[UADSApiVideoPlayer getVideoPlayer] getCurrentPosition]], nil];
    }
    else {
        [callback error:NSStringFromVideoPlayerError(kUnityAdsVideoViewNull) arg1:nil];
    }
}

+ (void)WebViewExposed_setAutomaticallyWaitsToMinimizeStalling:(NSNumber *)waits callback:(USRVWebViewCallback *)callback {
    if ([UADSApiVideoPlayer getVideoPlayer]) {
        SEL waitsSelector = NSSelectorFromString(@"setAutomaticallyWaitsToMinimizeStalling:");
        if ([[UADSApiVideoPlayer getVideoPlayer] respondsToSelector:waitsSelector]) {
            IMP waitsImp = [[UADSApiVideoPlayer getVideoPlayer] methodForSelector:waitsSelector];
            if (waitsImp) {
                void (*waitsFunc)(id, SEL, BOOL) = (void *)waitsImp;
                waitsFunc([UADSApiVideoPlayer getVideoPlayer], waitsSelector, [waits boolValue]);
                [callback invoke:nil];
                return;
            }
        }

        [callback error:NSStringFromVideoPlayerError(kUnityAdsVideoViewReflectionError) arg1:nil];
    }
    else {
        [callback error:NSStringFromVideoPlayerError(kUnityAdsVideoViewNull) arg1:nil];
    }
}

+ (UADSAVPlayer *)getVideoPlayer {
    if ([UADSApiAdUnit getAdUnit] && [[UADSApiAdUnit getAdUnit] getViewHandler:@"videoplayer"]) {
        return [(UADSVideoPlayerHandler *)[[UADSApiAdUnit getAdUnit] getViewHandler:@"videoplayer"] videoPlayer];
    }
    
    return NULL;
}

@end
