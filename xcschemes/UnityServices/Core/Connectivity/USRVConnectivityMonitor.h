@import Foundation;
@import SystemConfiguration;
@import CoreFoundation;

#import <netinet/in.h>
#import "USRVConnectivityDelegate.h"

@interface USRVConnectivityMonitor : NSObject

+ (void)setConnectionMonitoring:(BOOL)status;

+ (void)startListening:(id<USRVConnectivityDelegate>)connectivityDelegate;

+ (void)stopListening:(id<USRVConnectivityDelegate>)connectivitydelegate;

+ (void)stopAll;

@end


