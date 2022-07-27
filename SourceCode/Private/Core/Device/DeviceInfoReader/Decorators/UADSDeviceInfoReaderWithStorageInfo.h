#import <Foundation/Foundation.h>
#import "UADSDeviceInfoReader.h"
#import "USRVJsonStorage.h"
#import "UADSDeviceInfoStorageKeysProvider.h"
NS_ASSUME_NONNULL_BEGIN


@interface UADSDeviceInfoReaderWithStorageInfo : NSObject<UADSDeviceInfoReader>
+ (instancetype)decorateOriginal: (id<UADSDeviceInfoReader>)original
            andJSONStorageReader: (id<UADSJsonStorageContentsReader>)jsonStorageReader
                    keysProvider: (id<UADSDeviceInfoStorageKeysProvider>)keysProvider;

+ (instancetype)defaultDecorationOfOriginal: (id<UADSDeviceInfoReader>)original
                            andKeysProvider: (id<UADSDeviceInfoStorageKeysProvider>)keysProvider;
@end

NS_ASSUME_NONNULL_END
