#import "UADSDeviceError.h"

static NSString *couldntGetSensorInfo = @"COULDNT_GET_SENSOR_INFO";


NSString *NSStringFromDeviceError(UnityAdsDeviceError error) {
    switch (error) {
        case kUnityAdsCouldntGetSensorInfo:
            return couldntGetSensorInfo;
    }
}
