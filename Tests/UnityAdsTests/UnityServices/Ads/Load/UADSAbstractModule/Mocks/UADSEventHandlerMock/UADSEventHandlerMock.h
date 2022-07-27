#import "UADSEventHandler.h"
NS_ASSUME_NONNULL_BEGIN


@interface UADSEventHandlerMock : NSObject<UADSEventHandler>
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSArray<UADSInternalError *> *> *errors;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *startedCalls;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *onSuccessCalls;
@end

NS_ASSUME_NONNULL_END
