#import <Foundation/Foundation.h>
#import "UADSDeviceInfoReader.h"
#import "UADSPIITrackingStatusReader.h"
NS_ASSUME_NONNULL_BEGIN

@interface UADSMinDeviceInfoReader : NSObject<UADSDeviceInfoReader>
+ (id<UADSDeviceInfoReader>)newWithIDFIReader: (id<UADSDeviceIDFIReader>)idfiReader
                          userContainerReader: (id<UADSPIITrackingStatusReader>)userContainerReader
                        withUserNonBehavioral: (BOOL)includeUserNonBehavioral
                                   withGameID: (NSString *)gameID;
@end

NS_ASSUME_NONNULL_END
