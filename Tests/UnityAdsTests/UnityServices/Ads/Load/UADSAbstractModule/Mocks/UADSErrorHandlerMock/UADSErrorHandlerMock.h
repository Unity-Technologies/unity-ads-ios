#import "UADSInternalErrorLogger.h"
NS_ASSUME_NONNULL_BEGIN


@interface UADSErrorHandlerMock : NSObject<UADSInternalErrorHandler>
@property (nonatomic, strong) NSArray<UADSInternalError *> *errors;
@end

NS_ASSUME_NONNULL_END
