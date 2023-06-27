#import <netdb.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>


#import "USRVConnectivityUtils.h"

static CTTelephonyNetworkInfo *netinfo;

@implementation USRVConnectivityUtils

+ (void)initCarrierInfo {
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        netinfo = [CTTelephonyNetworkInfo new];
    });
}

+ (NSString *)networkTypeAsString {
    return netinfo.currentRadioAccessTechnology ? : @"";
}

+ (NSInteger)getNetworkType {
    NSString *currentRadioAccessTechnology = netinfo.currentRadioAccessTechnology;
    if ([currentRadioAccessTechnology isEqualToString: CTRadioAccessTechnologyGPRS]) {
        USRVLogInfo(@"GPRS");
        return NetworkTypeGPRS;
    } else if ([currentRadioAccessTechnology isEqualToString: CTRadioAccessTechnologyEdge]) {
        USRVLogInfo(@"Edge");
        return NetworkTypeEdge;
    } else if ([currentRadioAccessTechnology isEqualToString: CTRadioAccessTechnologyWCDMA]) {
        USRVLogInfo(@"WCDMA");
        return NetworkTypeCDMA;
    } else if ([currentRadioAccessTechnology isEqualToString: CTRadioAccessTechnologyHSDPA]) {
        USRVLogInfo(@"HSDPA");
        return NetworkTypeHSDPA;
    } else if ([currentRadioAccessTechnology isEqualToString: CTRadioAccessTechnologyHSUPA]) {
        USRVLogInfo(@"HSUPA");
        return NetworkTypeHSUPA;
    } else if ([currentRadioAccessTechnology isEqualToString: CTRadioAccessTechnologyCDMA1x]) {
        USRVLogInfo(@"CDMA1x");
        return NetworkTypeCDMA;
    } else if ([currentRadioAccessTechnology isEqualToString: CTRadioAccessTechnologyCDMAEVDORev0]) {
        USRVLogInfo(@"CDMAEVDO0Rev0");
        return NetworkTypeEVDO0;
    } else if ([currentRadioAccessTechnology isEqualToString: CTRadioAccessTechnologyCDMAEVDORevA]) {
        USRVLogInfo(@"CDMAEVDO0RevA");
        return NetworkTypeEVDOA;
    } else if ([currentRadioAccessTechnology isEqualToString: CTRadioAccessTechnologyCDMAEVDORevB]) {
        USRVLogInfo(@"CDMAEVDO0RevB");
        return NetworkTypeEVDOB;
    } else if ([currentRadioAccessTechnology isEqualToString: CTRadioAccessTechnologyeHRPD]) {
        USRVLogInfo(@"HRPD");
        return NetworkTypeHRPD;
    } else if ([currentRadioAccessTechnology isEqualToString: CTRadioAccessTechnologyLTE]) {
        USRVLogInfo(@"LTE");
        return NetworkTypeLTE;
    }
    
    if (@available(iOS 14.1, *)) {
        if ([currentRadioAccessTechnology isEqualToString: CTRadioAccessTechnologyNRNSA]) {
            USRVLogInfo(@"NRNSA")
            return NetworkTypeNRNSA;
        } else if ([currentRadioAccessTechnology isEqualToString: CTRadioAccessTechnologyNR]) {
            USRVLogInfo(@"NR")
            return NetworkTypeNR;
        }
    }
    
    return NetworkTypeUnknown;
} /* getNetworkType */

+ (NetworkStatus)networkStatusForFlags: (SCNetworkReachabilityFlags)flags {
    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0) {
        return NotReachable;
    }

    NetworkStatus returnValue = NotReachable;

    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0) {
        returnValue = ReachableViaWiFi;
    }

    if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand) != 0) ||
         (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0)) {
        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0) {
            returnValue = ReachableViaWiFi;
        }
    }

    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN) {
        returnValue = ReachableViaWWAN;
    }

    return returnValue;
} /* networkStatusForFlags */

+ (NetworkStatus)getNetworkStatus {
    NetworkStatus retValue = NotReachable;

    struct sockaddr_in zeroAddress;

    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;

    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)&zeroAddress);

    if (reachability != NULL) {
        SCNetworkReachabilityFlags flags;

        if (SCNetworkReachabilityGetFlags(reachability, &flags)) {
            retValue = [self networkStatusForFlags: flags];
        }
    }

    if (reachability) {
        CFRelease(reachability);
    }

    return retValue;
} /* getNetworkStatus */

+ (NSString *)getNetworkStatusString {
    NSString *type = nil;

    switch ([self getNetworkStatus]) {
        case ReachableViaWiFi:
            type = @"wifi";
            break;

        case ReachableViaWWAN:
            type = @"cellular";
            break;

        default:
            type = @"none";
            break;
    }
    return type;
}

@end
