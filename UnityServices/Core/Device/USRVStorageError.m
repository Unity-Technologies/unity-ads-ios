#import "USRVStorageError.h"

static NSString *couldntSetValue = @"COULDNT_SET_VALUE";
static NSString *couldntGetValue = @"COULDNT_GET_VALUE";
static NSString *couldntWriteStorageToCache = @"COULDNT_WRITE_STORAGE_TO_CACHE";
static NSString *couldntClearStorage = @"COULDNT_CLEAR_STORAGE";
static NSString *couldntGetStorage = @"COULDNT_GET_STORAGE";
static NSString *couldntDeleteValue = @"COULDNT_DELETE_VALUE";

NSString *NSStringFromStorageError(UnityServicesStorageError error) {
    switch (error) {
        case kUnityServicesCouldntSetValue:
            return couldntSetValue;
        case kUnityServicesCouldntGetValue:
            return couldntGetValue;
        case kUnityServicesCouldntWriteStorageToCache:
            return couldntWriteStorageToCache;
        case kUnityServicesCouldntClearStorage:
            return couldntClearStorage;
        case kUnityServicesCouldntGetStorage:
            return couldntGetStorage;
        case kUnityServicesCouldntDeleteValue:
            return couldntDeleteValue;
    }
}
