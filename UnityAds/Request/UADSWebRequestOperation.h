#import "UADSWebRequest.h"

typedef void(^UnityAdsWebRequestCompletion)(NSString *url, NSError *error, NSString *response, long responseCode, NSDictionary<NSString*,NSString*> *headers);

@interface UADSWebRequestOperation : NSOperation

@property (nonatomic, strong) UADSWebRequest *request;
@property (nonatomic, strong) UnityAdsWebRequestCompletion completeBlock;

- (instancetype)initWithUrl:(NSString *)url requestType:(NSString *)requestType headers:(NSDictionary<NSString*,NSArray<NSString*>*> *)headers body:(NSString *)body completeBlock:(UnityAdsWebRequestCompletion)completeBlock connectTimeout:(int)connectTimeout;

@end