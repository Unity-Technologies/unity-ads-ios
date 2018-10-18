#import "USRVDeviceError.h"

static NSString *couldntGetSensorInfo = @"COULDNT_GET_SENSOR_INFO";
static NSString *couldntGetProcessInfo = @"COULDNT_GET_PROCESS_INFO";


NSString *NSStringFromDeviceError(UnityServicesDeviceError error) {
    switch (error) {
        case kUnityServicesCouldntGetSensorInfo:
            return couldntGetSensorInfo;
        case kUnityServicesCouldntGetProcessInfo:
            return couldntGetProcessInfo;
    }
}
