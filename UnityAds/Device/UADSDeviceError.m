#import "UADSDeviceError.h"

static NSString *couldntGetSensorInfo = @"COULDNT_GET_SENSOR_INFO";
static NSString *couldntGetProcessInfo = @"COULDNT_GET_PROCESS_INFO";


NSString *NSStringFromDeviceError(UnityAdsDeviceError error) {
    switch (error) {
        case kUnityAdsCouldntGetSensorInfo:
            return couldntGetSensorInfo;
        case kUnityAdsCouldntGetProcessInfo:
            return couldntGetProcessInfo;
    }
}
