#import "USRVBodyCompressorMock.h"

@implementation USRVBodyCompressorMock

- (nonnull NSString *)compressedIntoString: (nonnull NSDictionary *)dictionary {
    return self.expectedString;
}

@end
