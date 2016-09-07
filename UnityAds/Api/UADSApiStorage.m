#import "UADSApiStorage.h"
#import "UADSStorageManager.h"
#import "UADSStorage.h"
#import "UADSStorageError.h"

@implementation UADSApiStorage

+ (void)WebViewExposed_set:(NSString *)type key:(NSString *)key value:(id)value callback:(UADSWebViewCallback *)callback {
    UnityAdsStorageType storageType = [UADSApiStorage getStorageTypeFromString:type];
    UADSStorage *storage = [UADSStorageManager getStorage:storageType];

    if (storage && key && value) {
        BOOL success = [storage setValue:value forKey:key];
        if (success) {
            [callback invoke:
                key,
                value,
             nil];
        }
        else {
            [callback error:NSStringFromStorageError(kUnityAdsCouldntSetValue) arg1:key, value, nil];
        }
    }
    else {
        [callback error:NSStringFromStorageError(kUnityAdsCouldntGetStorage) arg1:type, key, value, nil];
    }
}

+ (void)WebViewExposed_get:(NSString *)type key:(NSString *)key callback:(UADSWebViewCallback *)callback {
    UnityAdsStorageType storageType = [UADSApiStorage getStorageTypeFromString:type];
    UADSStorage *storage = [UADSStorageManager getStorage:storageType];

    if (storage && key) {
        __unsafe_unretained id value = [storage getValueForKey:key];

        if (value) {
            [callback invoke:
                value,
             nil];
        }
        else {
            [callback error:NSStringFromStorageError(kUnityAdsCouldntGetValue) arg1:key, nil];
        }
    }
    else {
        [callback error:NSStringFromStorageError(kUnityAdsCouldntGetStorage) arg1:type, key, nil];
    }
}

+ (void)WebViewExposed_read:(NSString *)type callback:(UADSWebViewCallback *)callback {
    UnityAdsStorageType storageType = [UADSApiStorage getStorageTypeFromString:type];
    UADSStorage *storage = [UADSStorageManager getStorage:storageType];

    if (storage) {
        [storage readStorage];
        [callback invoke:
            type,
         nil];
    }
    else {
        [callback error:NSStringFromStorageError(kUnityAdsCouldntGetStorage) arg1:type, nil];
    }
}

+ (void)WebViewExposed_write:(NSString *)type callback:(UADSWebViewCallback *)callback {
    UnityAdsStorageType storageType = [UADSApiStorage getStorageTypeFromString:type];
    UADSStorage *storage = [UADSStorageManager getStorage:storageType];

    if (storage) {
        BOOL success = [storage writeStorage];

        if (success) {
            [callback invoke:
                type,
             nil];
        }
        else {
            [callback error:NSStringFromStorageError(kUnityAdsCouldntWriteStorageToCache) arg1:type, nil];
        }
    }
    else {
        [callback error:NSStringFromStorageError(kUnityAdsCouldntGetStorage) arg1:type, nil];
    }
}

+ (void)WebViewExposed_clear:(NSString *)type callback:(UADSWebViewCallback *)callback {
    UnityAdsStorageType storageType = [UADSApiStorage getStorageTypeFromString:type];
    UADSStorage *storage = [UADSStorageManager getStorage:storageType];

    if (storage) {
        BOOL success = [storage clearStorage];

        if (success) {
            [callback invoke:
                type,
             nil];
        }
        else {
            [callback error:NSStringFromStorageError(kUnityAdsCouldntClearStorage) arg1:type, nil];
        }
    }
    else {
        [callback error:NSStringFromStorageError(kUnityAdsCouldntGetStorage) arg1:type, nil];
    }
}

+ (void)WebViewExposed_delete:(NSString *)type key:(NSString *)key callback:(UADSWebViewCallback *)callback {
    UnityAdsStorageType storageType = [UADSApiStorage getStorageTypeFromString:type];
    UADSStorage *storage = [UADSStorageManager getStorage:storageType];

    if (storage && key) {
        BOOL success = [storage deleteKey:key];

        if (success) {
            [callback invoke:
                type,
             nil];
        }
        else {
            [callback error:NSStringFromStorageError(kUnityAdsCouldntDeleteValue) arg1:type, nil];
        }
    }
    else {
        [callback error:NSStringFromStorageError(kUnityAdsCouldntGetStorage) arg1:type, nil];
    }
}

+ (void)WebViewExposed_getKeys:(NSString *)type key:(NSString *)key recursive:(NSNumber *)recursive callback:(UADSWebViewCallback *)callback {
    UnityAdsStorageType storageType = [UADSApiStorage getStorageTypeFromString:type];
    UADSStorage *storage = [UADSStorageManager getStorage:storageType];

    if (storage) {
        [callback invoke:
            [storage getKeys:key recursive:[recursive boolValue]],
         nil];
    }
    else {
        [callback error:NSStringFromStorageError(kUnityAdsCouldntGetStorage) arg1:type, key, nil];
    }
}

+ (UnityAdsStorageType)getStorageTypeFromString:(NSString *)typeString {
    int typeValue = 0;
    if ([typeString isEqualToString:@"PUBLIC"])
        typeValue = 1;
    else if ([typeString isEqualToString:@"PRIVATE"])
        typeValue = 2;

    return (UnityAdsStorageType)typeValue;
}

@end