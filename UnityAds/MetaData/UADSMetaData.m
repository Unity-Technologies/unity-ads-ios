#import "UnityAds.h"
#import "UADSMetaData.h"
#import "UADSStorageManager.h"

@implementation UADSMetaData

- (instancetype)initWithCategory:(NSString *)category {
    self = [super init];

    if (self) {
        [self setCategory:category];
    }

    return self;
}

- (void)set:(NSString *)key value:(id)value {
    if (!self.entries) {
        self.entries = [[NSMutableDictionary alloc] init];
    }
    
    NSString *finalKey = key;
    if (self.category) {
        finalKey = [NSString stringWithFormat:@"%@.%@", self.category, key];
    }
    
    [self.entries setObject:value forKey:[NSString stringWithFormat:@"%@.value", finalKey]];
    NSNumber *timestamp = [NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970] * 1000];
    [self.entries setObject:timestamp forKey:[NSString stringWithFormat:@"%@.ts", finalKey]];
}

- (void)commit {
    if ([UADSStorageManager init]) {
        UADSStorage *storage = [UADSStorageManager getStorage:kUnityAdsStorageTypePublic];

        for (NSString *key in [self.entries allKeys]) {
            if (storage) {
                [storage setValue:[self.entries objectForKey:key] forKey:key];
            }
        }

        if (storage) {
            [storage writeStorage];
            [storage sendEvent:@"SET" values:self.entries];
        }
        else {
            UADSLogDebug(@"No storage found!");
        }
    }
    else {
        UADSLogError(@"Init storages failed!");
    }
}

@end