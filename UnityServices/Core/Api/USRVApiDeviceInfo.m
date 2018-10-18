#import "USRVApiDeviceInfo.h"
#import "USRVConnectivityUtils.h"
#import "USRVWebViewCallback.h"
#import "USRVDevice.h"
#import "USRVClientProperties.h"
#import "USRVDeviceError.h"
#import "USRVVolumeChange.h"
#import "USRVWebViewApp.h"
#import "USRVWebViewEventCategory.h"

static USRVVolumeChangeListener *volumeChangeListener = NULL;

@implementation USRVVolumeChangeListener
- (void)onVolumeChanged:(float)volume {
    if ([USRVWebViewApp getCurrentApp]) {
        [[USRVWebViewApp getCurrentApp] sendEvent:@"VOLUME_CHANGED"
            category:NSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryDeviceInfo)
            param1:[NSNumber numberWithFloat:volume], [NSNumber numberWithFloat:[USRVDevice getDeviceMaxVolume]], nil];
    }
}
@end

@implementation USRVApiDeviceInfo

+ (void)WebViewExposed_getAdvertisingTrackingId:(USRVWebViewCallback *)callback {
    [callback invoke:[USRVDevice getAdvertisingTrackingId], nil];
}

+ (void)WebViewExposed_getLimitAdTrackingFlag:(USRVWebViewCallback *)callback {
    [callback invoke:[NSNumber numberWithBool:[USRVDevice isLimitTrackingEnabled]], nil];
}

+ (void)WebViewExposed_getOsVersion:(USRVWebViewCallback *)callback {
    [callback invoke:[USRVDevice getOsVersion], nil];
}

+ (void)WebViewExposed_getModel:(USRVWebViewCallback *)callback {
    [callback invoke:[USRVDevice getModel], nil];
}

+ (void)WebViewExposed_getConnectionType:(USRVWebViewCallback *)callback {
    NSString *type = nil;
    
    NetworkStatus status = [USRVConnectivityUtils getNetworkStatus];
    if (status == ReachableViaWiFi) {
        type = @"wifi";
    } else if (status == ReachableViaWWAN) {
        type = @"cellular";
    } else {
        type = @"none";
    }
    
    [callback invoke:type, nil];
}

+ (void)WebViewExposed_getNetworkType:(USRVWebViewCallback *)callback {
    [callback invoke:[NSNumber numberWithInteger:[USRVDevice getNetworkType]], nil];
}

+ (void)WebViewExposed_getScreenScale:(USRVWebViewCallback *)callback {
    [callback invoke:[NSNumber numberWithFloat:[USRVDevice getScreenScale]], nil];
}

+ (void)WebViewExposed_getScreenWidth:(USRVWebViewCallback *)callback {
    [callback invoke:[USRVDevice getScreenWidth], nil];
}

+ (void)WebViewExposed_getScreenHeight:(USRVWebViewCallback *)callback {
    [callback invoke:[USRVDevice getScreenHeight], nil];
}

+ (void)WebViewExposed_getNetworkOperator:(USRVWebViewCallback *)callback {
    [callback invoke:[USRVDevice getNetworkOperator], nil];
}

+ (void)WebViewExposed_getNetworkOperatorName:(USRVWebViewCallback *)callback {
    [callback invoke:[USRVDevice getNetworkOperatorName], nil];
}

+ (void)WebViewExposed_getHeadset:(USRVWebViewCallback *)callback {
    [callback invoke:[NSNumber numberWithBool:[USRVDevice isWiredHeadsetOn]], nil];
}

+ (void)WebViewExposed_getTimeZone:(NSNumber *)dst callback:(USRVWebViewCallback *)callback {
    [callback invoke:[USRVDevice getTimeZone:[dst boolValue]], nil];
}

+ (void)WebViewExposed_getTimeZoneOffset:(USRVWebViewCallback *)callback {
    [callback invoke:[NSNumber numberWithInteger:[USRVDevice getTimeZoneOffset]], nil];
}

+ (void)WebViewExposed_getSystemLanguage:(USRVWebViewCallback *)callback {
    [callback invoke:[USRVDevice getPreferredLocalization], nil];
}

+ (void)WebViewExposed_getDeviceVolume:(USRVWebViewCallback *)callback {
    [callback invoke:[NSNumber numberWithFloat:[USRVDevice getOutputVolume]], nil];
}

+ (void)WebViewExposed_getScreenBrightness:(USRVWebViewCallback *)callback {
    [callback invoke:[NSNumber numberWithFloat:[USRVDevice getScreenBrightness]], nil];
}

+ (void)WebViewExposed_getFreeSpace:(USRVWebViewCallback *)callback {
    [callback invoke:[USRVDevice getFreeSpaceInKilobytes], nil];
}

+ (void)WebViewExposed_getTotalSpace:(USRVWebViewCallback *)callback {
    [callback invoke:[USRVDevice getTotalSpaceInKilobytes], nil];
}

