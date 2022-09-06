#import "USRVInitialize.h"

NS_ASSUME_NONNULL_BEGIN

@interface USRVInitializeStateLoadWeb : USRVInitializeState

- (instancetype)initWithConfiguration: (USRVConfiguration *)configuration retries: (int)retries retryDelay: (long)retryDelay;

@property (nonatomic, assign) int retries;
@property (nonatomic, assign) long retryDelay;

@end

NS_ASSUME_NONNULL_END
