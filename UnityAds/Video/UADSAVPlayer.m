#import "UnityAds.h"
#import "UADSAVPlayer.h"
#import "UADSWebViewApp.h"
#import "UADSWebViewEventCategory.h"
#import "UADSAVPlayerEvent.h"

@interface UADSAVPlayer ()
    @property (nonatomic, assign) id progressTimer;
    @property (nonatomic, assign) id prepareTimeoutTimer;
    @property (nonatomic, strong) AVPlayerItem *playerItem;
@end

@implementation UADSAVPlayer

static void *playbackLikelyToKeepUpKVOToken = &playbackLikelyToKeepUpKVOToken;
static void *playbackBufferEmpty = &playbackBufferEmpty;
static void *playbackBufferFull = &playbackBufferFull;
static void *itemStatusChangeToken = &itemStatusChangeToken;

- (void)prepare:(NSString *)url initialVolume:(float)volume {
    [self stopObserving];
    self.url = url;
    UADSLogDebug(@"Preparing item: %@", self.url);
    NSURL *videoURL = [NSURL URLWithString:self.url];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:videoURL options:nil];
    self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressInterval = 300;
        [self setVolume:volume];
        [self replaceCurrentItemWithPlayerItem:self.playerItem];
        [self startObserving];
        [self startPrepareTimeoutTimer];
    });
}

- (void)startObserving {
    if (self.playerItem) {
        @try {
            [self.playerItem addObserver:self forKeyPath:@"status" options:0 context:itemStatusChangeToken];
            [self.playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:0 context:playbackBufferEmpty];
            [self.playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:0 context:playbackLikelyToKeepUpKVOToken];
            [self.playerItem addObserver:self forKeyPath:@"playbackBufferFull" options:0 context:playbackBufferFull];
        }
        @catch (id exception) {
        }
    }
}

- (void)stopObserving {
    if (self.playerItem) {
        @try {
            [self.playerItem removeObserver:self forKeyPath:@"status" context:itemStatusChangeToken];
            [self.playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty" context:playbackBufferEmpty];
            [self.playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp" context:playbackLikelyToKeepUpKVOToken];
            [self.playerItem removeObserver:self forKeyPath:@"playbackBufferFull" context:playbackBufferFull];
        }
        @catch (id exception) {
        }
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)setProgressEventInterval:(int)progressEventInterval {
    if (self.progressInterval != progressEventInterval) {
        [self stopVideoProgressTimer];
        self.progressInterval = progressEventInterval;
        [self startVideoProgressTimer];
    }
}

- (void)startPrepareTimeoutTimer {
    self.prepareTimeoutTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(onPrepareTimeoutListener:) userInfo:nil repeats:false];
}

- (void)stopPrepareTimeoutTimer {
    if (self.prepareTimeoutTimer) {
        [self.prepareTimeoutTimer invalidate];
        self.prepareTimeoutTimer = NULL;
    }
}

- (void)onPrepareTimeoutListener:(NSNotification *)notification {
    UADSLogError(@"Video prepare timeout");
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromAVPlayerError(kUnityAdsAVPlayerPrepareError)
                                         category:NSStringFromWebViewEventCategory(kUnityAdsWebViewEventCategoryVideoPlayer)
                                           param1:self.url, nil];
    });
}

- (void)onCompletionListener:(NSNotification *)notification {
    UADSLogDebug(@"Video playback completed");
    self.isPlaying = false;
    [self stopVideoProgressTimer];
    [self stopObserving];

    dispatch_async(dispatch_get_main_queue(), ^{
        [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromAVPlayerEvent(kUnityAdsAVPlayerEventCompleted)
                                         category:NSStringFromWebViewEventCategory(kUnityAdsWebViewEventCategoryVideoPlayer) param1:self.url, nil];
    });
}

- (void)startVideoProgressTimer {
    float interval = (float)self.progressInterval / 1000;
    self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(videoProgressTimer:) userInfo:nil repeats:YES];
}

- (void)stopVideoProgressTimer {
    if (self.progressTimer) {
        [self.progressTimer invalidate];
        self.progressTimer = NULL;
    }
}

- (void)videoProgressTimer:(NSTimer *)timer {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromAVPlayerEvent(kUnityAdsAVPlayerEventProgress)
                                         category:NSStringFromWebViewEventCategory(kUnityAdsWebViewEventCategoryVideoPlayer)
                                           param1:[NSNumber numberWithInt:[self getMsFromCMTime:self.currentTime]], nil];
    });
}

