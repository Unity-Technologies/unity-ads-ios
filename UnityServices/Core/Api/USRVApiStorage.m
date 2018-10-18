#import "USRVApiStorage.h"
#import "USRVStorageManager.h"
#import "USRVStorage.h"
#import "USRVStorageError.h"

@implementation USRVApiStorage

+ (void)WebViewExposed_set:(NSString *)type key:(NSString *)key value:(id)value callback:(USRVWebViewCallback *)callback {
    UnityServicesStorageType storageType = [USRVApiStorage getStorageTypeFromString:type];
    USRVStorage *storage = [USRVStorageManager getStorage:storageType];

    if (storage && key && value) {
        BOOL success = [storage set:key value:value];
        if (success) {
            [callback invoke:
                key,
                value,
             nil];
        }
        else {
            [callback error:NSStringFromStorageError(kUnityServicesCouldntSetValue) arg1:key, value, nil];
        }
    }
    else {
        [callback error:NSStringFromStorageError(kUnityServicesCouldntGetStorage) arg1:type, key, value, nil];
    }
}

+ (void)WebViewExposed_get:(NSString *)type key:(NSString *)key callback:(USRVWebViewCallback *)callback {
    UnityServicesStorageType storageType = [USRVApiStorage getStorageTypeFromString:type];
    USRVStorage *storage = [USRVStorageManager getStorage:storageType];

    if (storage && key) {
        __unsafe_unretained id value = [storage getValueForKey:key];

        if (value) {
            [callback invoke:
                value,
             nil];
        }
        else {
            [callback error:NSStringFromStorageError(kUnityServicesCouldntGetValue) arg1:key, nil];
        }
    }
    else {
        [callback error:NSStringFromStorageError(kUnityServicesCouldntGetStorage) arg1:type, key, nil];
    }
}

+ (void)WebViewExposed_read:(NSString *)type callback:(USRVWebViewCallback *)callback {
    UnityServicesStorageType storageType = [USRVApiStorage getStorageTypeFromString:type];
    USRVStorage *storage = [USRVStorageManager getStorage:storageType];

    if (storage) {
        [storage readStorage];
        [callback invoke:
            type,
         nil];
    }
    else {
        [callback error:NSStringFromStorageError(kUnityServicesCouldntGetStorage) arg1:type, nil];
    }
}

+ (void)WebViewExposed_write:(NSString *)type callback:(USRVWebViewCallback *)callback {
    UnityServicesStorageType storageType = [USRVApiStorage getStorageTypeFromString:type];
    USRVStorage *storage = [USRVStorageManager getStorage:storageType];

    if (storage) {
        BOOL success = [storage writeStorage];

        if (success) {
            [callback invoke:
                type,
             nil];
        }
        else {
            [callback error:NSStringFromStorageError(kUnityServicesCouldntWriteStorageToCache) arg1:type, nil];
        }
    }
    else {
        [callback error:NSStringFromStorageError(kUnityServicesCouldntGetStorage) arg1:type, nil];
    }
}

+ (void)WebViewExposed_clear:(NSString *)type callback:(USRVWebViewCallback *)callback {
    UnityServicesStorageType storageType = [USRVApiStorage getStorageTypeFromString:type];
    USRVStorage *storage = [USRVStorageManager getStorage:storageType];

    if (storage) {
        BOOL success = [storage clearStorage];

        if (success) {
            [callback invoke:
                type,
             nil];
        }
        else {
            [callback error:NSStringFromStorageError(kUnityServicesCouldntClearStorage) arg1:type, nil];
        }
    }
    else {
        [callback error:NSStringFromStorageError(kUnityServicesCouldntGetStorage) arg1:type, nil];
    }
}

+ (void)WebViewExposed_delete:(NSString *)type key:(NSString *)key callback:(USRVWebViewCallback *)callback {
    UnityServicesStorageType storageType = [USRVApiStorage getStorageTypeFromString:type];
    USRVStorage *storage = [USRVStorageManager getStorage:storageType];

    if (storage && key) {
        BOOL success = [storage deleteKey:key];

        if (success) {
            [callback invoke:
                type,
             nil];
        }
        else {
            [callback error:NSStringFromStorageError(kUnityServicesCouldntDeleteValue) arg1:type, nil];
        }
    }
    else {
        [callback error:NSStringFromStorageError(kUnityServicesCouldntGetStorage) arg1:type, nil];
    }
}

+ (void)WebViewExposed_getKeys:(NSString *)type key:(NSString *)key recursive:(NSNumber *)recursive callback:(USRVWebViewCallback *)callback {
    UnityServicesStorageType storageType = [USRVApiStorage getStorageTypeFromString:type];
    USRVStorage *storage = [USRVStorageManager getStorage:storageType];

    if (storage) {
        [callback invoke:
            [storage getKeys:key recursive:[recursive boolValue]],
         nil];
    }
    else {
        [callback error:NSStringFromStorageError(kUnityServicesCouldntGetStorage) arg1:type, key, nil];
    }
}

+ (UnityServicesStorageType)getStorageTypeFromString:(NSString *)typeString {
    int typeValue = 0;
    if ([typeString isEqualToString:@"PUBLIC"])
        typeValue = 1;
    else if ([typeString isEqualToString:@"PRIVATE"])
        typeValue = 2;

    return (UnityServicesStorageType)typeValue;
}

@end
