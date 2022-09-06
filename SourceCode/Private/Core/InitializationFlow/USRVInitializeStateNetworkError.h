#import "USRVInitialize.h"
#import <Foundation/Foundation.h>
#import "USRVInitializeStateError.h"

NS_ASSUME_NONNULL_BEGIN

@interface USRVInitializeStateNetworkError : USRVInitializeStateError <USRVConnectivityDelegate>

@property (nonatomic, strong) NSCondition *blockCondition;
@property (nonatomic, assign) int receivedConnectedEvents;
@property (nonatomic, assign) long long lastConnectedEventTimeMs;

@end

NS_ASSUME_NONNULL_END