- (void)play {
    UADSLogDebug(@"Starting video playback");

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCompletionListener:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.currentItem];

    [super play];
    self.isPlaying = true;
    [self stopVideoProgressTimer];
    [self startVideoProgressTimer];

    dispatch_async(dispatch_get_main_queue(), ^{
        [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromAVPlayerEvent(kUnityAdsAVPlayerEventPlay)
                                         category:NSStringFromWebViewEventCategory(kUnityAdsWebViewEventCategoryVideoPlayer)
                                           param1:self.url, nil];
    });
}

- (void)pause {
    UADSLogDebug(@"Pausing video playback");

    [super pause];
    self.isPlaying = false;
    [self stopVideoProgressTimer];

    dispatch_async(dispatch_get_main_queue(), ^{
        [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromAVPlayerEvent(kUnityAdsAVPlayerEventPause)
                                         category:NSStringFromWebViewEventCategory(kUnityAdsWebViewEventCategoryVideoPlayer)
                                           param1:self.url, nil];
    });
}

- (void)stop {
    UADSLogDebug(@"Stopping video playback");

    [super pause];
    self.isPlaying = false;
    [self stopVideoProgressTimer];

    dispatch_async(dispatch_get_main_queue(), ^{
        [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromAVPlayerEvent(kUnityAdsAVPlayerEventStop)
                                         category:NSStringFromWebViewEventCategory(kUnityAdsWebViewEventCategoryVideoPlayer)
                                           param1:self.url, nil];
    });
}

- (void)seekTo:(int)msec {
    Float64 t_ms = msec / 1000;
    CMTime time = CMTimeMakeWithSeconds(t_ms, 30);
    [self seekToTime:time completionHandler:^(BOOL finished) {
        [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromAVPlayerEvent(kUnityAdsAVPlayerEventSeekTo) category:NSStringFromWebViewEventCategory(kUnityAdsWebViewEventCategoryVideoPlayer) param1:self.url, nil];
    }];
}

- (int)getMsFromCMTime:(CMTime)time {
    Float64 current = CMTimeGetSeconds(time);
    Float64 ms = current * 1000;
    return (int)ms;
}

- (int)getCurrentPosition {
    return [self getMsFromCMTime:self.currentTime];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == itemStatusChangeToken) {
        UADSLogDebug(@"VIDEOPLAYERITEM_STATUS: %li", (long)self.currentItem.status);
        
        AVPlayerItemStatus playerItemStatus = self.playerItem.status;
        if (playerItemStatus == AVPlayerItemStatusReadyToPlay) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSArray *tracks = [self.currentItem.asset tracksWithMediaType:AVMediaTypeVideo];
                AVAssetTrack *track = [tracks objectAtIndex:0];
                CGSize mediaSize = track.naturalSize;

                [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromAVPlayerEvent(kUnityAdsAVPlayerEventPrepared) category:NSStringFromWebViewEventCategory(kUnityAdsWebViewEventCategoryVideoPlayer)
                    param1:[NSNumber numberWithInt:[self getMsFromCMTime:self.currentItem.duration]],
                    [NSNumber numberWithFloat:mediaSize.width],
                    [NSNumber numberWithFloat:mediaSize.height],
                    self.url,
                 nil];
            });

            [self stopPrepareTimeoutTimer];
        }
        else if (playerItemStatus == AVPlayerItemStatusFailed) {
            UADSLogError(@"VIDEOPLAYER_ERROR: %@", self.currentItem.error.description);
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromAVPlayerError(kUnityAdsAVPlayerGenericError)
                                                 category:NSStringFromWebViewEventCategory(kUnityAdsWebViewEventCategoryVideoPlayer)
                                                   param1:self.url,
                 nil];
            });
        }
    }
    else if (context == playbackLikelyToKeepUpKVOToken) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromAVPlayerEvent(kUnityAdsAVPlayerEventLikelyToKeepUp)
                                             category:NSStringFromWebViewEventCategory(kUnityAdsWebViewEventCategoryVideoPlayer)
                                               param1:self.url,
                [NSNumber numberWithBool:self.playerItem.isPlaybackLikelyToKeepUp],
             nil];
        });
    }
    else if (context == playbackBufferEmpty) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromAVPlayerEvent(kUnityAdsAVPlayerEventBufferEmpty)
                                             category:NSStringFromWebViewEventCategory(kUnityAdsWebViewEventCategoryVideoPlayer)
                                               param1:self.url,
                [NSNumber numberWithBool:self.playerItem.isPlaybackBufferEmpty],
             nil];
        });
    }
    else if (context == playbackBufferFull) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromAVPlayerEvent(kUnityAdsAVPlayerEventBufferFull)
                                             category:NSStringFromWebViewEventCategory(kUnityAdsWebViewEventCategoryVideoPlayer)
                                               param1:self.url,
                [NSNumber numberWithBool:self.playerItem.isPlaybackBufferFull],
             nil];
        });
    }
}

@end