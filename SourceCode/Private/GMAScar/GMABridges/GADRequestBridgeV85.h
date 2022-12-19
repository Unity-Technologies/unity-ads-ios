#import "GADRequestBridge.h"

NS_ASSUME_NONNULL_BEGIN

@interface GADRequestBridgeV85 : GADRequestBridge
@property (nonatomic, copy, nullable) NSString *requestAgent;
@property(nonatomic, copy, nullable) NSString *adString;

- (void)registerAdNetworkExtras:(nonnull id)extras;
@end

NS_ASSUME_NONNULL_END
