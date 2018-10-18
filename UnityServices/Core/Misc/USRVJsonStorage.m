#import "USRVJsonStorage.h"

@implementation USRVJsonStorage

- (BOOL)set:(NSString *)key value:(id)value {
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
                        [combinedKeys addObject:[NSString stringWithFormat:@"%@.%@", currentKey, subkey]];
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

- (void)clearData {
    self.storageContents = NULL;
}

- (BOOL)initData {
    if (!self.storageContents) {
        self.storageContents = [[NSMutableDictionary alloc] init];
        return true;
    }
    
    return false;
}

@end
