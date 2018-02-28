#import "UADSSensorInfoError.h"

static NSString *accelerometerDataNotAvailable = @"ACCELEROMETER_DATA_NOT_AVAILABLE";


NSString *NSStringFromSensorInfoError(UnityAdsSensorInfoError error) {
    switch (error) {
        case kUnityAdsAccelerometerDataNotAvailable:
            return accelerometerDataNotAvailable;
    }
}

