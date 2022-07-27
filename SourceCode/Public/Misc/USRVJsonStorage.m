#import "USRVJsonStorage.h"
#import "NSObject+DeepCopy.h"

/**
 * Stores objects for dot-separated keys in a json-like format. For each key component will create an entity with dictionary value, next key component will be stored in that parent dictionary. Object is saved to the final dictionary with key = "value".
 * E.g. storing <mediation.name : mediation_partner> will create
 * {
 * mediation = {
 *    name = {
 *        value = mediation_partner;
 *    };
 * };
 */

@interface USRVJsonStorage ()

@property (nonatomic, strong) dispatch_queue_t synchronizedQueue;

@end

@implementation USRVJsonStorage

- (instancetype)init {
    SUPER_INIT;
    _synchronizedQueue = dispatch_queue_create("com.unity.jsonstorage", DISPATCH_QUEUE_SERIAL);

    return self;
}

- (BOOL)set: (NSString *)key value: (id)value {
    if (!self.storageContents || !key || [key length] == 0 || !value) {
        return NO;
    }

    __block BOOL success = NO;

    dispatch_sync(self.synchronizedQueue, ^{
        [self createObjectTree: [self getParentObjectTreeForTree: key]];

        if ([[self findObjectForKey: [self getParentObjectTreeForTree: key]] isKindOfClass: [NSDictionary class]]) {
            NSMutableDictionary *parentObject = (NSMutableDictionary *)[self findObjectForKey: [self getParentObjectTreeForTree: key]];

            if (parentObject) {
                NSArray<NSString *> *keySplit = [key componentsSeparatedByString: @"."];
                NSString *lastKey = [keySplit objectAtIndex: [keySplit count] - 1];
                [parentObject setObject: value
                                 forKey: lastKey];

                success = YES;
            }
        }
    });

    return success;
}

- (id)getValueForKey: (NSString *)key {
    __block id value = NULL;

    dispatch_sync(self.synchronizedQueue, ^{
        if (self.storageContents && [[self findObjectForKey: [self getParentObjectTreeForTree: key]] isKindOfClass: [NSDictionary class]]) {
            NSArray<NSString *> *keySplit = [key componentsSeparatedByString: @"."];
            NSMutableDictionary *parentObject = (NSMutableDictionary *)[self findObjectForKey: [self getParentObjectTreeForTree: key]];

            if (parentObject) {
                value = [parentObject objectForKey: [keySplit objectAtIndex: [keySplit count] - 1]];
            }
        }
    });

    return value;
}

- (BOOL)deleteKey: (NSString *)key {
    __block BOOL success = NO;

    dispatch_sync(self.synchronizedQueue, ^{
        if (self.storageContents && [[self findObjectForKey: [self getParentObjectTreeForTree: key]] isKindOfClass: [NSDictionary class]]) {
            NSArray<NSString *> *keySplit = [key componentsSeparatedByString: @"."];
            NSMutableDictionary *parentObject = (NSMutableDictionary *)[self findObjectForKey: [self getParentObjectTreeForTree: key]];

            if (parentObject) {
                [parentObject removeObjectForKey: [keySplit objectAtIndex: [keySplit count] - 1]];
                success = true;
            }
        }
    });

    return success;
}

- (void)setContents: (NSDictionary *)contents {
    dispatch_sync(self.synchronizedQueue, ^{
        self.storageContents = [NSMutableDictionary dictionaryWithDictionary: contents];
    });
}

- (NSDictionary *)getContents {
    __block NSDictionary *contents = NULL;

    dispatch_sync(self.synchronizedQueue, ^{
        contents = [self.storageContents uads_deepCopy];
    });

    return contents;
}

- (NSArray *)getKeys: (NSString *)key recursive: (BOOL)recursive {
    if ([[self getValueForKey: key] isKindOfClass: [NSDictionary class]]) {
        NSDictionary *parentObject = [self getValueForKey: key];
        NSMutableArray *combinedKeys = [[NSMutableArray alloc] init];

        if (parentObject) {
            NSArray<NSString *> *keys = [parentObject allKeys];

            for (int idx = 0; idx < [keys count]; idx++) {
                NSString *currentKey = [keys objectAtIndex: idx];
                NSArray<NSString *> *subkeys;

                if (recursive) {
                    subkeys = [self getKeys: [NSString stringWithFormat: @"%@.%@", key, currentKey]
                                  recursive : recursive];
                }

                [combinedKeys addObject: currentKey];

                if (subkeys) {
                    for (NSString *subkey in subkeys) {
                        [combinedKeys addObject: [NSString stringWithFormat: @"%@.%@", currentKey, subkey]];
                    }
                }
            }

            return combinedKeys;
        }
    }

    return [[NSArray alloc]init];
} /* getKeys */

- (id)findObjectForKey: (NSString *)key {
    if (key && [key length] > 0) {
        NSArray<NSString *> *keySplit = [key componentsSeparatedByString: @"."];
        NSMutableDictionary *parentObject = self.storageContents;

        for (int idx = 0; idx < [keySplit count]; idx++) {
            if ([parentObject objectForKey: [keySplit objectAtIndex: idx]]) {
                parentObject = [parentObject objectForKey: [keySplit objectAtIndex: idx]];
            } else {
                return NULL;
            }
        }

        return parentObject;
    } else {
        return self.storageContents;
    }

    return NULL;
}

- (void)createObjectTree: (NSString *)tree {
    if (tree && [tree length] > 0) {
        NSArray<NSString *> *treeSplit = [tree componentsSeparatedByString: @"."];
        NSMutableDictionary *parentObject = self.storageContents;

        for (int idx = 0; idx < [treeSplit count]; idx++) {
            if (![parentObject objectForKey: [treeSplit objectAtIndex: idx]]) {
                [parentObject setObject: [[NSMutableDictionary alloc] init]
                                 forKey: [treeSplit objectAtIndex: idx]];
            }

            parentObject = [parentObject objectForKey: [treeSplit objectAtIndex: idx]];
        }
    }
}

- (NSString *)getParentObjectTreeForTree: (NSString *)tree {
    NSMutableArray<NSString *> *treeSplit = [NSMutableArray arrayWithArray: [tree componentsSeparatedByString: @"."]];

    [treeSplit removeLastObject];
    return [treeSplit componentsJoinedByString: @"."];
}

- (BOOL)hasData {
    __block BOOL hasData = NO;

    dispatch_sync(self.synchronizedQueue, ^{
        if (self.storageContents && [[self.storageContents allKeys] count] > 0) {
            hasData = YES;
        }
    });
    return hasData;
}

- (void)clearData {
    dispatch_sync(self.synchronizedQueue, ^{
        self.storageContents = NULL;
    });
}

- (BOOL)initData {
    __block BOOL initialized = NO;

    dispatch_sync(self.synchronizedQueue, ^{
        if (!self.storageContents) {
            self.storageContents = [[NSMutableDictionary alloc] init];
            initialized = YES;
        }
    });
    return initialized;
}

@end
