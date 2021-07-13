#import "USRVWebViewMethodInvokeOperation.h"
#import "USRVConfiguration.h"

@interface UADSWebViewShowOperation : USRVWebViewMethodInvokeOperation

- (instancetype)initWithPlacementId: (NSString *)placementId parametersDictionary: (NSDictionary *)parametersDictioanry;
+ (void)setConfiguration: (USRVConfiguration *)config;

@end
