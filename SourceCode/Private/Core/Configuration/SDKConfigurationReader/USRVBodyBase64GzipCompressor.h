
#import <Foundation/Foundation.h>
#import "USRVDataGzipCompressor.h"

NS_ASSUME_NONNULL_BEGIN

@protocol USRVStringCompressor <NSObject>

- (NSString *)compressedIntoString: (NSDictionary *)dictionary;

@end

@interface USRVBodyBase64GzipCompressor : NSObject<USRVStringCompressor>
+ (instancetype)newWithDataCompressor: (id<USRVDataCompressor>)compressor;
@end


NS_ASSUME_NONNULL_END
