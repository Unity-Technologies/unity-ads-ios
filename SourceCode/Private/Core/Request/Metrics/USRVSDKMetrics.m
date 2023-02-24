#import "USRVSDKMetrics.h"
#import "UADSMetricSender.h"
#import "UADSServiceProviderContainer.h"

@implementation USRVSDKMetrics


+ (id <ISDKMetrics>)getInstance {
    return UADSServiceProviderContainer.sharedInstance.serviceProvider.metricSender;
}

@end
