#import "UADSApiVideoPlayer.h"
#import "UADSWebViewCallback.h"
#import "UADSApiAdUnit.h"


typedef NS_ENUM(NSInteger, UnityAdsVideoPlayerError) {
    kUnityAdsVideoViewNull
};

NSString *NSStringFromVideoPlayerError(UnityAdsVideoPlayerError error) {
    switch (error) {
        case kUnityAdsVideoViewNull:
            return @"VIDEOVIEW_NULL";
    }
}

@implementation UADSApiVideoPlayer

+ (void)WebViewExposed_setProgressEventInterval:(NSNumber *)milliseconds callback:(UADSWebViewCallback *)callback {
    if ([[UADSApiAdUnit getAdUnit] videoPlayer]) {
        [[[UADSApiAdUnit getAdUnit] videoPlayer] setProgressEventInterval:[milliseconds intValue]];
        [callback invoke:nil];
    }
    else {
        [callback error:NSStringFromVideoPlayerError(kUnityAdsVideoViewNull) arg1:nil];
    }
}

+ (void)WebViewExposed_getProgressEventInterval:(UADSWebViewCallback *)callback {
    if ([[UADSApiAdUnit getAdUnit] videoPlayer]) {
        [callback invoke:[NSNumber numberWithInt:[[[UADSApiAdUnit getAdUnit] videoPlayer] progressInterval]], nil];
    }
    else {
        [callback error:NSStringFromVideoPlayerError(kUnityAdsVideoViewNull) arg1:nil];
    }
}

+ (void)WebViewExposed_prepare:(NSString *)url initialVolume:(NSNumber *)initialVolume callback:(UADSWebViewCallback *)callback {
    if ([[UADSApiAdUnit getAdUnit] videoPlayer]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UADSApiAdUnit getAdUnit] videoPlayer] prepare:url initialVolume:[initialVolume floatValue]];
        });
        
        [callback invoke:nil];
    }
    else {
        [callback error:NSStringFromVideoPlayerError(kUnityAdsVideoViewNull) arg1:nil];
    }
}

+ (void)WebViewExposed_play:(UADSWebViewCallback *)callback {
    if ([[UADSApiAdUnit getAdUnit] videoPlayer]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UADSApiAdUnit getAdUnit] videoPlayer] play];
        });

        [callback invoke:nil];
    }
    else {
        [callback error:NSStringFromVideoPlayerError(kUnityAdsVideoViewNull) arg1:nil];
    }
}

+ (void)WebViewExposed_pause:(UADSWebViewCallback *)callback {
    if ([[UADSApiAdUnit getAdUnit] videoPlayer]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UADSApiAdUnit getAdUnit] videoPlayer] pause];
        });

        [callback invoke:nil];
    }
    else {
        [callback error:NSStringFromVideoPlayerError(kUnityAdsVideoViewNull) arg1:nil];
    }
}

+ (void)WebViewExposed_stop:(UADSWebViewCallback *)callback {
    if ([[UADSApiAdUnit getAdUnit] videoPlayer]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UADSApiAdUnit getAdUnit] videoPlayer] pause];
            Float64 t_ms = 0;
            CMTime time = CMTimeMakeWithSeconds(t_ms, 30);
            [[[UADSApiAdUnit getAdUnit] videoPlayer] seekToTime:time completionHandler:^(BOOL finished) {
            }];
        });

        [callback invoke:nil];
    }
    else {
        [callback error:NSStringFromVideoPlayerError(kUnityAdsVideoViewNull) arg1:nil];
    }
}

+ (void)WebViewExposed_seekTo:(NSNumber *)time callback:(UADSWebViewCallback *)callback {
    if ([[UADSApiAdUnit getAdUnit] videoPlayer]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UADSApiAdUnit getAdUnit] videoPlayer] seekTo:[time intValue]];
        });

        [callback invoke:nil];
    }
    else {
        [callback error:NSStringFromVideoPlayerError(kUnityAdsVideoViewNull) arg1:nil];
    }
}

+ (void)WebViewExposed_setVolume:(NSNumber *)volume callback:(UADSWebViewCallback *)callback {
    if ([[UADSApiAdUnit getAdUnit] videoPlayer]) {
        [[[UADSApiAdUnit getAdUnit] videoPlayer] setVolume:[volume floatValue]];
        [callback invoke:nil];
    }
    else {
        [callback error:NSStringFromVideoPlayerError(kUnityAdsVideoViewNull) arg1:nil];
    }
}

+ (void)WebViewExposed_getVolume:(UADSWebViewCallback *)callback {
    if ([[UADSApiAdUnit getAdUnit] videoPlayer]) {
        [callback invoke:[NSNumber numberWithFloat:[[[UADSApiAdUnit getAdUnit] videoPlayer] volume]], nil];
    }
    else {
        [callback error:NSStringFromVideoPlayerError(kUnityAdsVideoViewNull) arg1:nil];
    }
}

+ (void)WebViewExposed_getCurrentPosition:(UADSWebViewCallback *)callback {
    if ([[UADSApiAdUnit getAdUnit] videoPlayer]) {
        [callback invoke:[NSNumber numberWithInt:[[[UADSApiAdUnit getAdUnit] videoPlayer] getCurrentPosition]], nil];
    }
    else {
        [callback error:NSStringFromVideoPlayerError(kUnityAdsVideoViewNull) arg1:nil];
    }
}

@end