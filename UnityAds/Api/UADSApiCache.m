#import "UADSApiCache.h"
#import "UADSWebViewCallback.h"
#import "UADSSdkProperties.h"
#import "UADSCacheQueue.h"
#import "UADSDevice.h"
#import "UADSConnectivityUtils.h"
#import "NSString+Hash.h"
#import <AVFoundation/AVFoundation.h>
#import "UADSApiRequest.h"

NSString *NSStringFromCacheError(UnityAdsCacheError error) {
    switch (error) {
        case kUnityAdsFileIOError:
            return @"FILE_IO_ERROR";
        case kUnityAdsFileNotFound:
            return @"FILE_NOT_FOUND";
        case kUnityAdsNoInternet:
            return @"NO_INTERNET";
        case kUnityAdsFileAlreadyCaching:
            return @"FILE_ALREADY_CACHING";
        case kUnityAdsNotCaching:
            return @"NOT_CACHING";
        case kUnityAdsMalformedUrl:
            return @"MALFORMED_URL";
        case kUnityAdsNetworkError:
            return @"NETWORK_ERROR";
        case kUnityAdsInvalidArgument:
            return @"INVALID_ARGUMENT";
        case kUnityAdsUnsupportedEncoding:
            return @"UNSUPPORTED_ENCODING";
            break;
    }
}

@implementation UADSApiCache

