#import "USRVSDKMetrics.h"
#import "UADSMetricSender.h"
#import "UADSServiceProvider.h"

@implementation USRVSDKMetrics


+ (id <ISDKMetrics>)getInstance {
    return UADSServiceProvider.sharedInstance.metricSender;
}

@end
