

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

NSString *NSStringFromAVPlayerEvent(UnityAdsAVPlayerEvent);

typedef NS_ENUM(NSInteger, UnityAdsAVPlayerError) {
    kUnityAdsAVPlayerPrepareError,
    kUnityAdsAVPlayerPrepareTimeout,
    kUnityAdsAVPlayerGenericError
};

NSString *NSStringFromAVPlayerError(UnityAdsAVPlayerError);
