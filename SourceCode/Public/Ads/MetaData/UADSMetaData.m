#import "USRVStorageManager.h"
#import "UADSMetaData.h"

/**
 * Uses category is a parent key for all objects. For each object saves timestamp it was added to the storage.
 * E.g. MetaData with category = "mediation" for <name : mediation_partner> will create
 * {
 * mediation = {
 *    name = {
 *        ts = 1628799917567;
 *        value = mediation_partner;
 *    };
 * };
 *
 * On commit, writes to a file and notifies webview about the changes.
 */

@implementation UADSMetaData

- (instancetype)initWithCategory: (NSString *)category {
    self = [super init];

    if (self) {
        [self setCategory: category];
    }

    return self;
}

- (BOOL)set: (NSString *)key value: (id)value {
    [self initData];

    BOOL success = false;
    NSNumber *timestamp = [NSNumber numberWithLongLong: [[NSDate date] timeIntervalSince1970] * 1000];

    if ([super set: [NSString stringWithFormat: @"%@.value", [self getActualKeyForKey: key]]
             value : value] &&
        [super set: [NSString stringWithFormat: @"%@.ts", [self getActualKeyForKey: key]]
             value : timestamp]) {
        success = true;
    }

    return success;
}

- (BOOL)setRaw: (NSString *)key value: (id)value {
    [self initData];
    return [super set: [self getActualKeyForKey: key]
                value : value];
}

- (NSString *)getActualKeyForKey: (NSString *)key {
    NSString *finalKey = key;

    if (self.category) {
        finalKey = [NSString stringWithFormat: @"%@.%@", self.category, key];
    }

    return finalKey;
}

- (void)commit {
    NSDictionary *storageContents = [self getContents];

    [[USRVStorageManager sharedInstance] commit: storageContents];
} /* commit */

@end
