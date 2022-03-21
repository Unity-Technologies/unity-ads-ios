#import <Foundation/Foundation.h>
#import "UADSDeviceInfoReader.h"
#import "UADSDeviceInfoExcludeFieldsProvider.h"
NS_ASSUME_NONNULL_BEGIN

@interface UADSDeviceInfoReaderWithFilter : NSObject<UADSDeviceInfoReader>

+ (id<UADSDeviceInfoReader>)newWithOriginal: (id<UADSDeviceInfoReader>)original
                               andBlockList: (id<UADSDictionaryKeysBlockList>)blockListReader;
@end

NS_ASSUME_NONNULL_END
