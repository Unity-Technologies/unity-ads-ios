#import "USRVResolve.h"

typedef void(^UnityServicesResolveRequestCompletion)(NSString *host, NSString *address, NSString *error, NSString *errorMessage);

@interface USRVResolveOperation : NSOperation

@property (nonatomic, strong) UnityServicesResolveRequestCompletion completeBlock;
@property (nonatomic, strong) USRVResolve *resolve;

- (instancetype)initWithHostName:(NSString *)hostName completeBlock:(UnityServicesResolveRequestCompletion)completeBlock;

@end
