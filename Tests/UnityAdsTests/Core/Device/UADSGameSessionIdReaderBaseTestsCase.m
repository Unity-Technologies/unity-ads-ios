#import <XCTest/XCTest.h>
#import "UADSGameSessionIdReader.h"
#import "USRVStorageManager.h"
#import "UADSJsonStorageKeyNames.h"
#import "XCTestCase+Convenience.h"
#import "UADSServiceProviderContainer.h"

@interface UADSGameSessionIdReaderBaseTestsCase : XCTestCase

@end

@implementation UADSGameSessionIdReaderBaseTestsCase

- (void)setUp {
    [self.privateStorage deleteKey: UADSJsonStorageKeyNames.webViewDataGameSessionIdKey];
    UADSServiceProviderContainer.sharedInstance.serviceProvider = [UADSServiceProvider new];
}

- (void)tearDown {
    [self.privateStorage deleteKey: UADSJsonStorageKeyNames.webViewDataGameSessionIdKey];
}

- (void)test_game_session_id_is_generated_once_and_saved_to_storage {
    UADSGameSessionIdReaderBase *sut = [UADSGameSessionIdReaderBase new];
    XCTAssertNil([self.privateStorage getValueForKey: UADSJsonStorageKeyNames.webViewDataGameSessionIdKey]);
    
    NSNumber *gameSessionId = [sut gameSessionId];
    NSNumber *savedGameSessionId = [self.privateStorage getValueForKey: UADSJsonStorageKeyNames.webViewDataGameSessionIdKey];
    XCTAssertEqualObjects(savedGameSessionId, gameSessionId, "GameSessionId should be saved to storage");
    XCTAssertEqual(gameSessionId, [sut gameSessionId], "Should not generate a new value");
}

- (void)test_multithread_generate_call {
    UADSGameSessionIdReaderBase *sut = [UADSGameSessionIdReaderBase new];
    __block NSMutableSet *generatedIds = [NSMutableSet set];
    
    [self asyncExecuteTimes:1000 block:^(XCTestExpectation * _Nonnull expectation, int index) {
        NSNumber *gameSessionId = [sut gameSessionId];
        @synchronized (generatedIds) {
            [generatedIds addObject:gameSessionId];
        }
        [expectation fulfill];
    }];
    
    XCTAssertEqual(generatedIds.count, 1);
}

- (USRVStorage *)privateStorage {
    return [USRVStorageManager getStorage: kUnityServicesStorageTypePrivate];
}


@end
