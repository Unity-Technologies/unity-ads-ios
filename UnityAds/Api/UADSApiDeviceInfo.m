#import "UADSApiDeviceInfo.h"
#import "UADSWebViewCallback.h"
#import "UADSDevice.h"
#import "UADSConnectivityUtils.h"
#import "UADSClientProperties.h"


@implementation UADSApiDeviceInfo

+ (void)WebViewExposed_getAdvertisingTrackingId:(UADSWebViewCallback *)callback {
    [callback invoke:[UADSDevice getAdvertisingTrackingId], nil];
}

+ (void)WebViewExposed_getLimitAdTrackingFlag:(UADSWebViewCallback *)callback {
    [callback invoke:[NSNumber numberWithBool:[UADSDevice isLimitTrackingEnabled]], nil];
}

+ (void)WebViewExposed_getOsVersion:(UADSWebViewCallback *)callback {
    [callback invoke:[UADSDevice getOsVersion], nil];
}

+ (void)WebViewExposed_getModel:(UADSWebViewCallback *)callback {
    [callback invoke:[UADSDevice getModel], nil];
}

+ (void)WebViewExposed_getConnectionType:(UADSWebViewCallback *)callback {
    NSString *type = nil;
    
    NetworkStatus status = [UADSConnectivityUtils getNetworkStatus];
    if (status == ReachableViaWiFi) {
        type = @"wifi";
    } else if (status == ReachableViaWWAN) {
        type = @"cellular";
    } else {
        type = @"none";
    }
    
    [callback invoke:type, nil];
}

+ (void)WebViewExposed_getNetworkType:(UADSWebViewCallback *)callback {
    [callback invoke:[NSNumber numberWithInteger:[UADSDevice getNetworkType]], nil];
}

+ (void)WebViewExposed_getScreenScale:(UADSWebViewCallback *)callback {
    [callback invoke:[NSNumber numberWithFloat:[UADSDevice getScreenScale]], nil];
}

+ (void)WebViewExposed_getScreenWidth:(UADSWebViewCallback *)callback {
    [callback invoke:[UADSDevice getScreenWidth], nil];
}

+ (void)WebViewExposed_getScreenHeight:(UADSWebViewCallback *)callback {
    [callback invoke:[UADSDevice getScreenHeight], nil];
}

+ (void)WebViewExposed_getNetworkOperator:(UADSWebViewCallback *)callback {
    [callback invoke:[UADSDevice getNetworkOperator], nil];
}

+ (void)WebViewExposed_getNetworkOperatorName:(UADSWebViewCallback *)callback {
    [callback invoke:[UADSDevice getNetworkOperatorName], nil];
}

+ (void)WebViewExposed_getHeadset:(UADSWebViewCallback *)callback {
    [callback invoke:[NSNumber numberWithBool:[UADSDevice isWiredHeadsetOn]], nil];
}

+ (void)WebViewExposed_getTimeZone:(NSNumber *)dst callback:(UADSWebViewCallback *)callback {
    [callback invoke:[UADSDevice getTimeZone:[dst boolValue]], nil];
}

+ (void)WebViewExposed_getSystemLanguage:(UADSWebViewCallback *)callback {
    [callback invoke:[UADSDevice getPreferredLocalization], nil];
}

+ (void)WebViewExposed_getDeviceVolume:(UADSWebViewCallback *)callback {
    [callback invoke:[NSNumber numberWithFloat:[UADSDevice getOutputVolume]], nil];
}

+ (void)WebViewExposed_getScreenBrightness:(UADSWebViewCallback *)callback {
    [callback invoke:[NSNumber numberWithFloat:[UADSDevice getScreenBrightness]], nil];
}

+ (void)WebViewExposed_getFreeSpace:(UADSWebViewCallback *)callback {
    [callback invoke:[UADSDevice getFreeSpaceInKilobytes], nil];
}

+ (void)WebViewExposed_getTotalSpace:(UADSWebViewCallback *)callback {
    [callback invoke:[UADSDevice getTotalSpaceInKilobytes], nil];
}

+ (void)WebViewExposed_getBatteryLevel:(UADSWebViewCallback *)callback {
    [callback invoke:[NSNumber numberWithFloat:[UADSDevice getBatteryLevel]], nil];
}

+ (void)WebViewExposed_getBatteryStatus:(UADSWebViewCallback *)callback {
    [callback invoke:[NSNumber numberWithInteger:[UADSDevice getBatteryStatus]], nil];
}

+ (void)WebViewExposed_getFreeMemory:(UADSWebViewCallback *)callback {
    [callback invoke:[UADSDevice getFreeMemoryInKilobytes], nil];
}

+ (void)WebViewExposed_getTotalMemory:(UADSWebViewCallback *)callback {
    [callback invoke:[UADSDevice getTotalMemoryInKilobytes], nil];
}

+ (void)WebViewExposed_isRooted:(UADSWebViewCallback *)callback {
    [callback invoke:[NSNumber numberWithBool:[UADSDevice isRooted]], nil];
}

+ (void)WebViewExposed_getUniqueEventId:(UADSWebViewCallback *)callback {
    [callback invoke:[UADSDevice getUniqueEventId], nil];
}

+ (void)WebViewExposed_getUserInterfaceIdiom:(UADSWebViewCallback *)callback {
    [callback invoke:[NSNumber numberWithInteger:[UADSDevice getUserInterfaceIdiom]], nil];
}

+ (void)WebViewExposed_isSimulator:(UADSWebViewCallback *)callback {
    [callback invoke:[NSNumber numberWithBool:[UADSDevice isSimulator]], nil];
}

+ (void)WebViewExposed_getSupportedOrientationsPlist:(UADSWebViewCallback *)callback {
    [callback invoke:[UADSClientProperties getSupportedOrientationsPlist], nil];
}

+ (void)WebViewExposed_getSupportedOrientations:(UADSWebViewCallback *)callback {
    [callback invoke:[NSNumber numberWithInt:[UADSClientProperties getSupportedOrientations]], nil];
}

+ (void)WebViewExposed_getStatusBarWidth:(UADSWebViewCallback *)callback {
    NSNumber *width = [NSNumber numberWithFloat:[UIApplication sharedApplication].statusBarFrame.size.width];
    [callback invoke:width, nil];
}

+ (void)WebViewExposed_getStatusBarHeight:(UADSWebViewCallback *)callback {
    NSNumber *height = [NSNumber numberWithFloat: [UIApplication sharedApplication].statusBarFrame.size.height];
    [callback invoke:height, nil];
}

+ (void)WebViewExposed_isStatusBarHidden:(UADSWebViewCallback *)callback {
    NSNumber *isHidden = [NSNumber numberWithBool:[UIApplication sharedApplication].statusBarHidden];
    [callback invoke:isHidden, nil];
}

@end
