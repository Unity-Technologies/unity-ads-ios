#import <Foundation/Foundation.h>
#import "UADSDeviceInfoReader.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSDeviceReaderMock : NSObject<UADSDeviceInfoReader>
@property (nonatomic, strong) NSDictionary *expectedInfo;
@end

NS_ASSUME_NONNULL_END
