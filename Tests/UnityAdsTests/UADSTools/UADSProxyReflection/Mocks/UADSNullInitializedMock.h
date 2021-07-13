#import "UADSProxyReflection.h"
NS_ASSUME_NONNULL_BEGIN

@interface UADSNullInitializedMock : NSObject
@end

@interface UADSNullInitializedReflectionMock : UADSProxyReflection
@end

@interface UADSNSObjectReflectionMock : UADSProxyReflection
+ (NSNumber *)proxyDeallocationCount;
@end

NS_ASSUME_NONNULL_END
