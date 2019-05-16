#import <netdb.h>
@import CoreTelephony;


#import "USRVConnectivityUtils.h"

static CTTelephonyNetworkInfo *netinfo;

@implementation USRVConnectivityUtils

+ (void)initCarrierInfo {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        netinfo = [CTTelephonyNetworkInfo new];
    });
}

+ (NSInteger)getNetworkType {
    if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyGPRS]) {
        NSLog(@"GPRS");
        return NetworkTypeGPRS;
    } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyEdge]) {
        NSLog(@"Edge");
        return NetworkTypeEdge;
    } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyWCDMA]) {
        NSLog(@"WCDMA");
        return NetworkTypeCDMA;
    } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyHSDPA]) {
        NSLog(@"HSDPA");
        return NetworkTypeHSDPA;
    } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyHSUPA]) {
        NSLog(@"HSUPA");
        return NetworkTypeHSUPA;
    } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMA1x]) {
        NSLog(@"CDMA1x");
        return NetworkTypeCDMA;
    } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0]) {
        NSLog(@"CDMAEVDO0Rev0");
        return NetworkTypeEVDO0;
    } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA]) {
        NSLog(@"CDMAEVDO0RevA");
        return NetworkTypeEVDOA;
    } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB]) {
        NSLog(@"CDMAEVDO0RevB");
        return NetworkTypeEVDOB;
    } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyeHRPD]) {
        NSLog(@"HRPD");
        return NetworkTypeHRPD;
    } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyLTE]) {
        NSLog(@"LTE");
        return NetworkTypeLTE;
    }
    
    return NetworkTypeUnknown;
}

+ (NetworkStatus)networkStatusForFlags:(SCNetworkReachabilityFlags)flags {
    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0) {
        return NotReachable;
    }
    
    NetworkStatus returnValue = NotReachable;
    
    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0) {
        returnValue = ReachableViaWiFi;
    }
    
    if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
         (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0)) {
        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0) {
            returnValue = ReachableViaWiFi;
        }
    }
    
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN) {
        returnValue = ReachableViaWWAN;
    }
    
    return returnValue;
}

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
            retValue = [self networkStatusForFlags:flags];
        }
    }

    if (reachability) {
        CFRelease(reachability);
    }

    return retValue;
}

@end

