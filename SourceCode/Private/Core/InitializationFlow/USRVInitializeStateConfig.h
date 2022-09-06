#import "USRVInitialize.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface USRVInitializeStateConfig : USRVInitializeState

@property (nonatomic, strong) USRVConfiguration *localConfig;
@property (nonatomic, assign) int retries;
@property (nonatomic, assign) long retryDelay;

- (instancetype)initWithConfiguration: (USRVConfiguration *)configuration retries: (int)retries retryDelay: (long)retryDelay;

@end

NS_ASSUME_NONNULL_END
