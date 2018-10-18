#import <CoreMotion/CoreMotion.h>

@interface USRVSensorInfo : NSObject

+ (BOOL)startAccelerometerUpdates:(double)updateInterval;

+ (void)stopAccelerometerUpdates;

+ (BOOL)isAccelerometerActive;

+ (NSDictionary *)getAccelerometerData;

@end


