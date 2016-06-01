#import "UADSApiCache.h"
#import "UADSWebViewCallback.h"
#import "UADSSdkProperties.h"
#import "UADSCacheQueue.h"
#import "UADSDevice.h"
#import "UADSConnectivityUtils.h"
#import "NSString+Hash.h"

typedef NS_ENUM(NSInteger, UnityAdsCacheError) {
    kUnityAdsFileIOError,
    kUnityAdsNoInternet,
    kUnityAdsFileAlreadyCaching,
    kUnityAdsNotCaching
};

NSString *NSStringFromCacheError(UnityAdsCacheError error) {
    switch (error) {
        case kUnityAdsFileIOError:
            return @"FILE_IO_ERROR";
        case kUnityAdsNoInternet:
            return @"NO_INTERNET";
        case kUnityAdsFileAlreadyCaching:
            return @"FILE_ALREADY_CACHING";
        case kUnityAdsNotCaching:
            return @"NOT_CACHING";
    }
}

@implementation UADSApiCache

+ (void)WebViewExposed_download:(NSString *)url fileId:(NSString *)fileId callback:(UADSWebViewCallback *)callback {
    if ([UADSConnectivityUtils getNetworkStatus] == NotReachable) {
        [callback error:NSStringFromCacheError(kUnityAdsNoInternet) arg1:nil];
        return;
    }

    BOOL success = [UADSCacheQueue download:url target:[UADSApiCache fileIdToFilename:fileId]];
    if (!success) {
        [callback error:NSStringFromCacheError(kUnityAdsFileAlreadyCaching) arg1:nil];
    }
    else {
        [callback invoke:nil];
    }
}

+ (void)WebViewExposed_stop:(UADSWebViewCallback *)callback {
    if (![UADSCacheQueue hasOperations]) {
        [callback error:NSStringFromCacheError(kUnityAdsNotCaching) arg1:nil];
    }
    else {
        [UADSCacheQueue cancelAllDownloads];
        [callback invoke:nil];
    }
}

+ (void)WebViewExposed_isCaching:(UADSWebViewCallback *)callback {
    [callback invoke:[NSNumber numberWithBool:[UADSCacheQueue hasOperations]], nil];
}

+ (void)WebViewExposed_getFiles:(UADSWebViewCallback *)callback {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error;
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:[UADSSdkProperties getCacheDirectory] error:&error];

    if (!error) {
        NSString *predicate = [NSString stringWithFormat:@"self BEGINSWITH '%@'", [UADSSdkProperties getCacheFilePrefix]];
        NSPredicate *filter = [NSPredicate predicateWithFormat:predicate];
        NSArray *filteredFiles = [dirContents filteredArrayUsingPredicate:filter];

        [callback invoke:
         filteredFiles,
         nil];
    }
    else {
        [callback error:NSStringFromCacheError(kUnityAdsFileIOError) arg1:nil];
    }
}

+ (void)WebViewExposed_getFileInfo:(NSString *)fileId callback:(UADSWebViewCallback *)callback {
    [callback invoke:[UADSApiCache getFileDictionary:fileId], nil];
}

+ (void)WebViewExposed_getFilePath:(NSString *)fileId callback:(UADSWebViewCallback *)callback {
    [callback invoke:[UADSApiCache fileIdToFilename:fileId], nil];
}

+ (void)WebViewExposed_deleteFile:(NSString *)fileId callback:(UADSWebViewCallback *)callback {
    NSString *fileName = [NSString stringWithFormat:@"%@", [UADSApiCache fileIdToFilename:fileId]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:fileName error:&error];
        
        if (!error) {
            [callback invoke:[NSNumber numberWithBool:true]];
        }
        else {
            [callback invoke:[NSNumber numberWithBool:false]];
        }
    }
}


+ (void)WebViewExposed_setTimeouts:(NSNumber *)connectTimeout callback:(UADSWebViewCallback *)callback {
    [UADSCacheQueue setConnectTimeout:connectTimeout.intValue];
    [callback invoke:nil];
}

+ (void)WebViewExposed_getTimeouts:(UADSWebViewCallback *)callback {
    [callback invoke:
     [NSNumber numberWithInt:[UADSCacheQueue getConnectTimeout]],
     nil];
}

+ (void)WebViewExposed_setProgressInterval:(NSNumber *)interval callback:(UADSWebViewCallback *)callback {
    [UADSCacheQueue setProgressInterval:[interval intValue]];
    [callback invoke:nil];
}

+ (void)WebViewExposed_getProgressInterval:(UADSWebViewCallback *)callback {
    [callback invoke:[NSNumber numberWithInt:[UADSCacheQueue getProgressInterval]]];
}

+ (void)WebViewExposed_getFreeSpace:(UADSWebViewCallback *)callback {
    [callback invoke:[UADSDevice getFreeSpaceInKilobytes], nil];
}

+ (void)WebViewExposed_getTotalSpace:(UADSWebViewCallback *)callback {
    [callback invoke:[UADSDevice getTotalSpaceInKilobytes], nil];
}

+ (void)WebViewExposed_getHash:(NSString *)stringToHash callback:(UADSWebViewCallback *)callback {
    [callback invoke:[stringToHash sha256], nil];
}

+ (NSString*)fileIdToFilename:(NSString *)fileId {
    return [NSString stringWithFormat:@"%@/%@%@", [UADSSdkProperties getCacheDirectory], [UADSSdkProperties getCacheFilePrefix], fileId];
}

+ (NSDictionary *)getFileDictionary:(NSString *)fileId {
    NSString *fileName = [UADSApiCache fileIdToFilename:fileId];
    NSError *error;
    NSDictionary* fileAttribs = [[NSFileManager defaultManager] attributesOfItemAtPath:fileName error:&error];
    NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
    
    if (!error) {
        NSDate *modifiedDate = [fileAttribs objectForKey:NSFileModificationDate]; //or NSFileModificationDate
        NSNumber *size = [fileAttribs objectForKey:NSFileSize];
        
        [resultDict setObject:fileId forKey:@"id"];
        [resultDict setObject:[NSNumber numberWithLong:[modifiedDate timeIntervalSince1970] * 1000] forKey:@"mtime"];
        [resultDict setObject:[NSNumber numberWithBool:true] forKey:@"found"];
        [resultDict setObject:size forKey:@"size"];
    }
    else {
        [resultDict setObject:[NSNumber numberWithBool:false] forKey:@"found"];
    }
    
    return [[NSDictionary alloc] initWithDictionary:resultDict];
}

@end