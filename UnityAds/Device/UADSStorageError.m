#import "UADSStorageError.h"

static NSString *couldntSetValue = @"COULDNT_SET_VALUE";
static NSString *couldntGetValue = @"COULDNT_GET_VALUE";
static NSString *couldntWriteStorageToCache = @"COULDNT_WRITE_STORAGE_TO_CACHE";
static NSString *couldntClearStorage = @"COULDNT_CLEAR_STORAGE";
static NSString *couldntGetStorage = @"COULDNT_GET_STORAGE";
static NSString *couldntDeleteValue = @"COULDNT_DELETE_VALUE";

NSString *NSStringFromStorageError(UnityAdsStorageError error) {
    switch (error) {
        case kUnityAdsCouldntSetValue:
            return couldntSetValue;
        case kUnityAdsCouldntGetValue:
            return couldntGetValue;
        case kUnityAdsCouldntWriteStorageToCache:
            return couldntWriteStorageToCache;
        case kUnityAdsCouldntClearStorage:
            return couldntClearStorage;
        case kUnityAdsCouldntGetStorage:
            return couldntGetStorage;
        case kUnityAdsCouldntDeleteValue:
            return couldntDeleteValue;
    }
}
