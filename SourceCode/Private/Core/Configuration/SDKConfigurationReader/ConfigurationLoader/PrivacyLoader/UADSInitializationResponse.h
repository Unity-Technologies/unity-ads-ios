#import <Foundation/Foundation.h>
#import "UADSConfigurationExperiments.h"
NS_ASSUME_NONNULL_BEGIN

@interface UADSInitializationResponse : NSObject
@property (nonatomic, strong) NSString *webViewUrl;
@property (nonatomic, strong) NSString *webViewHash;
@property (nonatomic, strong) NSString *webViewData;
@property (nonatomic, strong) NSString *webViewVersion;
@property (nonatomic, assign) BOOL delayWebViewUpdate;
@property (nonatomic, assign) int resetWebAppTimeout;
@property (nonatomic, assign) int maxRetries;
@property (nonatomic, assign) long retryDelay;
@property (nonatomic, assign) double retryScalingFactor;
@property (nonatomic, assign) int connectedEventThresholdInMs;
@property (nonatomic, assign) int maximumConnectedEvents;
@property (nonatomic, assign) long networkErrorTimeout;
@property (nonatomic, assign) int showTimeout;
@property (nonatomic, assign) int loadTimeout;
@property (nonatomic, assign) int webViewTimeout;
@property (nonatomic, strong) NSString *metricsUrl;
@property (nonatomic, assign) double metricSamplingRate;
@property (nonatomic, assign) long webViewAppCreateTimeout;
@property (nonatomic, strong) NSString *sdkVersion;
@property (nonatomic, strong) NSString *configUrl;
@property (nonatomic, strong) NSString *error;
@property (nonatomic, strong) NSError *requestError;
@property (nonatomic, strong) NSString *headerBiddingToken;
@property (nonatomic, strong) NSString *stateId;
@property (nonatomic, strong) UADSConfigurationExperiments *experiments;
@property (nonatomic, strong) NSString *source;
@property (nonatomic, assign) long hbTokenTimeout;
@property (nonatomic, assign) long privacyWaitTimeout;
@property (nonatomic, strong, readonly) NSDictionary *originalJSON;
@property (nonatomic, assign) long responseCode;
@property (nonatomic, assign) BOOL allowTracking;

+ (instancetype)newFromDictionary: (NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
