#import "UADSDeviceReaderMock.h"

@implementation UADSDeviceReaderMock

- (nonnull NSDictionary *)getDeviceInfoForGameMode: (UADSGameMode)mode {
    return self.expectedInfo;
}

@end
