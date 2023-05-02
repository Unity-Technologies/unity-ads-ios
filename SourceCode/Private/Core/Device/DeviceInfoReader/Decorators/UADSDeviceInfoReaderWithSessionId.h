#import <Foundation/Foundation.h>
#import "UADSDeviceInfoReader.h"
#import "UADSSharedSessionIdReader.h"
NS_ASSUME_NONNULL_BEGIN

@interface UADSDeviceInfoReaderWithSessionId : NSObject<UADSDeviceInfoReader>

+ (id<UADSDeviceInfoReader>)newWithOriginal: (id<UADSDeviceInfoReader>)original
                         andSessionIdReader: (id<UADSSharedSessionIdReader>)sessionIdReader;
@end

NS_ASSUME_NONNULL_END
