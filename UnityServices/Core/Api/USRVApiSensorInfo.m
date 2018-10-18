#import "USRVApiSensorInfo.h"
#import "USRVWebViewCallback.h"
#import "USRVSensorInfo.h"
#import "USRVSensorInfoError.h"

@implementation USRVApiSensorInfo

+ (void)WebViewExposed_startAccelerometerUpdates:(NSNumber *)updateInterval callback:(USRVWebViewCallback *)callback {
    BOOL started = [USRVSensorInfo startAccelerometerUpdates:[updateInterval doubleValue]];
    [callback invoke:[NSNumber numberWithBool:started], nil];
}

+ (void)WebViewExposed_stopAccelerometerUpdates:(USRVWebViewCallback *)callback {
    [USRVSensorInfo stopAccelerometerUpdates];
    [callback invoke:nil];
}

+ (void)WebViewExposed_isAccelerometerActive:(USRVWebViewCallback *)callback {
    [callback invoke:[NSNumber numberWithBool:[USRVSensorInfo isAccelerometerActive]], nil];
}

+ (void)WebViewExposed_getAccelerometerData:(USRVWebViewCallback *)callback {
    NSDictionary *accelerometerData = [USRVSensorInfo getAccelerometerData];
    if(accelerometerData != nil) {
        [callback invoke:accelerometerData, nil];
    } else {
        [callback error:NSStringFromSensorInfoError(kUnityServicesAccelerometerDataNotAvailable) arg1:nil];
    }
}

@end

