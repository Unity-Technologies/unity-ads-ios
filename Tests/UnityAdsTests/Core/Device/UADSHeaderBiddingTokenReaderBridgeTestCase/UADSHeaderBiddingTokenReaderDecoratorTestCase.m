#import <XCTest/XCTest.h>
#import "XCTestCase+Convenience.h"
#import "UADSHeaderBiddingTokenAsyncReaderMock.h"
#import "UADSHeaderBiddingTokenReaderWithSerialQueue.h"
#import "UADSInitializationStatusReaderMock.h"

@interface UADSHeaderBiddingTokenReaderDecoratorTestCase : XCTestCase
@property (nonatomic, strong) UADSHeaderBiddingTokenAsyncReaderMock *readerMock;
@property (nonatomic, strong) UADSInitializationStatusReaderMock *statusReaderMock;

@end

@implementation UADSHeaderBiddingTokenReaderDecoratorTestCase

- (void)setUp {
    self.readerMock = [UADSHeaderBiddingTokenAsyncReaderMock new];
    self.statusReaderMock = [UADSInitializationStatusReaderMock new];
}

- (id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD>)sut {
    return [UADSHeaderBiddingTokenReaderWithSerialQueue newWithOriginalReader: _readerMock
                                                              andStatusReader: _statusReaderMock];
}

- (void)test_if_status_is_not_initialized_should_return_null_token {
    _statusReaderMock.currentState = NOT_INITIALIZED;
    [self.sut getToken:^(UADSHeaderBiddingToken *_Nullable token) {
        XCTAssertNotNil(token);
        XCTAssertFalse(token.isValid);
        XCTAssertEqual(self.readerMock.getTokenCount, 0);
    }];

    [self waitForTimeInterval: 0.1];
}

- (void)test_if_status_is_failed_should_return_null_token {
    _statusReaderMock.currentState = INITIALIZED_FAILED;
    [self.sut getToken:^(UADSHeaderBiddingToken *_Nullable token) {
        XCTAssertNotNil(token);
        XCTAssertFalse(token.isValid);
        XCTAssertEqual(self.readerMock.getTokenCount, 0);
    }];

    [self waitForTimeInterval: 0.1];
}

- (void)test_passes_calls_to_original {
    id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD> sut = self.sut;

    _statusReaderMock.currentState = INITIALIZED_SUCCESSFULLY;
    [sut setPeekMode: YES];
    [sut getToken];
    [sut deleteTokens];
    [sut createTokens: @[]];
    [sut appendTokens: @[]];
    [self.sut getToken:^(UADSHeaderBiddingToken *_Nullable token) {
    }];

    [self waitForTimeInterval: 0.5];
    XCTAssertEqual(_readerMock.setPeekModeCount, 1);
    XCTAssertEqual(_readerMock.getTokenCount, 1);
    XCTAssertEqual(_readerMock.getTokenSyncCount, 1);
    XCTAssertEqual(_readerMock.deleteTokenCount, 1);
    XCTAssertEqual(_readerMock.appendTokenCount, 1);
    XCTAssertEqual(_readerMock.createTokenCount, 1);
}

@end
