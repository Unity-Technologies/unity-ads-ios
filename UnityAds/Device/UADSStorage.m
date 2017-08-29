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


- (void)sendEvent:(NSString *)eventType values:(id)values {
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

- (BOOL)storageFileExists {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:self.targetFileName];
}

@end
