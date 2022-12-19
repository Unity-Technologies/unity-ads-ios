#import "GMAQueryInfoRequestFactoryV85.h"
#import "GADExtrasBridge.h"
#import "GADRequestBridgeV85.h"
#import "USRVSdkProperties.h"

@implementation GMAQueryInfoRequestFactoryV85

- (nonnull GADRequestBridge *)createRequest {
    GADRequestBridgeV85 *request = [GADRequestBridgeV85 getNewRequest];
    GADExtrasBridge *extras = [GADExtrasBridge getNewExtras];
    extras.additionalParameters = @{@"query_info_type" : @"requester_type_5"};
    [request registerAdNetworkExtras:extras];
    request.requestAgent = [NSString stringWithFormat:@"UnityScar%@", [USRVSdkProperties getVersionName]];
    
    return request;
}

@end
