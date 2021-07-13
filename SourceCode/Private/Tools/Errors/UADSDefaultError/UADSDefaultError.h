#import "UADSGenericError.h"
NS_ASSUME_NONNULL_BEGIN

/// Class that provides simple interface to create an error from a string
/// and then pass it back to the webView.
@interface UADSDefaultError : NSObject<UADSError>

+ (instancetype)newWithString: (NSString *)errorMessage;

@end

NS_ASSUME_NONNULL_END
