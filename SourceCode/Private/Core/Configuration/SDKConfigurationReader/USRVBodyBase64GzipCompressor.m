#import "USRVBodyBase64GzipCompressor.h"

@interface USRVBodyBase64GzipCompressor ()
@property (nonatomic, strong) id<USRVDataCompressor> compressor;
@end

@implementation USRVBodyBase64GzipCompressor

+ (instancetype)newWithDataCompressor: (id<USRVDataCompressor>)compressor {
    USRVBodyBase64GzipCompressor *base64Compressor = [USRVBodyBase64GzipCompressor new];

    base64Compressor.compressor = compressor;
    return base64Compressor;
}

- (NSString *)compressedIntoString: (NSDictionary *)dictionary {
    NSData *compressedData = [self.compressor compressedIntoData: dictionary];

    return [compressedData base64EncodedStringWithOptions: 0];
}

@end
