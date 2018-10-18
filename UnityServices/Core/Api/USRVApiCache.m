#import "USRVApiCache.h"
#import "USRVConnectivityUtils.h"
#import "USRVCacheQueue.h"
#import "USRVWebViewCallback.h"
#import "USRVSdkProperties.h"
#import "USRVDevice.h"
#import "NSString+Hash.h"
#import <AVFoundation/AVFoundation.h>
#import "USRVApiRequest.h"

NSString *NSStringFromCacheError(UnityServicesCacheError error) {
    switch (error) {
        case kUnityServicesFileIOError:
            return @"FILE_IO_ERROR";
        case kUnityServicesFileNotFound:
            return @"FILE_NOT_FOUND";
        case kUnityServicesNoInternet:
            return @"NO_INTERNET";
        case kUnityServicesFileAlreadyCaching:
            return @"FILE_ALREADY_CACHING";
        case kUnityServicesNotCaching:
            return @"NOT_CACHING";
        case kUnityServicesMalformedUrl:
            return @"MALFORMED_URL";
        case kUnityServicesNetworkError:
            return @"NETWORK_ERROR";
        case kUnityServicesInvalidArgument:
            return @"INVALID_ARGUMENT";
        case kUnityServicesUnsupportedEncoding:
            return @"UNSUPPORTED_ENCODING";
        case kUnityServicesFileStateWrong:
            return @"FILE_STATE_WRONG";
            break;
    }
}

@implementation USRVApiCache

+ (void)WebViewExposed_download:(NSString *)url fileId:(NSString *)fileId headers:(NSArray *)headers append:(NSNumber *)append callback:(USRVWebViewCallback *)callback {
    if ([USRVConnectivityUtils getNetworkStatus] == NotReachable) {
        [callback error:NSStringFromCacheError(kUnityServicesNoInternet) arg1:nil];
        return;
    }

    BOOL success = [USRVCacheQueue download:url target:[USRVApiCache fileIdToFilename:fileId] headers:[USRVApiRequest getHeadersMap:headers] append:[append boolValue]];
    if (!success) {
        [callback error:NSStringFromCacheError(kUnityServicesFileAlreadyCaching) arg1:nil];
    }
    else {
        [callback invoke:nil];
    }
}

+ (void)WebViewExposed_stop:(USRVWebViewCallback *)callback {
    if (![USRVCacheQueue hasOperations]) {
        [callback error:NSStringFromCacheError(kUnityServicesNotCaching) arg1:nil];
    }
    else {
        [USRVCacheQueue cancelAllDownloads];
        [callback invoke:nil];
    }
}

+ (void)WebViewExposed_getFileContent:(NSString *)fileId encoding:(NSString *)encoding callback:(USRVWebViewCallback *)callback {
    NSString *fileName = [USRVApiCache fileIdToFilename:fileId];

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
                    [callback error:NSStringFromCacheError(kUnityServicesUnsupportedEncoding) arg1:fileId, fileName, encoding, nil];
                    return;
                }

                if (!fileContents) {
                    [callback error:NSStringFromCacheError(kUnityServicesUnsupportedEncoding) arg1:fileId, fileName, encoding, nil];
                    return;
                }
                else {
                    [callback invoke:fileContents, nil];
                }
            }
            else {
                [callback error:NSStringFromCacheError(kUnityServicesUnsupportedEncoding) arg1:fileId, fileName, [NSNull null], nil];
            }
        }
        else if (error) {
            [callback error:NSStringFromCacheError(kUnityServicesFileIOError) arg1:fileId, fileName, error.description, nil];
        }
        else if (!contents) {
            [callback error:NSStringFromCacheError(kUnityServicesFileIOError) arg1:fileId, fileName, "no file content", nil];
        }
    }
    else {
        [callback error:NSStringFromCacheError(kUnityServicesFileNotFound) arg1:fileId, fileName, nil];
    }
}

+ (void)WebViewExposed_setFileContent:(NSString *)fileId encoding:(NSString *)encoding content:(NSString *)content callback:(USRVWebViewCallback *)callback {
    NSString *tagetFilePath = [USRVApiCache fileIdToFilename:fileId];
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
            [callback error:NSStringFromCacheError(kUnityServicesUnsupportedEncoding) arg1:fileId, tagetFilePath, encoding, nil];
            return;
        }
    }

    @try {
        if (![[NSFileManager defaultManager] fileExistsAtPath:tagetFilePath]) {
            [[NSFileManager defaultManager] createFileAtPath:tagetFilePath contents:nil attributes:nil];
        }
        if (![[NSFileManager defaultManager] isWritableFileAtPath:tagetFilePath]) {
            [callback error:NSStringFromCacheError(kUnityServicesFileIOError) arg1:fileId, tagetFilePath, encoding, nil];
            return;
        }
        [fileContents writeToFile:tagetFilePath atomically:YES];
    }
    @catch (NSException *exception) {
        [callback error:NSStringFromCacheError(kUnityServicesFileIOError) arg1:fileId, tagetFilePath, exception.reason, nil];
        return;
    }
    [callback invoke:nil];
}

