#import <Foundation/Foundation.h>
#import "UADSDeviceInfoReader.h"
#import "UADSPIITrackingStatusReader.h"
#import "UADSGameSessionIdReader.h"
#import "UADSClientConfig.h"
NS_ASSUME_NONNULL_BEGIN

@interface UADSMinDeviceInfoReader : NSObject<UADSDeviceInfoReader>
+ (id<UADSDeviceInfoReader>)newWithIDFIReader: (id<UADSDeviceIDFIReader>)idfiReader
                          userContainerReader: (id<UADSPIITrackingStatusReader>)userContainerReader
                          gameSessionIdReader: (id<UADSGameSessionIdReader>)gameSessionIdReader
                                 clientConfig: (id<UADSClientConfig>)clientConfig;
@end

NS_ASSUME_NONNULL_END
