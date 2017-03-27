#import "UnityAds.h"
#import "UADSAVPlayer.h"
#import "UADSWebViewApp.h"
#import "UADSWebViewEventCategory.h"
#import "UADSAVPlayerEvent.h"

@interface UADSAVPlayer ()
    @property (nonatomic, assign) id progressTimer;
    @property (nonatomic, assign) id prepareTimeoutTimer;
@end

@implementation UADSAVPlayer

static void *playbackLikelyToKeepUpKVOToken = &playbackLikelyToKeepUpKVOToken;
static void *playbackBufferEmpty = &playbackBufferEmpty;
static void *playbackBufferFull = &playbackBufferFull;
static void *itemStatusChangeToken = &itemStatusChangeToken;

- (void)prepare:(NSString *)url initialVolume:(float)volume timeout:(NSInteger)timeout {
    [self stopObserving];
    self.url = url;
    UADSLogDebug(@"Preparing item: %@", self.url);
    NSURL *videoURL = [NSURL URLWithString:self.url];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:videoURL options:nil];
    NSInteger adjustedTimeout = timeout / 1000;
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressInterval = 300;
        [self setVolume:volume];
        [self replaceCurrentItemWithPlayerItem:playerItem];
        [self startObserving];
        [self startPrepareTimeoutTimer:adjustedTimeout];
    });
}

- (void)startObserving {
    if (self.currentItem) {
        @try {
            [self.currentItem addObserver:self forKeyPath:@"status" options:0 context:itemStatusChangeToken];
        }
        @catch (id exception) {
            UADSLogDebug(@"Failed adding observer for 'status'");
        }

        @try {
            [self.currentItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:0 context:playbackBufferEmpty];
        }
        @catch (id exception) {
            UADSLogDebug(@"Failed adding observer for 'playbackBufferEmpty'");
        }
        
        @try {
            [self.currentItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:0 context:playbackLikelyToKeepUpKVOToken];
        }
        @catch (id exception) {
            UADSLogDebug(@"Failed adding observer for 'playbackLikelyToKeepUp'");
        }
        
        @try {
            [self.currentItem addObserver:self forKeyPath:@"playbackBufferFull" options:0 context:playbackBufferFull];
        }
        @catch (id exception) {
            UADSLogDebug(@"Failed adding observer for 'playbackBufferFull'");
        }
    }
}

- (void)stopObserving {
    UADSLogDebug("Attempting to remove observers for item: %@", self.url);
    if (self.currentItem) {
        @try {
            [self.currentItem removeObserver:self forKeyPath:@"status" context:itemStatusChangeToken];
        }
        @catch (id exception) {
            UADSLogDebug(@"Failed removing observer for 'status'");
        }
        
        @try {
            [self.currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty" context:playbackBufferEmpty];
        }
        @catch (id exception) {
            UADSLogDebug(@"Failed removing observer for 'playbackBufferEmpty'");
        }

        @try {
            [self.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp" context:playbackLikelyToKeepUpKVOToken];
        }
        @catch (id exception) {
            UADSLogDebug(@"Failed removing observer for 'playbackLikelyToKeepUp'");
        }

        @try {
            [self.currentItem removeObserver:self forKeyPath:@"playbackBufferFull" context:playbackBufferFull];
        }
        @catch (id exception) {
            UADSLogDebug(@"Failed removing observer for 'playbackBufferFull'");
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

- (void)startPrepareTimeoutTimer:(NSInteger)timeout {
    self.prepareTimeoutTimer = [NSTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(onPrepareTimeoutListener:) userInfo:nil repeats:false];
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
        [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromAVPlayerError(kUnityAdsAVPlayerPrepareTimeout)
                                         category:NSStringFromWebViewEventCategory(kUnityAdsWebViewEventCategoryVideoPlayer)
                                           param1:self.url, nil];
    });
}

- (void)onCompletionListener:(NSNotification *)notification {
    UADSLogDebug(@"Video playback completed");
    self.isPlaying = false;
    [self stopVideoProgressTimer];

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
    __weak UADSAVPlayer *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromAVPlayerEvent(kUnityAdsAVPlayerEventProgress)
                                         category:NSStringFromWebViewEventCategory(kUnityAdsWebViewEventCategoryVideoPlayer)
                                           param1:[NSNumber numberWithLong:[weakSelf getMsFromCMTime:weakSelf.currentTime]], nil];
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

- (void)seekTo:(long)msec {
    Float64 t_ms = msec / 1000;
    CMTime time = CMTimeMakeWithSeconds(t_ms, 30);
    [self seekToTime:time completionHandler:^(BOOL finished) {
        [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromAVPlayerEvent(kUnityAdsAVPlayerEventSeekTo) category:NSStringFromWebViewEventCategory(kUnityAdsWebViewEventCategoryVideoPlayer) param1:self.url, nil];
    }];
}

- (long)getMsFromCMTime:(CMTime)time {
    Float64 current = CMTimeGetSeconds(time);
    Float64 ms = current * 1000;
    return (long)ms;
}

- (long)getCurrentPosition {
    return [self getMsFromCMTime:self.currentTime];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == itemStatusChangeToken) {
        UADSLogDebug(@"VIDEOPLAYERITEM_STATUS: %li", (long)self.currentItem.status);

        AVPlayerItemStatus playerItemStatus = self.currentItem.status;
        if (playerItemStatus == AVPlayerItemStatusReadyToPlay) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSArray *tracks = [self.currentItem.asset tracksWithMediaType:AVMediaTypeVideo];

                float width = -1;
                float height = -1;
                if ([tracks count] > 0) {
                    AVAssetTrack *track = [tracks objectAtIndex:0];
                    CGSize mediaSize = track.naturalSize;
                    width = mediaSize.width;
                    height = mediaSize.height;
                }

                [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromAVPlayerEvent(kUnityAdsAVPlayerEventPrepared) category:NSStringFromWebViewEventCategory(kUnityAdsWebViewEventCategoryVideoPlayer)
                    param1:self.url,
                    [NSNumber numberWithLong:[self getMsFromCMTime:self.currentItem.duration]],
                    [NSNumber numberWithFloat:width],
                    [NSNumber numberWithFloat:height],
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
                    self.currentItem.error.description,
                 nil];
            });

            [self stopPrepareTimeoutTimer];
        }
    }
    else if (context == playbackLikelyToKeepUpKVOToken) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromAVPlayerEvent(kUnityAdsAVPlayerEventLikelyToKeepUp)
                                             category:NSStringFromWebViewEventCategory(kUnityAdsWebViewEventCategoryVideoPlayer)
                                               param1:self.url,
                [NSNumber numberWithBool:self.currentItem.isPlaybackLikelyToKeepUp],
             nil];
        });
    }
    else if (context == playbackBufferEmpty) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromAVPlayerEvent(kUnityAdsAVPlayerEventBufferEmpty)
                                             category:NSStringFromWebViewEventCategory(kUnityAdsWebViewEventCategoryVideoPlayer)
                                               param1:self.url,
                [NSNumber numberWithBool:self.currentItem.isPlaybackBufferEmpty],
             nil];
        });
    }
    else if (context == playbackBufferFull) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromAVPlayerEvent(kUnityAdsAVPlayerEventBufferFull)
                                             category:NSStringFromWebViewEventCategory(kUnityAdsWebViewEventCategoryVideoPlayer)
                                               param1:self.url,
                [NSNumber numberWithBool:self.currentItem.isPlaybackBufferFull],
             nil];
        });
    }
}

@end