+ (void)WebViewExposed_isCaching:(USRVWebViewCallback *)callback {
    [callback invoke:[NSNumber numberWithBool:[USRVCacheQueue hasOperations]], nil];
}

+ (void)WebViewExposed_getFiles:(USRVWebViewCallback *)callback {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error;
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:[USRVSdkProperties getCacheDirectory] error:&error];

    if (!error) {
        NSString *predicate = [NSString stringWithFormat:@"self BEGINSWITH '%@'", [USRVSdkProperties getCacheFilePrefix]];
        NSPredicate *filter = [NSPredicate predicateWithFormat:predicate];
        NSArray *filteredFiles = [dirContents filteredArrayUsingPredicate:filter];

        NSMutableArray *result = [NSMutableArray arrayWithCapacity:[filteredFiles count]];
        for(id file in filteredFiles) {
            NSString *fileId = [file substringFromIndex:[[USRVSdkProperties getCacheFilePrefix] length]];
            [result addObject:[USRVApiCache getFileDictionary:fileId]];
        }

        [callback invoke:result, nil];
    }
    else {
        [callback error:NSStringFromCacheError(kUnityServicesFileIOError) arg1:nil];
    }
}

+ (void)WebViewExposed_getVideoInfo:(NSString *)fileId callback:(USRVWebViewCallback *)callback {
    NSString *fileName = [NSString stringWithFormat:@"%@", [USRVApiCache fileIdToFilename:fileId]];

    if ([[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
        @try {
            NSURL *videoURL = [[NSURL alloc] initFileURLWithPath:[USRVApiCache fileIdToFilename:fileId]];
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
            [callback error:NSStringFromCacheError(kUnityServicesInvalidArgument) arg1:nil];
        }
    }
    else {
        [callback error:NSStringFromCacheError(kUnityServicesFileIOError) arg1:nil];
    }
}

+ (void)WebViewExposed_getFileInfo:(NSString *)fileId callback:(USRVWebViewCallback *)callback {
    [callback invoke:[USRVApiCache getFileDictionary:fileId], nil];
}

+ (void)WebViewExposed_getFilePath:(NSString *)fileId callback:(USRVWebViewCallback *)callback {
    NSString *file = [USRVApiCache fileIdToFilename:fileId];

    if ([[NSFileManager defaultManager] fileExistsAtPath:file]) {
        [callback invoke:[USRVApiCache fileIdToFilename:fileId], nil];
    }
    else {
        [callback error:NSStringFromCacheError(kUnityServicesFileNotFound) arg1:nil];
    }
}

+ (void)WebViewExposed_deleteFile:(NSString *)fileId callback:(USRVWebViewCallback *)callback {
    NSString *fileName = [NSString stringWithFormat:@"%@", [USRVApiCache fileIdToFilename:fileId]];
    NSError *error;
    BOOL removed = [[NSFileManager defaultManager] removeItemAtPath:fileName error:&error];

    if (!error && removed) {
        [callback invoke:nil];
    }
    else {
        [callback error:NSStringFromCacheError(kUnityServicesFileIOError) arg1:nil];
    }
}


+ (void)WebViewExposed_setTimeouts:(NSNumber *)connectTimeout callback:(USRVWebViewCallback *)callback {
    [USRVCacheQueue setConnectTimeout:connectTimeout.intValue];
    [callback invoke:nil];
}

+ (void)WebViewExposed_getTimeouts:(USRVWebViewCallback *)callback {
    [callback invoke:
     [NSNumber numberWithInt:[USRVCacheQueue getConnectTimeout]],
     nil];
}

+ (void)WebViewExposed_setProgressInterval:(NSNumber *)interval callback:(USRVWebViewCallback *)callback {
    [USRVCacheQueue setProgressInterval:[interval intValue]];
    [callback invoke:nil];
}

+ (void)WebViewExposed_getProgressInterval:(USRVWebViewCallback *)callback {
    [callback invoke:[NSNumber numberWithInt:[USRVCacheQueue getProgressInterval]]];
}

+ (void)WebViewExposed_getFreeSpace:(USRVWebViewCallback *)callback {
    [callback invoke:[USRVDevice getFreeSpaceInKilobytes], nil];
}

+ (void)WebViewExposed_getTotalSpace:(USRVWebViewCallback *)callback {
    [callback invoke:[USRVDevice getTotalSpaceInKilobytes], nil];
}

+ (void)WebViewExposed_getHash:(NSString *)stringToHash callback:(USRVWebViewCallback *)callback {
    [callback invoke:[stringToHash sha256], nil];
}

+ (NSString*)fileIdToFilename:(NSString *)fileId {
    return [NSString stringWithFormat:@"%@/%@%@", [USRVSdkProperties getCacheDirectory], [USRVSdkProperties getCacheFilePrefix], fileId];
}

+ (NSDictionary *)getFileDictionary:(NSString *)fileId {
    NSString *fileName = [USRVApiCache fileIdToFilename:fileId];
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
