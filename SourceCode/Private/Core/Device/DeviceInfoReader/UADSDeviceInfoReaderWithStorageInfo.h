#import <Foundation/Foundation.h>
#import "UADSDeviceInfoReader.h"
#import "USRVJsonStorage.h"
NS_ASSUME_NONNULL_BEGIN


@interface UADSDeviceInfoReaderWithStorageInfo : NSObject<UADSDeviceInfoReader>
+ (instancetype)decorateOriginal: (id<UADSDeviceInfoReader>)original
            andJSONStorageReader: (id<UADSJsonStorageContentsReader>)jsonStorageReader
               includeContainers: (NSArray< NSString *> *)includeContainers;

+ (instancetype)defaultDecorationOfOriginal: (id<UADSDeviceInfoReader>)original;
@end

NS_ASSUME_NONNULL_END
