#import "SKAdNetworkProxy.h"
#import "UADSStoreKitLoader.h"


static NSString * const kSKAdNetworkProxyStartImpressionMethod = @"startImpression:completionHandler:";
static NSString * const kSKAdNetworkProxyEndImpressionMethod = @"endImpression:completionHandler:";

@implementation SKAdNetworkProxy

+ (NSString *)className {
    return @"SKAdNetwork";
}

+ (void)startImpression:(SKAdImpressionProxy *)impression
      completionHandler:(UADSNSErrorCompletion) completion; {
    
    [self callClassMethod: kSKAdNetworkProxyStartImpressionMethod
                     args: @[impression.proxyObject, completion]];
}

+ (void)endImpression:(SKAdImpressionProxy *)impression
    completionHandler:(UADSNSErrorCompletion) completion; {
    [self callClassMethod: kSKAdNetworkProxyEndImpressionMethod
                     args: @[impression.proxyObject, completion]];
}

@end
