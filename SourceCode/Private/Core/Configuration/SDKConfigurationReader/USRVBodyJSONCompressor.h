#import <Foundation/Foundation.h>
#import "USRVBodyBase64GzipCompressor.h"

NS_ASSUME_NONNULL_BEGIN

@interface USRVBodyJSONCompressor : NSObject<USRVStringCompressor>

+ (id<USRVStringCompressor>)defaultURLEncoded;
@end

NS_ASSUME_NONNULL_END
