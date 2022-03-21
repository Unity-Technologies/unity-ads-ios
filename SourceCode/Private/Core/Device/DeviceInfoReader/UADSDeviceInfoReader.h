#import <Foundation/Foundation.h>
#import "UADSDeviceIDFIReader.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM (NSInteger, UADSGameMode) {
    UADSGameModeKids,
    UADSGameModeMix,
    UADSGameModeAdults
};

@protocol UADSDeviceInfoReader <NSObject>

- (NSDictionary *)getDeviceInfoForGameMode: (UADSGameMode)mode;

@end

@interface UADSDeviceInfoReaderBase : NSObject<UADSDeviceInfoReader>
+ (id<UADSDeviceInfoReader>)newWithIDFIReader: (id<UADSDeviceIDFIReader, UADSAnalyticValuesReader, UADSInitializationTimeStampReader>)userDefaultsReader;
@end

NS_ASSUME_NONNULL_END
