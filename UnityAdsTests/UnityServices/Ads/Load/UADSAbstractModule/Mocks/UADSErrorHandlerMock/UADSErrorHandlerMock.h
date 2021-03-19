#import "UADSErrorLogger.h"
NS_ASSUME_NONNULL_BEGIN


@interface UADSErrorHandlerMock : NSObject<UADSErrorHandler>
@property (nonatomic, strong) NSArray<UADSInternalError *> *errors;
@end

NS_ASSUME_NONNULL_END
