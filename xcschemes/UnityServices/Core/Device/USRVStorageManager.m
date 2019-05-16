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
    [self addStorageLocation:[NSString stringWithFormat:@"%@/%@%@", cacheDir, localStorageFilePrefix, @"public-data.json"] forStorageType:kUnityServicesStorageTypePublic];
    [self addStorageLocation:[NSString stringWithFormat:@"%@/%@%@", cacheDir, localStorageFilePrefix, @"private-data.json"] forStorageType:kUnityServicesStorageTypePrivate];

    if (![USRVStorageManager setupStorage:kUnityServicesStorageTypePublic]) {
        return false;
    }
    if (![USRVStorageManager setupStorage:kUnityServicesStorageTypePrivate]) {
        return false;
    }

    return true;
}

+ (void)initStorage:(UnityServicesStorageType)storageType {
    if (!storages) {
        storages = [[NSMutableDictionary alloc] init];
    }

    if ([self hasStorage:storageType]) {
        USRVStorage *storage = [USRVStorageManager getStorage:storageType];
        if (storage) {
            [storage initStorage];
        }
    }
    
    else if ([storageLocations objectForKey:[NSNumber numberWithInt:storageType]]) {
        USRVStorage *storage = [[USRVStorage alloc] initWithLocation:[storageLocations objectForKey:[NSNumber numberWithInt:storageType]] type:storageType];
        [storage initStorage];
        [storages setObject:storage forKey:[NSNumber numberWithInt:storageType]];
    }
}

+ (BOOL)setupStorage:(UnityServicesStorageType)storageType {
    if (![USRVStorageManager hasStorage:storageType]) {
        [USRVStorageManager initStorage:storageType];
        USRVStorage *storage = [USRVStorageManager getStorage:storageType];
        
        if (storage && ![storage storageFileExists]) {
            [storage writeStorage];
        }
        if (!storage) {
            return false;
        }
    }

    return true;
}

+ (void)addStorageLocation:(NSString *)location forStorageType:(UnityServicesStorageType)storageType {
    if (!storageLocations) {
        storageLocations = [[NSMutableDictionary alloc] init];
    }

    if (![storageLocations objectForKey:[NSNumber numberWithInt:storageType]]) {
        [storageLocations setObject:location forKey:[NSNumber numberWithInt:storageType]];
    }
}

+ (void)removeStorage:(UnityServicesStorageType)storageType {
    if ([storageLocations objectForKey:[NSNumber numberWithInt:storageType]]) {
        [storageLocations removeObjectForKey:[NSNumber numberWithInt:storageType]];
    }
    if ([storages objectForKey:[NSNumber numberWithInt:storageType]]) {
        [storages removeObjectForKey:[NSNumber numberWithInt:storageType]];
    }
}

+ (USRVStorage *)getStorage:(UnityServicesStorageType)storageType {
    if (storages) {
        return [storages objectForKey:[NSNumber numberWithInt:storageType]];
    }

    return NULL;
}

+ (BOOL)hasStorage:(UnityServicesStorageType)storageType {
    if ([storages objectForKey:[NSNumber numberWithInt:storageType]]) {
        return true;
    }
    
    return false;
}

@end
