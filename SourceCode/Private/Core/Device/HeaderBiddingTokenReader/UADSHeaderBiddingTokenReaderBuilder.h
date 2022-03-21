#import <Foundation/Foundation.h>
#import "UADSHeaderBiddingTokenReaderBridge.h"
#import "UADSInitializationStatusReader.h"
#import "UADSTokenStorage.h"
NS_ASSUME_NONNULL_BEGIN

@interface UADSHeaderBiddingTokenReaderBuilder : NSObject
@property (nonatomic, strong) id<USRVStringCompressor>bodyCompressor;
@property (nonatomic, strong) id<ISDKMetrics>metricsSender;
@property (nonatomic, strong) id<UADSInitializationStatusReader>sdkInitializationStatusReader;
@property (nonatomic, strong) id<UADSConfigurationReader, UADSConfigurationMetricTagsReader>sdkConfigReader;
@property (nonatomic, strong) id<UADSDeviceInfoReader>deviceInfoReader;
@property (nonatomic, strong) id<UADSHeaderBiddingTokenCRUD>tokenCRUD;
@property (nonatomic, strong) id<UADSHeaderBiddingAsyncTokenReader>tokenGenerator;


- (id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD>)defaultReader;


+ (instancetype)                                                     sharedInstance;
@end
NS_ASSUME_NONNULL_END
