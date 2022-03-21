#import "USRVDataGzipCompressor.h"
#import "NSData+GZIP.h"
#import "NSDictionary+JSONString.h"

@implementation USRVDataGzipCompressor

- (NSData *)compressedIntoData: (NSDictionary *)dictionary {
    return dictionary.jsonData.gzippedData;
}

@end
