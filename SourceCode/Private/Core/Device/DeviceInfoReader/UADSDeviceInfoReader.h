#import <Foundation/Foundation.h>
#import "UADSDeviceIDFIReader.h"
#import "UADSLogger.h"
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM (NSInteger, UADSGameMode) {
    UADSGameModeKids,
    UADSGameModeMix,
    UADSGameModeAdults
};

@protocol UADSDeviceInfoReader <NSObject>

- (NSDictionary *)getDeviceInfoForGameMode: (UADSGameMode)mode;

@end

@interface UADSDeviceInfoReaderExtended : NSObject<UADSDeviceInfoReader>
+ (id<UADSDeviceInfoReader>)newWithIDFIReader: (id<UADSAnalyticValuesReader, UADSInitializationTimeStampReader>)idfiReader
                                  andOriginal: (id<UADSDeviceInfoReader>)orignal
                                    andLogger: (id<UADSLogger>)logger;

@end

NS_ASSUME_NONNULL_END
