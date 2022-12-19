#import "GADRequestBridge.h"

NS_ASSUME_NONNULL_BEGIN

@protocol GMAQueryInfoRequestFactory <NSObject>

- (GADRequestBridge *)createRequest;

@end

@interface GMAQueryInfoRequestFactoryBase : NSObject <GMAQueryInfoRequestFactory>

@end

NS_ASSUME_NONNULL_END
