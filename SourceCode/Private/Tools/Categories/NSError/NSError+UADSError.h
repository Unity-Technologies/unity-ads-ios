#import "UADSGenericError.h"
NS_ASSUME_NONNULL_BEGIN

NSString * uads_extractErrorString(id error);
NSString * uads_tryExtractAsUADSErrorString(id error);
NSString * uads_tryExtractAsNSString(id error);
NSNumber * _Nullable  uads_extractErrorCode(id error);
@interface NSError (Category) <UADSError>

@end

NS_ASSUME_NONNULL_END
