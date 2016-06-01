

typedef NS_ENUM(NSInteger, UnityAdsAVPlayerEvent) {
    kUnityAdsAVPlayerEventPrepared,
    kUnityAdsAVPPlayerEventProgress,
    kUnityAdsAVPlayerEventCompleted,
    kUnityAdsAVPlayerEventSeekTo,
    kUnityAdsAVPlayerEventLikelyToKeepUp,
    kUnityAdsAVPlayerEventBufferEmpty,
    kUnityAdsAVPlayerEventBufferFull
};

NSString *NSStringFromAVPlayerEvent(UnityAdsAVPlayerEvent);

typedef NS_ENUM(NSInteger, UnityAdsAVPlayerError) {
    kUnityAdsAVPlayerPrepareError,
    kUnityAdsAVPlayerGenericError
};

NSString *NSStringFromAVPlayerError(UnityAdsAVPlayerError);