+ (void)WebViewExposed_download:(NSString *)url fileId:(NSString *)fileId headers:(NSArray *)headers callback:(UADSWebViewCallback *)callback {
    if ([UADSConnectivityUtils getNetworkStatus] == NotReachable) {
        [callback error:NSStringFromCacheError(kUnityAdsNoInternet) arg1:nil];
        return;
    }

    BOOL success = [UADSCacheQueue download:url target:[UADSApiCache fileIdToFilename:fileId] headers:[UADSApiRequest getHeadersMap:headers]];
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

+ (void)WebViewExposed_getFileContent:(NSString *)fileId encoding:(NSString *)encoding callback:(UADSWebViewCallback *)callback {
    NSString *fileName = [UADSApiCache fileIdToFilename:fileId];

    if ([[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
        NSError *error;
        NSData *contents = [NSData dataWithContentsOfFile:fileName options:0 error:&error];
        NSString *fileContents = nil;

        if (!error && contents) {
            if (encoding) {
                if ([encoding isEqualToString:@"UTF-8"]) {
                    fileContents = [[NSString alloc] initWithData:contents encoding:NSUTF8StringEncoding];
                }
                else if ([encoding isEqualToString:@"Base64"]) {
                    fileContents = [contents base64EncodedStringWithOptions:0];
                }
                else {
                    [callback error:NSStringFromCacheError(kUnityAdsUnsupportedEncoding) arg1:fileId, fileName, encoding, nil];
                    return;
                }

                if (!fileContents) {
                    [callback error:NSStringFromCacheError(kUnityAdsUnsupportedEncoding) arg1:fileId, fileName, encoding, nil];
                    return;
                }
                else {
                    [callback invoke:fileContents, nil];
                }
            }
            else {
                [callback error:NSStringFromCacheError(kUnityAdsUnsupportedEncoding) arg1:fileId, fileName, [NSNull null], nil];
            }
        }
        else if (error) {
            [callback error:NSStringFromCacheError(kUnityAdsFileIOError) arg1:fileId, fileName, error.description, nil];
        }
        else if (!contents) {
            [callback error:NSStringFromCacheError(kUnityAdsFileIOError) arg1:fileId, fileName, "no file content", nil];
        }
    }
    else {
        [callback error:NSStringFromCacheError(kUnityAdsFileNotFound) arg1:fileId, fileName, nil];
    }
}

+ (void)WebViewExposed_setFileContent:(NSString *)fileId encoding:(NSString *)encoding content:(NSString *)content callback:(UADSWebViewCallback *)callback {
    NSString *tagetFilePath = [UADSApiCache fileIdToFilename:fileId];
    NSData *fileContents = nil;

    fileContents = [content dataUsingEncoding:NSUTF8StringEncoding];

    if (encoding) {
        if ([encoding isEqualToString:@"UTF-8"]) {
            // UTF-8 handled by default
        }
        else if ([encoding isEqualToString:@"Base64"]) {
            fileContents = [[NSData alloc] initWithBase64EncodedString:content options:0];
        }
        else {
            [callback error:NSStringFromCacheError(kUnityAdsUnsupportedEncoding) arg1:fileId, tagetFilePath, encoding, nil];
            return;
        }
    }

    @try {
        if (![[NSFileManager defaultManager] fileExistsAtPath:tagetFilePath]) {
            [[NSFileManager defaultManager] createFileAtPath:tagetFilePath contents:nil attributes:nil];
        }
        if (![[NSFileManager defaultManager] isWritableFileAtPath:tagetFilePath]) {
            [callback error:NSStringFromCacheError(kUnityAdsFileIOError) arg1:fileId, tagetFilePath, encoding, nil];
            return;
        }
        [fileContents writeToFile:tagetFilePath atomically:YES];
    }
    @catch (NSException *exception) {
        [callback error:NSStringFromCacheError(kUnityAdsFileIOError) arg1:fileId, tagetFilePath, exception.reason, nil];
        return;
    }
    [callback invoke:nil];
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

        NSMutableArray *result = [NSMutableArray arrayWithCapacity:[filteredFiles count]];
        for(id file in filteredFiles) {
            NSString *fileId = [file substringFromIndex:[[UADSSdkProperties getCacheFilePrefix] length]];
            [result addObject:[UADSApiCache getFileDictionary:fileId]];
        }

        [callback invoke:result, nil];
    }
    else {
        [callback error:NSStringFromCacheError(kUnityAdsFileIOError) arg1:nil];
    }
}

+ (void)WebViewExposed_getVideoInfo:(NSString *)fileId callback:(UADSWebViewCallback *)callback {
    NSString *fileName = [NSString stringWithFormat:@"%@", [UADSApiCache fileIdToFilename:fileId]];

    if ([[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
        @try {
            NSURL *videoURL = [[NSURL alloc] initFileURLWithPath:[UADSApiCache fileIdToFilename:fileId]];
            AVURLAsset *asset = [AVURLAsset URLAssetWithURL:videoURL options:nil];
            NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
            AVAssetTrack *track = [tracks objectAtIndex:0];
            CGSize mediaSize = track.naturalSize;
            Float64 lengthseconds = CMTimeGetSeconds(asset.duration);
            Float64 ms = lengthseconds * 1000;
            int duration = (int)ms;

            [callback invoke:[NSNumber numberWithFloat:mediaSize.width],
                [NSNumber numberWithFloat:mediaSize.height],
                [NSNumber numberWithInt:duration],
             nil];
        }
        @catch (NSException *exception) {
            [callback error:NSStringFromCacheError(kUnityAdsInvalidArgument) arg1:nil];
        }
    }
    else {
        [callback error:NSStringFromCacheError(kUnityAdsFileIOError) arg1:nil];
    }
}

+ (void)WebViewExposed_getFileInfo:(NSString *)fileId callback:(UADSWebViewCallback *)callback {
    [callback invoke:[UADSApiCache getFileDictionary:fileId], nil];
}

+ (void)WebViewExposed_getFilePath:(NSString *)fileId callback:(UADSWebViewCallback *)callback {
    NSString *file = [UADSApiCache fileIdToFilename:fileId];

    if ([[NSFileManager defaultManager] fileExistsAtPath:file]) {
        [callback invoke:[UADSApiCache fileIdToFilename:fileId], nil];
    }
    else {
        [callback error:NSStringFromCacheError(kUnityAdsFileNotFound) arg1:nil];
    }
}

+ (void)WebViewExposed_deleteFile:(NSString *)fileId callback:(UADSWebViewCallback *)callback {
    NSString *fileName = [NSString stringWithFormat:@"%@", [UADSApiCache fileIdToFilename:fileId]];
    NSError *error;
    BOOL removed = [[NSFileManager defaultManager] removeItemAtPath:fileName error:&error];

    if (!error && removed) {
        [callback invoke:nil];
    }
    else {
        [callback error:NSStringFromCacheError(kUnityAdsFileIOError) arg1:nil];
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
        [resultDict setObject:[NSNumber numberWithLongLong:[modifiedDate timeIntervalSince1970] * 1000] forKey:@"mtime"];
        [resultDict setObject:[NSNumber numberWithBool:true] forKey:@"found"];
        [resultDict setObject:size forKey:@"size"];
    }
    else {
        [resultDict setObject:[NSNumber numberWithBool:false] forKey:@"found"];
    }
    
    return [[NSDictionary alloc] initWithDictionary:resultDict];
}

@end
