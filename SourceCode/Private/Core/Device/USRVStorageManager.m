#import "USRVStorageManager.h"
#import "USRVSdkProperties.h"

@implementation USRVStorageManager

static NSMutableDictionary *storageLocations;
static NSMutableDictionary *storages;

+ (BOOL)init {
    if (!storages) {
        storages = [[NSMutableDictionary alloc] init];
    }

    NSString *cacheDir = [USRVSdkProperties getCacheDirectory];
    NSString *localStorageFilePrefix = [USRVSdkProperties getLocalStorageFilePrefix];

    [self addStorageLocation: [NSString stringWithFormat: @"%@/%@%@", cacheDir, localStorageFilePrefix, @"public-data.json"]
              forStorageType: kUnityServicesStorageTypePublic];
    [self addStorageLocation: [NSString stringWithFormat: @"%@/%@%@", cacheDir, localStorageFilePrefix, @"private-data.json"]
              forStorageType: kUnityServicesStorageTypePrivate];

    if (![USRVStorageManager setupStorage: kUnityServicesStorageTypePublic]) {
        return false;
    }

    if (![USRVStorageManager setupStorage: kUnityServicesStorageTypePrivate]) {
        return false;
    }

    return true;
} /* init */

+ (dispatch_queue_t)getSynchronize {
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
}

+ (void)initStorage: (UnityServicesStorageType)storageType {
    if (!storages) {
        storages = [[NSMutableDictionary alloc] init];
    }

    if ([self hasStorage: storageType]) {
        USRVStorage *storage = [USRVStorageManager getStorage: storageType];

        if (storage) {
            [storage initStorage];
        }
    } else if ([storageLocations objectForKey: [NSNumber numberWithInteger: storageType]]) {
        USRVStorage *storage = [[USRVStorage alloc] initWithLocation: [storageLocations objectForKey: [NSNumber numberWithInteger: storageType]]
                                                                type: storageType];
        [storage initStorage];
        dispatch_sync([self getSynchronize], ^{
            [storages setObject: storage
                         forKey: [NSNumber numberWithInteger: storageType]];
        });
    }
} /* initStorage */

+ (BOOL)setupStorage: (UnityServicesStorageType)storageType {
    if (![USRVStorageManager hasStorage: storageType]) {
        [USRVStorageManager initStorage: storageType];
        USRVStorage *storage = [USRVStorageManager getStorage: storageType];

        if (storage && ![storage storageFileExists]) {
            [storage writeStorage];
        }

        if (!storage) {
            return false;
        }
    }

    return true;
}

+ (void)addStorageLocation: (NSString *)location forStorageType: (UnityServicesStorageType)storageType {
    if (!storageLocations) {
        storageLocations = [[NSMutableDictionary alloc] init];
    }

    dispatch_sync([self getSynchronize], ^{
        if (![storageLocations objectForKey: [NSNumber numberWithInteger: storageType]]) {
            [storageLocations setObject: location
                                 forKey: [NSNumber numberWithInteger: storageType]];
        }
    });
}

+ (void)removeStorage: (UnityServicesStorageType)storageType {
    dispatch_sync([self getSynchronize], ^{
        if ([storageLocations objectForKey: [NSNumber numberWithInteger: storageType]]) {
            [storageLocations removeObjectForKey: [NSNumber numberWithInteger: storageType]];
        }
    });

    dispatch_sync([self getSynchronize], ^{
        if ([storages objectForKey: [NSNumber numberWithInteger: storageType]]) {
            [storages removeObjectForKey: [NSNumber numberWithInteger: storageType]];
        }
    });
}

+ (USRVStorage *)getStorage: (UnityServicesStorageType)storageType {
    __block USRVStorage *result = NULL;

    dispatch_sync([self getSynchronize], ^{
        result = [storages objectForKey: [NSNumber numberWithInteger: storageType]];
    });
    return result;
}

+ (BOOL)hasStorage: (UnityServicesStorageType)storageType {
    __block BOOL result = false;

    dispatch_sync([self getSynchronize], ^{
        result = [storages objectForKey: [NSNumber numberWithInteger: storageType]];
    });
    return result;
}

@end
