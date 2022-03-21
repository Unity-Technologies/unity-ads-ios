#import <Foundation/Foundation.h>
#import "USRVBodyBase64GzipCompressor.h"
NS_ASSUME_NONNULL_BEGIN

@interface USRVBodyCompressorMock : NSObject<USRVStringCompressor>
@property (nonatomic, copy) NSString *expectedString;
@end

NS_ASSUME_NONNULL_END
