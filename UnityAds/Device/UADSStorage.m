#import "UnityAds.h"
#import "UADSStorage.h"
#import "UADSWebViewApp.h"

@implementation UADSStorage

- (instancetype)initWithLocation:(NSString *)fileLocation type:(UnityAdsStorageType)type {
    self = [super init];
    
    if (self) {
        [self setTargetFileName:fileLocation];
        [self setType:type];
    }
    
    return self;
}

- (BOOL)setValue:(id)value forKey:(NSString *)key {
    if (self.storageContents && key && [key length] > 0 && value) {
        [self createObjectTree:[self getParentObjectTreeForTree:key]];

        if ([[self findObjectForKey:[self getParentObjectTreeForTree:key]] isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *parentObject = (NSMutableDictionary *)[self findObjectForKey:[self getParentObjectTreeForTree:key]];

            if (parentObject) {
                NSArray<NSString*> *keySplit = [key componentsSeparatedByString:@"."];
                NSString *lastKey = [keySplit objectAtIndex:[keySplit count] - 1];
                [parentObject setObject:value forKey:lastKey];

                return true;
            }
        }
    }

    return false;
}

- (id)getValueForKey:(NSString *)key {
    if (self.storageContents && [[self findObjectForKey:[self getParentObjectTreeForTree:key]] isKindOfClass:[NSDictionary class]]) {
        NSArray<NSString*> *keySplit = [key componentsSeparatedByString:@"."];
        NSMutableDictionary *parentObject = (NSMutableDictionary *)[self findObjectForKey:[self getParentObjectTreeForTree:key]];

        if (parentObject) {
            return [parentObject objectForKey:[keySplit objectAtIndex:[keySplit count] - 1]];
        }
    }

    return NULL;
}

- (BOOL)deleteKey:(NSString *)key {
    if (self.storageContents && [[self findObjectForKey:[self getParentObjectTreeForTree:key]] isKindOfClass:[NSDictionary class]]) {
        NSArray<NSString*> *keySplit = [key componentsSeparatedByString:@"."];
        NSMutableDictionary *parentObject = (NSMutableDictionary *)[self findObjectForKey:[self getParentObjectTreeForTree:key]];

        if (parentObject) {
            [parentObject removeObjectForKey:[keySplit objectAtIndex:[keySplit count] - 1]];
            return true;
        }
    }

    return false;
}

- (NSArray *)getKeys:(NSString *)key recursive:(BOOL)recursive {
    if ([[self getValueForKey:key] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *parentObject = [self getValueForKey:key];
        NSMutableArray *combinedKeys = [[NSMutableArray alloc] init];

        if (parentObject) {
            NSArray<NSString*> *keys = [parentObject allKeys];

            for (int idx = 0; idx < [keys count]; idx++) {
                NSString *currentKey = [keys objectAtIndex:idx];
                NSArray<NSString*> *subkeys;

                if (recursive) {
                    subkeys = [self getKeys:[NSString stringWithFormat:@"%@.%@", key, currentKey] recursive:recursive];
                }

                [combinedKeys addObject:currentKey];

                if (subkeys) {
                    for (NSString *subkey in subkeys) {
                        [combinedKeys addObject:[NSString stringWithFormat:@"%@.%@", key, subkey]];
                    }
                }
            }
            
            return combinedKeys;
        }
    }

    return [[NSArray alloc]init];
}

- (id)findObjectForKey:(NSString *)key {
    if (key && [key length] > 0) {
        NSArray<NSString*> *keySplit = [key componentsSeparatedByString:@"."];
        NSMutableDictionary *parentObject = self.storageContents;
        
        for (int idx = 0; idx < [keySplit count]; idx++) {
            if ([parentObject objectForKey:[keySplit objectAtIndex:idx]]) {
                parentObject = [parentObject objectForKey:[keySplit objectAtIndex:idx]];
            }
            else {
                return NULL;
            }
        }
        
        return parentObject;
    }
    else {
        return self.storageContents;
    }
    
    return NULL;
}

- (void)createObjectTree:(NSString *)tree {
    if (tree && [tree length] > 0) {
        NSArray<NSString*> *treeSplit = [tree componentsSeparatedByString:@"."];
        NSMutableDictionary *parentObject = self.storageContents;
        
        for (int idx = 0; idx < [treeSplit count]; idx++) {
            if (![parentObject objectForKey:[treeSplit objectAtIndex:idx]]) {
                [parentObject setObject:[[NSMutableDictionary alloc] init] forKey:[treeSplit objectAtIndex:idx]];
            }

            parentObject = [parentObject objectForKey:[treeSplit objectAtIndex:idx]];
        }
    }
}

- (NSString *)getParentObjectTreeForTree:(NSString *)tree {
    NSMutableArray<NSString*> *treeSplit = [NSMutableArray arrayWithArray:[tree componentsSeparatedByString:@"."]];
    [treeSplit removeLastObject];
    return [treeSplit componentsJoinedByString:@"."];
}

- (BOOL)hasData {
    if (self.storageContents && [[self.storageContents allKeys] count] > 0) {
        return true;
    }

    return false;
}

- (void)sendEvent:(NSString *)eventType values:(NSDictionary *)values {
    if ([UADSWebViewApp getCurrentApp]) {
        NSMutableArray *params = [[NSMutableArray alloc] init];
        if (self.type == kUnityAdsStorageTypePublic) {
            [params addObject:@"PUBLIC"];
        }
        else if (self.type == kUnityAdsStorageTypePrivate) {
            [params addObject:@"PRIVATE"];
        }

        [params addObject:values];
        BOOL success = [[UADSWebViewApp getCurrentApp] sendEvent:eventType category:@"STORAGE" params:params];

        if (!success) {
            UADSLogDebug(@"Coudn't send storage event to WebApp!");
        }
    }
}

// FILE HANDLING

- (void)initStorage {
    [self readStorage];
    if (!self.storageContents) {
        self.storageContents = [[NSMutableDictionary alloc] init];
    }
}

- (BOOL)readStorage {
    NSError *error;
    NSData *fileContents = [NSData dataWithContentsOfFile:self.targetFileName options:NSDataReadingUncached error:&error];

    if (!error) {
        NSError* jsonError;
        NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:fileContents options:NSJSONReadingMutableContainers error:&jsonError];
        
        if (!error && fileContents) {
            [self setStorageContents:[NSMutableDictionary dictionaryWithDictionary:jsonDict]];
            return true;
        }
    }

    return false;
}

- (BOOL)writeStorage {
    if (self.storageContents) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.storageContents options:0 error:nil];
        [jsonData writeToFile:self.targetFileName options:NSDataWritingAtomic error:&error];

        if (error) {
            return false;
        }

        return true;
    }

    return false;
}

- (BOOL)clearStorage {
    [self clearData];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    [fileManager removeItemAtPath:self.targetFileName error:&error];
    
    if (error) {
        return false;
    }
    
    return true;
}

- (void)clearData {
    self.storageContents = NULL;
}

- (BOOL)storageFileExists {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:self.targetFileName];
}

@end