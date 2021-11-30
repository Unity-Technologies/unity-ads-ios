#import "USRVStorageManager.h"
#import "USRVSdkProperties.h"
#import "NSDictionary+Merge.h"

@interface USRVStorageManager ()

@property (nonatomic, strong) NSMutableDictionary *storageLocations;
@property (nonatomic, strong) NSMutableDictionary *storages;
@property (nonatomic, strong) dispatch_queue_t syncQueue;

@end

@implementation USRVStorageManager

+ (USRVStorage *)getStorage: (UnityServicesStorageType)storageType {
    return [[USRVStorageManager sharedInstance] getStorage: storageType];
}

+ (void)removeStorage: (UnityServicesStorageType)storageType {
    [[USRVStorageManager sharedInstance] removeStorage: storageType];
}

_uads_custom_singleton_imp(USRVStorageManager, ^{
    return [self new];
})

- (instancetype)init {
    SUPER_INIT

        _syncQueue = dispatch_queue_create("com.unity.storage.manager", DISPATCH_QUEUE_SERIAL);

    _storages = [[NSMutableDictionary alloc] init];

    _storageLocations = [[NSMutableDictionary alloc] init];

    [self setupStorages];

    return self;
}

- (void)setupStorages {
    NSString *cacheDir = [USRVSdkProperties getCacheDirectory];
    NSString *localStorageFilePrefix = [USRVSdkProperties getLocalStorageFilePrefix];

    dispatch_sync(_syncQueue, ^{
        [self addStorageLocation: [NSString stringWithFormat: @"%@/%@%@", cacheDir, localStorageFilePrefix, @"public-data.json"]
                  forStorageType: kUnityServicesStorageTypePublic];
        [self addStorageLocation: [NSString stringWithFormat: @"%@/%@%@", cacheDir, localStorageFilePrefix, @"private-data.json"]
                  forStorageType: kUnityServicesStorageTypePrivate];

        [self setupStorage: kUnityServicesStorageTypePublic];
        [self setupStorage: kUnityServicesStorageTypePrivate];
    });
}

- (void)addStorageLocation: (NSString *)location forStorageType: (UnityServicesStorageType)storageType {
    if (![_storageLocations objectForKey: [NSNumber numberWithInteger: storageType]]) {
        [_storageLocations setObject: location
                              forKey: [NSNumber numberWithInteger: storageType]];
    }
}

- (BOOL)setupStorage: (UnityServicesStorageType)storageType {
    if (![self hasStorage: storageType]) {
        [self initStorage: storageType];
        USRVStorage *storage = [_storages objectForKey: [NSNumber numberWithInteger: storageType]];

        if (storage && ![storage storageFileExists]) {
            [storage writeStorage];
        }

        if (!storage) {
            return false;
        }
    }

    return true;
}

- (BOOL)hasStorage: (UnityServicesStorageType)storageType {
    return [self.storages objectForKey: [NSNumber numberWithInteger: storageType]] != nil;
}

- (void)initStorage: (UnityServicesStorageType)storageType {
    if ([self hasStorage: storageType]) {
        USRVStorage *storage =  [_storages objectForKey: [NSNumber numberWithInteger: storageType]];

        if (storage) {
            [storage initStorage];
        }
    } else if ([_storageLocations objectForKey: [NSNumber numberWithInteger: storageType]]) {
        USRVStorage *storage = [[USRVStorage alloc] initWithLocation: [_storageLocations objectForKey: [NSNumber numberWithInteger: storageType]]
                                                                type: storageType];
        [storage initStorage];
        [_storages setObject: storage
                      forKey: [NSNumber numberWithInteger: storageType]];
    }
} /* initStorage */

- (void)removeStorage: (UnityServicesStorageType)storageType {
    dispatch_sync(_syncQueue, ^{
        [_storageLocations removeObjectForKey: [NSNumber numberWithInteger: storageType]];
        [_storages removeObjectForKey: [NSNumber numberWithInteger: storageType]];
    });
}

- (USRVStorage *)getStorage: (UnityServicesStorageType)storageType {
    __block USRVStorage *result = NULL;

    dispatch_sync(_syncQueue, ^{
        result = [_storages objectForKey: [NSNumber numberWithInteger: storageType]];
    });
    return result;
}

- (void)commit: (NSDictionary *)storageContents {
    USRVStorage *storage = [USRVStorageManager getStorage: kUnityServicesStorageTypePublic];

    if (!storage || !storageContents) {
        return;
    }

    dispatch_sync(_syncQueue, ^{
        for (NSString *key in storageContents) {
            id value = [storageContents valueForKey: key];
            id storageValue = [storage getValueForKey: key];

            if (storageValue && [storageValue isKindOfClass: [NSDictionary class]] && [value isKindOfClass: [NSDictionary class]]) {
                value = [NSDictionary unityads_dictionaryByMerging: value
                                                         secondary: storageValue];
            }

            [storage set: key
                   value : value];
        }

        [storage writeStorage];
        [storage sendEvent: @"SET"
                    values: storageContents];
    });
}

@end
