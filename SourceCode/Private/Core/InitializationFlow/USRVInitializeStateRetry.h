#import "USRVInitialize.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface USRVInitializeStateRetry : USRVInitializeState

@property (nonatomic, strong) id retryState;
@property (nonatomic, assign) long retryDelay;

- (instancetype)initWithConfiguration: (USRVConfiguration *)configuration retryState: (id)retryState retryDelay: (long)retryDelay;

@end

NS_ASSUME_NONNULL_END
