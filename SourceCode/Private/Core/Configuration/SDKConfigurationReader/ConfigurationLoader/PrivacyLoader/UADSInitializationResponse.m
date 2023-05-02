#import "UADSInitializationResponse.h"



@interface UADSInitializationResponse ()
@property (nonatomic, strong) NSDictionary *originalJSON;
@end

@implementation UADSInitializationResponse

+ (instancetype)newFromDictionary: (NSDictionary *)dictionary {
    UADSInitializationResponse *response = [UADSInitializationResponse new];

    response.webViewHash = dictionary[@"hash"];
    response.webViewUrl = dictionary[@"url"];
    response.webViewVersion = dictionary[@"version"];
    response.delayWebViewUpdate = [dictionary[@"dwu"] boolValue] ? : NO;
    response.resetWebAppTimeout = [dictionary[@"rwt"] intValue] ? : 10000;
    response.maxRetries = [dictionary[@"mr"] intValue] ? : 6;
    response.retryDelay = [dictionary[@"rd"] longValue] ? : 5000L;
    response.retryScalingFactor = [dictionary[@"rcf"] doubleValue] ? : 2.0;
    response.connectedEventThresholdInMs = [dictionary[@"cet"] intValue] ? : 10000;
    response.maximumConnectedEvents = [dictionary[@"mce"] intValue] ? : 500;
    response.networkErrorTimeout = [dictionary[@"net"] longValue] ? : 60000L;
    response.metricsUrl = dictionary[@"murl"] ? : nil;
    response.metricSamplingRate = [dictionary[@"msr"] doubleValue] ? : 100;
    response.showTimeout = [dictionary[@"sto"] intValue] ? : 10000;
    response.loadTimeout = [dictionary[@"lto"] intValue] ? : 30000;
    response.webViewTimeout = [dictionary[@"wto"] intValue] ? : 5000;
    response.webViewAppCreateTimeout = [dictionary[@"wct"] longValue] ? : 60000L;
    response.sdkVersion = dictionary[@"sdkv"] ? : nil;
    response.headerBiddingToken = dictionary[@"tkn"];
    response.stateId = dictionary[@"sid"];
    response.source = dictionary[@"src"];
    NSDictionary *experimentsDictionary = dictionary[@"expo"] ? : (dictionary[@"exp"] ? : @{});

    response.hbTokenTimeout = [dictionary[@"tto"] longLongValue] ? : 5000; //tto
    response.privacyWaitTimeout = [dictionary[@"prwto"] longLongValue] ? : 3000; //prwto
    response.experiments = [UADSConfigurationExperiments newWithJSON: experimentsDictionary];
    response.originalJSON = dictionary;

    response.allowTracking = [dictionary[@"pas"] boolValue] ? : false;
    response.shouldSendNonBehavioural = [dictionary[@"snb"] boolValue] ?: false;
    return response;
}

- (BOOL)allowTracking {
    return _allowTracking && _responseCode == 200;
}

@end
