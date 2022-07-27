#import "USRVBodyCompressorMock.h"
#import "NSDictionary+JSONString.h"
@implementation USRVBodyCompressorMock

- (nonnull NSString *)compressedIntoString: (nonnull NSDictionary *)dictionary {
    return self.expectedString;
}

- (NSData *)compressedIntoData: (NSDictionary *)dictionary {
    return dictionary.uads_jsonData;
}

@end
