#import <Foundation/Foundation.h>
#import "USRVBodyBase64GzipCompressor.h"

NS_ASSUME_NONNULL_BEGIN

@interface USRVBodyURLEncodedCompressorDecorator : NSObject<USRVStringCompressor>
+ (instancetype)decorateOriginal: (id<USRVStringCompressor>)original;
@end

NS_ASSUME_NONNULL_END
