#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ISDKMetrics;

@protocol UADSDeviceIDFIReader <NSObject>

- (NSString *)idfi;

@end

@protocol UADSAnalyticValuesReader <NSObject>

- (NSString *)sessionID;
- (NSString *)userID;

@end

@protocol UADSInitializationTimeStampReader <NSObject>

- (NSNumber *)initializationStartTimeStamp;

@end



@interface UADSDeviceIDFIReaderBase : NSObject<UADSDeviceIDFIReader, UADSAnalyticValuesReader, UADSInitializationTimeStampReader>

@end

NS_ASSUME_NONNULL_END
