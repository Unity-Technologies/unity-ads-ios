#import "USRVConfiguration.h"

@protocol ISDKMetrics
- (void)sendEvent:(NSString *)event;
- (void)sendEventWithTags:(NSString *)event tags:(NSDictionary<NSString *, NSString *> *)tags;
@end

@interface USRVSDKMetrics : NSObject
+ (void)setConfiguration:(USRVConfiguration *)configuration;
+ (id <ISDKMetrics>)getInstance;
@end
