#import <XCTest/XCTest.h>
#import "UADSHeaderBiddingTokenReaderSCARSignalsConfig.h"
#import "UADSSCARHeaderBiddingFetchSendStrategyFactory.h"
#import "UADSConfigurationReaderMock.h"
#import "UADSHeaderBiddingTokenReaderWithSCARSignalsEagerStrategy.h"
#import "UADSHeaderBiddingTokenReaderWithSCARSignalsHybridStrategy.h"
#import "UADSHeaderBiddingTokenReaderWithSCARSignalsLazyStrategy.h"
#import "USRVSdkProperties.h"

@interface UADSSCARHeaderBiddingFetchSendStrategyFactoryTests : XCTestCase
@property (nonatomic, strong) UADSHeaderBiddingTokenReaderSCARSignalsConfig* configMock;
@property (nonatomic, strong) UADSSCARHeaderBiddingFetchSendStrategyFactory* strategyFactory;
@property (nonatomic, strong) UADSConfigurationCRUDBase* configurationReader;

@end

@implementation UADSSCARHeaderBiddingFetchSendStrategyFactoryTests

- (void)setUp {
    _configMock = [UADSHeaderBiddingTokenReaderSCARSignalsConfig new];
    _configurationReader = [UADSConfigurationCRUDBase new];
    _strategyFactory = [UADSSCARHeaderBiddingFetchSendStrategyFactory new];
    
    _configMock.configurationReader = _configurationReader;
    _configMock.strategyFactory = _strategyFactory;
    _strategyFactory.config = _configMock;
}

- (void)test_eager_set_in_experiments {
    [self saveLocalConfigWithObject:false experiments:[self eagerExperimentWithObject]];
    id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD> strategy = [_strategyFactory strategyWithOriginal:nil];
    XCTAssertEqual([strategy class], [UADSHeaderBiddingTokenReaderWithSCARSignalsEagerStrategy class], @"Eager set, should return eager implementation");
}

- (void)test_lazy_set_in_experiments {
    [self saveLocalConfigWithObject:false experiments:[self lazyExperimentWithObject]];
    id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD> strategy = [_strategyFactory strategyWithOriginal:nil];
    XCTAssertEqual([strategy class], [UADSHeaderBiddingTokenReaderWithSCARSignalsLazyStrategy class], @"Lazy set, should return eager implementation");
}

- (void)test_hybrid_set_in_experiments {
    [self saveLocalConfigWithObject:false experiments:[self hybridExperimentWithObject]];
    id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD> strategy = [_strategyFactory strategyWithOriginal:nil];
    XCTAssertEqual([strategy class], [UADSHeaderBiddingTokenReaderWithSCARSignalsHybridStrategy class], @"Hybrid set, should return eager implementation");
}

- (void)test_empty_set_in_experiments {
    [self saveLocalConfigWithObject:false experiments:[self emptyExperimentWithObject]];
    id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD> strategy = [_strategyFactory strategyWithOriginal:nil];
    XCTAssertEqual([strategy class], nil, @"no experiment set, should return no implementation");
}

- (void)test_no_experiment_set_in_experiments {
    [self saveLocalConfigWithObject:false experiments:[self noExperimentWithObject]];
    id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD> strategy = [_strategyFactory strategyWithOriginal:nil];
    XCTAssertEqual([strategy class], nil, @"no experiment set, should return no implementation");
}

- (void)test_nil_experiment_set_in_experiments {
    [self saveLocalConfigWithObject:false experiments:[self noExperimentWithNilObject]];
    id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD> strategy = [_strategyFactory strategyWithOriginal:nil];
    XCTAssertEqual([strategy class], nil, @"no experiment set, should return no implementation");
}

- (void)saveLocalConfigWithObject: (BOOL)withObject experiments:(NSDictionary *)localExperiments {
    USRVConfiguration *localConfiguration = [self mockConfigWithUrl: self.localWebViewUrl
                                                        experiments: localExperiments
                                                   experimentObject: withObject];

    [[localConfiguration toJson] writeToFile: [USRVSdkProperties getLocalConfigFilepath]
                                  atomically: YES];
}

- (USRVConfiguration *)mockConfigWithUrl: (NSString *)url experiments: (NSDictionary *)experiments experimentObject: (BOOL)isObject {
    NSString *experimentsKey = isObject ? kUnityServicesConfigValueExperimentsObject : kUnityServicesConfigValueExperiments;
    USRVConfiguration *configuration = [USRVConfiguration newFromJSON: @{
                                            kUnityServicesConfigValueUrl:  url,
                                            experimentsKey: experiments ?: @{},
                                            kUnityServicesConfigValueSource: self.source
    }];

    return configuration;
}

- (NSDictionary *)eagerExperimentWithObject {
    return @{
        @"scar_bm": @{
            @"value": @"eag"
        }
    };
}

- (NSDictionary *)lazyExperimentWithObject {
    return @{
        @"scar_bm": @{
            @"value": @"laz"
        }
    };
}

- (NSDictionary *)hybridExperimentWithObject {
    return @{
        @"scar_bm": @{
            @"value": @"hyb"
        }
    };
}

- (NSDictionary *)emptyExperimentWithObject {
    return @{
        @"scar_bm": @{
        }
    };
}

- (NSDictionary *)noExperimentWithObject {
    return @{
    };
}

- (NSDictionary *)noExperimentWithNilObject {
    return nil;
}

- (NSString *)localWebViewUrl {
    return @"local-fake-url";
}

- (NSString *)source {
    return @"srvc";
}

@end
