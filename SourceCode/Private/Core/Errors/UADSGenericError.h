#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

// An interface to help unify errors
// errorString provides localizedDescription/Name for printing
// errorInfo contains an array of additional info. Useful when we need to pass an error back to WebView
@protocol UADSError<NSObject>
- (NSString *)             errorDomain;
- (NSNumber *)             errorCode;
- (NSString *)             errorString;
- (nullable NSDictionary *)errorInfo;
@end


@protocol UADSErrorHandler <NSObject>
- (void)                   catchError: (id<UADSError>)error;

@end

NS_ASSUME_NONNULL_END
