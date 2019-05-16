#import "USRVStorage.h"
#import "USRVWebViewApp.h"
#import "USRVJsonUtilities.h"

@implementation USRVStorage

- (instancetype)initWithLocation:(NSString *)fileLocation type:(UnityServicesStorageType)type {
    self = [super init];
    
    if (self) {
        [self setTargetFileName:fileLocation];
        [self setType:type];
    }
    
    return self;
}


- (void)sendEvent:(NSString *)eventType values:(id)values {
    if ([USRVWebViewApp getCurrentApp]) {
        NSMutableArray *params = [[NSMutableArray alloc] init];
        if (self.type == kUnityServicesStorageTypePublic) {
            [params addObject:@"PUBLIC"];
        }
        else if (self.type == kUnityServicesStorageTypePrivate) {
            [params addObject:@"PRIVATE"];
        }

        [params addObject:values];
        BOOL success = [[USRVWebViewApp getCurrentApp] sendEvent:eventType category:@"STORAGE" params:params];

        if (!success) {
            USRVLogDebug(@"Coudn't send storage event to WebApp!");
        }
    }
}

// FILE HANDLING

- (void)initStorage {
    [self readStorage];
    [self initData];
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
        NSData *jsonData = [USRVJsonUtilities dataWithJSONObject:self.storageContents options:0 error:nil];
        if (jsonData) {
            NSError *error;
            [jsonData writeToFile:self.targetFileName options:NSDataWritingAtomic error:&error];

            if (error) {
                USRVLogError(@"USRVStorage.writeStorage was not able to write data to file : %@", [error localizedDescription]);
                return false;
            } else {
                // successfully wrote to file
                return true;
            }
        } else {
            return false;
        }
    } else {
        return false;
    }
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

- (BOOL)storageFileExists {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:self.targetFileName];
}

@end
