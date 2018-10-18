#import "UADSAVPlayerEvent.h"

static NSString *eventPrepared = @"PREPARED";
static NSString *eventProgress = @"PROGRESS";
static NSString *eventCompleted = @"COMPLETED";
static NSString *eventSeekTo = @"SEEKTO";
static NSString *eventLikelyToKeepUp = @"LIKELY_TO_KEEP_UP";
static NSString *eventBufferFull = @"BUFFER_FULL";
static NSString *eventBufferEmpty = @"BUFFER_EMPTY";
static NSString *eventPlay = @"PLAY";
static NSString *eventPause = @"PAUSE";
static NSString *eventStop = @"STOP";


static NSString *prepareError = @"PREPARE_ERROR";
static NSString *prepareTimeout = @"PREPARE_TIMEOUT";
static NSString *genericError = @"GENERIC_ERROR";


NSString *NSStringFromAVPlayerEvent(UnityAdsAVPlayerEvent event) {
    switch (event) {
        case kUnityAdsAVPlayerEventPrepared:
            return eventPrepared;
        case kUnityAdsAVPlayerEventProgress:
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
        case kUnityAdsAVPlayerEventPlay:
            return eventPlay;
        case kUnityAdsAVPlayerEventPause:
            return eventPause;
        case kUnityAdsAVPlayerEventStop:
            return eventStop;
    }
}

NSString *NSStringFromAVPlayerError(UnityAdsAVPlayerError error) {
    switch (error) {
        case kUnityAdsAVPlayerPrepareError:
            return prepareError;
        case kUnityAdsAVPlayerPrepareTimeout:
            return prepareTimeout;
        case kUnityAdsAVPlayerGenericError:
            return genericError;
    }
}
