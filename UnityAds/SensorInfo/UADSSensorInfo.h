#import <CoreMotion/CoreMotion.h>

@interface UADSSensorInfo : NSObject

+ (BOOL)startAccelerometerUpdates:(double)updateInterval;

+ (void)stopAccelerometerUpdates;

+ (BOOL)isAccelerometerActive;

+ (NSDictionary *)getAccelerometerData;

@end


