#import "UADSResolve.h"

typedef void(^UnityAdsResolveRequestCompletion)(NSString *host, NSString *address, NSString *error, NSString *errorMessage);

@interface UADSResolveOperation : NSOperation

@property (nonatomic, strong) UnityAdsResolveRequestCompletion completeBlock;
@property (nonatomic, strong) UADSResolve *resolve;

- (instancetype)initWithHostName:(NSString *)hostName completeBlock:(UnityAdsResolveRequestCompletion)completeBlock;

@end