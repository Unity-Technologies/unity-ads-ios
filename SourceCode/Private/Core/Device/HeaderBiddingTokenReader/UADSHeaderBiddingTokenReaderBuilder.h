#import <Foundation/Foundation.h>
#import "UADSHeaderBiddingTokenReaderBridge.h"
#import "UADSInitializationStatusReader.h"
#import "UADSTokenStorage.h"
#import "UADSPrivacyStorage.h"
#import "UADSGameSessionIdReader.h"
NS_ASSUME_NONNULL_BEGIN

@interface UADSHeaderBiddingTokenReaderBuilder : NSObject
@property (nonatomic, strong) id<USRVStringCompressor>bodyCompressor;
@property (nonatomic, strong) id<ISDKMetrics>metricsSender;
@property (nonatomic, strong) id<UADSInitializationStatusReader>sdkInitializationStatusReader;
@property (nonatomic, strong) id<UADSConfigurationReader, UADSConfigurationMetricTagsReader>sdkConfigReader;
@property (nonatomic, strong) id<UADSDeviceInfoReader>deviceInfoReader;
@property (nonatomic, strong) id<UADSHeaderBiddingTokenCRUD>tokenCRUD;
@property (nonatomic, strong) id<UADSHeaderBiddingAsyncTokenReader>tokenGenerator;
@property (nonatomic, strong) NSString *nativeTokenPrefix;
@property (nonatomic, strong) id<UADSPrivacyResponseSaver, UADSPrivacyResponseReader, UADSPrivacyResponseSubject> privacyStorage;
@property (nonatomic, strong) id<UADSGameSessionIdReader> gameSessionIdReader;

- (id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD>)defaultReader;

@end
NS_ASSUME_NONNULL_END
