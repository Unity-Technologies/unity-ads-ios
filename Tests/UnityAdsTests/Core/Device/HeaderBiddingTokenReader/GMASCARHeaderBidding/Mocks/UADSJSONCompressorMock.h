#import <Foundation/Foundation.h>
#import "USRVBodyBase64GzipCompressor.h"
NS_ASSUME_NONNULL_BEGIN

@interface UADSJSONCompressorMock : NSObject<USRVStringCompressor, USRVDataCompressor>

- (NSDictionary*)uncompress:(NSString*)compressedString;
@end

NS_ASSUME_NONNULL_END
