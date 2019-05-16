

typedef NS_ENUM(NSInteger, UnityAdsAVPlayerEvent) {
    kUnityAdsAVPlayerEventPrepared,
    kUnityAdsAVPlayerEventProgress,
    kUnityAdsAVPlayerEventCompleted,
    kUnityAdsAVPlayerEventSeekTo,
    kUnityAdsAVPlayerEventLikelyToKeepUp,
    kUnityAdsAVPlayerEventBufferEmpty,
    kUnityAdsAVPlayerEventBufferFull,
    kUnityAdsAVPlayerEventPlay,
    kUnityAdsAVPlayerEventPause,
    kUnityAdsAVPlayerEventStop
};

NSString *UADSNSStringFromAVPlayerEvent(UnityAdsAVPlayerEvent);

typedef NS_ENUM(NSInteger, UnityAdsAVPlayerError) {
    kUnityAdsAVPlayerPrepareError,
    kUnityAdsAVPlayerPrepareTimeout,
    kUnityAdsAVPlayerGenericError
};

NSString *UADSNSStringFromAVPlayerError(UnityAdsAVPlayerError);
