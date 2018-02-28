#import "UADSApiSensorInfo.h"
#import "UADSWebViewCallback.h"
#import "UADSSensorInfo.h"
#import "UADSSensorInfoError.h"

@implementation UADSApiSensorInfo

+ (void)WebViewExposed_startAccelerometerUpdates:(NSNumber *)updateInterval callback:(UADSWebViewCallback *)callback {
    BOOL started = [UADSSensorInfo startAccelerometerUpdates:[updateInterval doubleValue]];
    [callback invoke:[NSNumber numberWithBool:started], nil];
}

+ (void)WebViewExposed_stopAccelerometerUpdates:(UADSWebViewCallback *)callback {
    [UADSSensorInfo stopAccelerometerUpdates];
    [callback invoke:nil];
}

+ (void)WebViewExposed_isAccelerometerActive:(UADSWebViewCallback *)callback {
    [callback invoke:[NSNumber numberWithBool:[UADSSensorInfo isAccelerometerActive]], nil];
}

+ (void)WebViewExposed_getAccelerometerData:(UADSWebViewCallback *)callback {
    NSDictionary *accelerometerData = [UADSSensorInfo getAccelerometerData];
    if(accelerometerData != nil) {
        [callback invoke:accelerometerData, nil];
    } else {
        [callback error:NSStringFromSensorInfoError(kUnityAdsAccelerometerDataNotAvailable) arg1:nil];
    }
}

@end

