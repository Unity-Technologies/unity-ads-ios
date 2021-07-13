#import "GMAAdLoaderStrategy + SyncCategory.h"
#import "GMAIntegrationTestsConstants.h"

@implementation GMAAdLoaderStrategy (SyncCategory)

- (void)loadSyncWithTestCase: (XCTestCase *)testCase
                 andMetaData: (GMAAdMetaData *)meta
               andCompletion: (void (^)(id _Nullable obj))completion
             errorCompletion: (void (^)(GMAError *))errorCompletion {
    XCTestExpectation *exp = [testCase expectationWithDescription: @"LoadAdsExpectation"];

    id successHandler = ^(id _Nullable obj) {
        completion(obj);
        [exp fulfill];
    };

    id errorHandler = ^(id<UADSError> _Nonnull error) {
        errorCompletion((GMAError *)error);
        [exp fulfill];
    };

    UADSAnyCompletion *anyCompletion = [UADSAnyCompletion newWithSuccess: successHandler
                                                                andError: errorHandler];

    [self loadAdUsingMetaData: meta
                andCompletion: anyCompletion];

    [testCase waitForExpectations: @[exp]
                          timeout: DEFAULT_WAITING_INTERVAL];
}

- (void)loadSuccessSyncWithTestCase: (XCTestCase *)testCase
                        andMetaData: (GMAAdMetaData *)meta
               andSuccessCompletion: (void (^)(id _Nullable))completion {
    [self loadSyncWithTestCase: testCase
                   andMetaData: meta
                 andCompletion: completion
               errorCompletion: self.errorHandlerFail];
}

- (void)loadErrorSyncWithTestCase: (XCTestCase *)testCase
                      andMetaData: (GMAAdMetaData *)meta
               andErrorCompletion: (void (^)(GMAError *))errorCompletion  {
    [self loadSyncWithTestCase: testCase
                   andMetaData: meta
                 andCompletion: self.successFail
               errorCompletion: errorCompletion];
}

- (id)errorHandlerFail {
    return ^(id<UADSError> _Nonnull error) {
               XCTFail("Doesnt expect to have an error here %@", error.errorString);
    };
}

- (id)successFail {
    return ^(id _Nonnull obj) {
               XCTFail("Doesnt expect to have success here");
    };
}

@end
