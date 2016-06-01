#import "UADSStorageManager.h"
#import "UADSSdkProperties.h"

@implementation UADSStorageManager

static NSMutableDictionary *storageLocations;
static NSMutableDictionary *storages;

+ (BOOL)init {
    if (!storages) {
        storages = [[NSMutableDictionary alloc] init];
    }

    NSString *cacheDir = [UADSSdkProperties getCacheDirectory];
    NSString *localStorageFilePrefix = [UADSSdkProperties getLocalStorageFilePrefix];
    [self addStorageLocation:[NSString stringWithFormat:@"%@/%@%@", cacheDir, localStorageFilePrefix, @"public-data.json"] forStorageType:kUnityAdsStorageTypePublic];
    [self addStorageLocation:[NSString stringWithFormat:@"%@/%@%@", cacheDir, localStorageFilePrefix, @"private-data.json"] forStorageType:kUnityAdsStorageTypePrivate];

    if (![UADSStorageManager setupStorage:kUnityAdsStorageTypePublic]) {
        return false;
    }
    if (![UADSStorageManager setupStorage:kUnityAdsStorageTypePrivate]) {
        return false;
    }

    return true;
}

+ (void)initStorage:(UnityAdsStorageType)storageType {
    if (!storages) {
        storages = [[NSMutableDictionary alloc] init];
    }

    if ([self hasStorage:storageType]) {
        UADSStorage *storage = [UADSStorageManager getStorage:storageType];
        if (storage) {
            [storage initStorage];
        }
    }
    
    else if ([storageLocations objectForKey:[NSNumber numberWithInt:storageType]]) {
        UADSStorage *storage = [[UADSStorage alloc] initWithLocation:[storageLocations objectForKey:[NSNumber numberWithInt:storageType]] type:storageType];
        [storage initStorage];
        [storages setObject:storage forKey:[NSNumber numberWithInt:storageType]];
    }
}

+ (BOOL)setupStorage:(UnityAdsStorageType)storageType {
    if (![UADSStorageManager hasStorage:storageType]) {
        [UADSStorageManager initStorage:storageType];
        UADSStorage *storage = [UADSStorageManager getStorage:storageType];
        
        if (storage && ![storage storageFileExists]) {
            [storage writeStorage];
        }
        if (!storage) {
            return false;
        }
    }

    return true;
}

+ (void)addStorageLocation:(NSString *)location forStorageType:(UnityAdsStorageType)storageType {
    if (!storageLocations) {
        storageLocations = [[NSMutableDictionary alloc] init];
    }

    if (![storageLocations objectForKey:[NSNumber numberWithInt:storageType]]) {
        [storageLocations setObject:location forKey:[NSNumber numberWithInt:storageType]];
    }
}

+ (void)removeStorage:(UnityAdsStorageType)storageType {
    if ([storageLocations objectForKey:[NSNumber numberWithInt:storageType]]) {
        [storageLocations removeObjectForKey:[NSNumber numberWithInt:storageType]];
    }
    if ([storages objectForKey:[NSNumber numberWithInt:storageType]]) {
        [storages removeObjectForKey:[NSNumber numberWithInt:storageType]];
    }
}

+ (UADSStorage *)getStorage:(UnityAdsStorageType)storageType {
    if (storages) {
        return [storages objectForKey:[NSNumber numberWithInt:storageType]];
    }

    return NULL;
}

+ (BOOL)hasStorage:(UnityAdsStorageType)storageType {
    if ([storages objectForKey:[NSNumber numberWithInt:storageType]]) {
        return true;
    }
    
    return false;
}

@end