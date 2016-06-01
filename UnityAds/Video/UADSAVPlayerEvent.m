#import "UADSAVPlayerEvent.h"

static NSString *eventPrepared = @"PREPARED";
static NSString *eventProgress = @"PROGRESS";
static NSString *eventCompleted = @"COMPLETED";
static NSString *eventSeekTo = @"SEEKTO";
static NSString *eventLikelyToKeepUp = @"LIKELY_TO_KEEP_UP";
static NSString *eventBufferFull = @"BUFFER_FULL";
static NSString *eventBufferEmpty = @"BUFFER_EMPTY";

static NSString *prepareError = @"PREPARE_ERROR";
static NSString *genericError = @"GENERIC_ERROR";


NSString *NSStringFromAVPlayerEvent(UnityAdsAVPlayerEvent event) {
    switch (event) {
        case kUnityAdsAVPlayerEventPrepared:
            return eventPrepared;
        case kUnityAdsAVPPlayerEventProgress:
            return eventProgress;
        case kUnityAdsAVPlayerEventCompleted:
            return eventCompleted;
        case kUnityAdsAVPlayerEventSeekTo:
            return eventSeekTo;
        case kUnityAdsAVPlayerEventLikelyToKeepUp:
            return eventLikelyToKeepUp;
        case kUnityAdsAVPlayerEventBufferFull:
            return eventBufferFull;
        case kUnityAdsAVPlayerEventBufferEmpty:
            return eventBufferEmpty;
    }
}

NSString *NSStringFromAVPlayerError(UnityAdsAVPlayerError error) {
    switch (error) {
        case kUnityAdsAVPlayerPrepareError:
            return prepareError;
        case kUnityAdsAVPlayerGenericError:
            return genericError;
    }
}