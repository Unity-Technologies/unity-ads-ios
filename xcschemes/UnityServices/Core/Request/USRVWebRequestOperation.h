#import "USRVWebRequest.h"

typedef void(^UnityServicesWebRequestCompletion)(NSString *url, NSError *error, NSString *response, long responseCode, NSDictionary<NSString*,NSString*> *headers);

@interface USRVWebRequestOperation : NSOperation

@property (nonatomic, strong) USRVWebRequest *request;
@property (nonatomic, strong) UnityServicesWebRequestCompletion completeBlock;

- (instancetype)initWithUrl:(NSString *)url requestType:(NSString *)requestType headers:(NSDictionary<NSString*,NSArray<NSString*>*> *)headers body:(NSString *)body completeBlock:(UnityServicesWebRequestCompletion)completeBlock connectTimeout:(int)connectTimeout;

@end
