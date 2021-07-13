#import "USRVSensorInfoError.h"

static NSString *accelerometerDataNotAvailable = @"ACCELEROMETER_DATA_NOT_AVAILABLE";


NSString * USRVNSStringFromSensorInfoError(UnityServicesSensorInfoError error) {
    switch (error) {
        case kUnityServicesAccelerometerDataNotAvailable:
            return accelerometerDataNotAvailable;
    }
}
