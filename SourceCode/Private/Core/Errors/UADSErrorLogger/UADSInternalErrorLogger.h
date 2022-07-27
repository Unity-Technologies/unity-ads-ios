#import <Foundation/Foundation.h>
#import "UADSInternalError.h"
NS_ASSUME_NONNULL_BEGIN

@protocol UADSInternalErrorHandler <NSObject>
- (void)catchError: (UADSInternalError *)error forId: (NSString *)identifier;
@end


NS_ASSUME_NONNULL_END
