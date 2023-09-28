#import <Foundation/Foundation.h>
#import "UADSHeaderBiddingTokenReaderBridge.h"
#import "UADSGMAScar.h"
#import "USRVWebRequestFactory.h"
#import "UADSConfigurationCRUDBase.h"
#import "USRVSDKMetrics.h"
#import "UADSCurrentTimestampBase.h"
@protocol UADSSCARHeaderBiddingStrategyFactory;

NS_ASSUME_NONNULL_BEGIN

@interface UADSHeaderBiddingTokenReaderSCARSignalsConfig : NSObject

@property (nonatomic, strong) id<IUSRVWebRequestFactory> requestFactory;
@property (nonatomic, strong) id<GMASCARSignalService> signalService;
@property (nonatomic, weak) id<USRVStringCompressor> compressor;
@property (nonatomic, strong) id<UADSDeviceIDFIReader> idfiReader;
@property (nonatomic, strong) id<UADSConfigurationReader> configurationReader;
@property (nonatomic, strong) id<ISDKMetrics> metricsSender;
@property (nonatomic, strong) id<UADSCurrentTimestamp> timestampReader;

@end

NS_ASSUME_NONNULL_END
