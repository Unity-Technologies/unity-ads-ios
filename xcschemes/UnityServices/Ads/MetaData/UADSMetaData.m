#import "UnityAds.h"
#import "USRVStorageManager.h"
#import "UADSMetaData.h"
#import "NSDictionary+Merge.h"

@implementation UADSMetaData

- (instancetype)initWithCategory:(NSString *)category {
    self = [super init];

    if (self) {
        [self setCategory:category];
    }

    return self;
}

- (BOOL)set:(NSString *)key value:(id)value {
    [self initData];
    
    BOOL success = false;
    NSNumber *timestamp = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000];
    if ([super set:[NSString stringWithFormat:@"%@.value", [self getActualKeyForKey:key]] value:value] &&
         [super set:[NSString stringWithFormat:@"%@.ts", [self getActualKeyForKey:key]] value:timestamp]) {
        success = true;
    };

    return success;
}

- (BOOL)setRaw:(NSString *)key value:(id)value {
    [self initData];
    return [super set:[self getActualKeyForKey:key] value:value];
}

- (NSString *)getActualKeyForKey:(NSString *)key {
    NSString *finalKey = key;
    if (self.category) {
        finalKey = [NSString stringWithFormat:@"%@.%@", self.category, key];
    }
    
    return finalKey;
}

- (void)commit {
    if ([USRVStorageManager init]) {
        USRVStorage *storage = [USRVStorageManager getStorage:kUnityServicesStorageTypePublic];

        if (self.storageContents && storage) {
            for (NSString *key in self.storageContents) {
                id value = [self getValueForKey:key];
                if ([storage getValueForKey:key] && [[storage getValueForKey:key] isKindOfClass:[NSDictionary class]] && [value isKindOfClass:[NSDictionary class]]) {
                    value = [NSDictionary dictionaryByMerging:value secondary:[storage getValueForKey:key]];
                }

                [storage set:key value:value];
            }

            [storage writeStorage];
            [storage sendEvent:@"SET" values:self.storageContents];
        }
    }
    else {
        USRVLogError(@"Init storages failed!");
    }
}

@end
