
#import "USRVSensorInfo.h"

@implementation USRVSensorInfo

static CMMotionManager *motionManager;

+ (BOOL)startAccelerometerUpdates:(double)updateInterval {
    if (!motionManager) {
       motionManager = [[CMMotionManager alloc] init];
    }
    
    if ([motionManager isAccelerometerAvailable]) {
        motionManager.accelerometerUpdateInterval = updateInterval;
        [motionManager startAccelerometerUpdates];
        return YES;
    } else {
        return NO;
    }
}

+ (void)stopAccelerometerUpdates {
    if (motionManager) {
        [motionManager stopAccelerometerUpdates];
    }
}

+ (BOOL)isAccelerometerActive {
    if (motionManager && [motionManager isAccelerometerActive]) {
        return YES;
    } else {
        return NO;
    }
}

+ (NSDictionary *)getAccelerometerData {
    if (motionManager && [motionManager isAccelerometerActive] && motionManager.accelerometerData) {
        double x = motionManager.accelerometerData.acceleration.x;
        double y = motionManager.accelerometerData.acceleration.y;
        double z = motionManager.accelerometerData.acceleration.z;

        NSDictionary *accelerometerDataDictionary = @{@"x" : [NSNumber numberWithDouble:x],
                                               @"y" : [NSNumber numberWithDouble:y],
                                               @"z" : [NSNumber numberWithDouble:z]};
        return accelerometerDataDictionary;
    }
    return nil;
}

@end