+ (void)WebViewExposed_getBatteryLevel:(USRVWebViewCallback *)callback {
    [callback invoke:[NSNumber numberWithFloat:[USRVDevice getBatteryLevel]], nil];
}

+ (void)WebViewExposed_getBatteryStatus:(USRVWebViewCallback *)callback {
    [callback invoke:[NSNumber numberWithInteger:[USRVDevice getBatteryStatus]], nil];
}

+ (void)WebViewExposed_getFreeMemory:(USRVWebViewCallback *)callback {
    [callback invoke:[USRVDevice getFreeMemoryInKilobytes], nil];
}

+ (void)WebViewExposed_getTotalMemory:(USRVWebViewCallback *)callback {
    [callback invoke:[USRVDevice getTotalMemoryInKilobytes], nil];
}

+ (void)WebViewExposed_isRooted:(USRVWebViewCallback *)callback {
    [callback invoke:[NSNumber numberWithBool:[USRVDevice isRooted]], nil];
}

+ (void)WebViewExposed_getUniqueEventId:(USRVWebViewCallback *)callback {
    [callback invoke:[USRVDevice getUniqueEventId], nil];
}

+ (void)WebViewExposed_getUserInterfaceIdiom:(USRVWebViewCallback *)callback {
    [callback invoke:[NSNumber numberWithInteger:[USRVDevice getUserInterfaceIdiom]], nil];
}

+ (void)WebViewExposed_isSimulator:(USRVWebViewCallback *)callback {
    [callback invoke:[NSNumber numberWithBool:[USRVDevice isSimulator]], nil];
}

+ (void)WebViewExposed_getSupportedOrientationsPlist:(USRVWebViewCallback *)callback {
    [callback invoke:[USRVClientProperties getSupportedOrientationsPlist], nil];
}

+ (void)WebViewExposed_getSupportedOrientations:(USRVWebViewCallback *)callback {
    [callback invoke:[NSNumber numberWithInt:[USRVClientProperties getSupportedOrientations]], nil];
}

+ (void)WebViewExposed_getSensorList:(USRVWebViewCallback *)callback {
    NSArray<NSString *> *sensorList = [USRVDevice getSensorList];
    if (sensorList) {
        [callback invoke:sensorList, nil];
    }
    else {
        [callback error:NSStringFromDeviceError(kUnityServicesCouldntGetSensorInfo) arg1:nil];
    }
}

+ (void)WebViewExposed_getProcessInfo:(USRVWebViewCallback *)callback {
    NSDictionary* processInfo = [USRVDevice getProcessInfo];
    if (processInfo) {
        [callback invoke:[USRVDevice getProcessInfo], nil];
    } else {
        [callback error:NSStringFromDeviceError(kUnityServicesCouldntGetProcessInfo) arg1:nil];
    }
    
}

+ (void)WebViewExposed_getStatusBarWidth:(USRVWebViewCallback *)callback {
    NSNumber *width = [NSNumber numberWithFloat:[UIApplication sharedApplication].statusBarFrame.size.width];
    [callback invoke:width, nil];
}

+ (void)WebViewExposed_getStatusBarHeight:(USRVWebViewCallback *)callback {
    NSNumber *height = [NSNumber numberWithFloat: [UIApplication sharedApplication].statusBarFrame.size.height];
    [callback invoke:height, nil];
}

+ (void)WebViewExposed_isStatusBarHidden:(USRVWebViewCallback *)callback {
    NSNumber *isHidden = [NSNumber numberWithBool:[UIApplication sharedApplication].statusBarHidden];
    [callback invoke:isHidden, nil];
}

+ (void)WebViewExposed_getGLVersion:(USRVWebViewCallback *)callback {
    [callback invoke:[USRVDevice getGLVersion], nil];
}

+ (void)WebViewExposed_getDeviceMaxVolume:(USRVWebViewCallback *)callback {
    [callback invoke:[NSNumber numberWithFloat:[USRVDevice getDeviceMaxVolume]], nil];
}

+ (void)WebViewExposed_registerVolumeChangeListener:(USRVWebViewCallback *)callback {
    if (!volumeChangeListener) {
        volumeChangeListener = [[USRVVolumeChangeListener alloc] init];
        [USRVVolumeChange registerDelegate:volumeChangeListener];
    }

    [callback invoke:nil];
}

+ (void)WebViewExposed_unregisterVolumeChangeListener:(USRVWebViewCallback *)callback {
    if (volumeChangeListener) {
        [USRVVolumeChange unregisterDelegate:volumeChangeListener];
        volumeChangeListener = NULL;
    }

    [callback invoke:nil];
}

+ (void)WebViewExposed_getCPUCount:(USRVWebViewCallback *)callback {
    [callback invoke:[NSNumber numberWithUnsignedInteger:[USRVDevice getCPUCount]], nil];
}

@end
