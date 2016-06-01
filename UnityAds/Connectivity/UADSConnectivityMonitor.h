@import Foundation;
@import SystemConfiguration;
@import CoreFoundation;

#import <netinet/in.h>
#import "UADSConnectivityDelegate.h"

@interface UADSConnectivityMonitor : NSObject

+ (void)setConnectionMonitoring:(BOOL)status;

+ (void)startListening:(id<UADSConnectivityDelegate>)connectivityDelegate;

+ (void)stopListening:(id<UADSConnectivityDelegate>)connectivitydelegate;

+ (void)stopAll;

@end


