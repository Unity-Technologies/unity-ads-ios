#import <XCTest/XCTest.h>
#import "UADSHeaderBiddingTokenReaderWithSCARSignalsEagerStrategy.h"
#import "UADSHeaderBiddingTokenAsyncReaderMock.h"
#import "UADSSCARSignalReaderMock.h"
#import "UADSSCARSignalSenderMock.h"
#import "USRVBodyCompressorMock.h"
#import "UADSHeaderBiddingTokenReaderWithSCARSignalsBaseStrategy+Internal.h"
#import "XCTestCase+Convenience.h"
#import "UADSUniqueIdGeneratorMock.h"
#import "UADSJSONCompressorMock.h"
#import "XCTestCase+SCARHBStrategies.h"
#import "UADSDeviceReaderMock.h"
#import "USRVDataGzipCompressor.h"
#import "UADSConfigurationReaderMock.h"

@interface UADSHeaderBiddingTokenReaderWithSCARSignalsEagerStrategyTests : XCTestCase
@property (nonatomic, strong) UADSHeaderBiddingTokenReaderWithSCARSignalsEagerStrategy *strategyToTest;
@property (nonatomic, strong) UADSHeaderBiddingTokenReaderSCARSignalsConfig* configMock;
@property (nonatomic, strong) UADSHeaderBiddingTokenAsyncReaderMock* originalMock;
@property (nonatomic, strong) UADSSCARSignalReaderMock* signalReaderMock;
@property (nonatomic, strong) UADSSCARSignalSenderMock* signalSenderMock;
@property (nonatomic, strong) USRVBodyBase64GzipCompressor* compressor;
@property (nonatomic, strong) UADSUniqueIdGeneratorMock* idGeneratorMock;
@property (nonatomic, strong) UADSUniqueIdGeneratorMock* baseIdGeneratorMock;
@property (nonatomic, strong) UADSDeviceReaderMock *readerMock;
@property (strong, nonatomic) UADSConfigurationReaderMock *configurationReaderMock;
@end

@implementation UADSHeaderBiddingTokenReaderWithSCARSignalsEagerStrategyTests

- (void)setUp {
    _originalMock = [UADSHeaderBiddingTokenAsyncReaderMock new];
    
    _signalReaderMock = [UADSSCARSignalReaderMock new];
    _signalSenderMock = [UADSSCARSignalSenderMock new];
    _idGeneratorMock = [UADSUniqueIdGeneratorMock new];
    _baseIdGeneratorMock = [UADSUniqueIdGeneratorMock new];
    _configurationReaderMock = [UADSConfigurationReaderMock new];
    _configurationReaderMock.expectedStrategyType = UADSSCARHeaderBiddingStrategyTypeEager;
    
    _configMock = [UADSHeaderBiddingTokenReaderSCARSignalsConfig new];
    _configMock.compressor = _compressor;
    
    _readerMock  = [UADSDeviceReaderMock new];
    _readerMock.expectedInfo = @{ @"test" : @"test"};
    id<USRVDataCompressor> gzipCompressor = [USRVDataGzipCompressor new];


    _compressor = [USRVBodyBase64GzipCompressor newWithDataCompressor: gzipCompressor];
    UADSHeaderBiddingTokenReaderBase *base = [UADSHeaderBiddingTokenReaderBase newWithDeviceInfoReader: _readerMock
                                                                                         andCompressor: _compressor
                                                                                       withTokenPrefix: @""
                                                                                 withUniqueIdGenerator: _baseIdGeneratorMock
                                                                               withConfigurationReader: _configurationReaderMock];
    _originalMock.original = base;
    _strategyToTest = [UADSHeaderBiddingTokenReaderWithSCARSignalsEagerStrategy decorateOriginal:_originalMock config:_configMock];
    _strategyToTest.scarSignalReader = _signalReaderMock;
    _strategyToTest.scarSignalSender = _signalSenderMock;
    _strategyToTest.uniqueIdGenerator = _idGeneratorMock;
    _originalMock.expectedToken = @"tokenValue";
    _originalMock.shoudSkipCompletion = true;
    _idGeneratorMock.expectedValue = [NSUUID new].UUIDString;
    _baseIdGeneratorMock.expectedValue = [NSUUID new].UUIDString;
}

- (void)test_signals_recieved_and_signals_sent_before_token_returned {
    [self checkWithStrategy:_strategyToTest original:_originalMock stepAfterGetTokenTriggered:^ {
        [self.signalReaderMock triggerSignalCompletion];
        [self checkSenderCallHistoryCountIsOne:self.signalSenderMock withUUID:self.baseIdGeneratorMock.expectedValue];
    } getTokenReturn:^ (UADSHeaderBiddingToken *_Nullable token) {
        XCTAssertEqualObjects(token.uuidString, self.baseIdGeneratorMock.expectedValue, @"token uuid should have been overridden");
    }];
}


- (void)test_signals_received_and_signals_sent_after_token_recieved {
    [self checkWithStrategy:_strategyToTest original:_originalMock stepAfterGetTokenTriggered:^ { } getTokenReturn:^ (UADSHeaderBiddingToken *_Nullable token) {
        XCTAssertNotEqualObjects(token.uuidString, self.idGeneratorMock.expectedValue, @"token uuid should not have changed");
        [self.signalReaderMock triggerSignalCompletion];
        [self checkSenderCallHistoryCountIsOne:self.signalSenderMock withUUID:token.uuidString];
    }];
}

- (void)test_signals_sent_as_soon_as_received_remote_token {
    
    _originalMock.tokenType = kUADSTokenRemote;
    [self checkWithStrategy:_strategyToTest original:_originalMock stepAfterGetTokenTriggered:^ {
        [self.signalReaderMock triggerSignalCompletion];
        [self checkSenderCallHistoryCountIsOne:self.signalSenderMock withUUID:self.idGeneratorMock.expectedValue];
    } getTokenReturn:^ (UADSHeaderBiddingToken *_Nullable token) {
        [self hasValueSamePrefix:token.value withUUID:self.idGeneratorMock.expectedValue];
    }];
}

- (void)test_signals_recieved_and_signals_sent_before_remote_token_returned {
    
    _originalMock.tokenType = kUADSTokenRemote;
    [self checkWithStrategy:_strategyToTest original:_originalMock stepAfterGetTokenTriggered:^ { } getTokenReturn:^ (UADSHeaderBiddingToken *_Nullable token) {
        [self hasValueSamePrefix:token.value withUUID:token.uuidString];
        [self.signalReaderMock triggerSignalCompletion];
        [self checkSenderCallHistoryCountIsOne:self.signalSenderMock withUUID:token.uuidString];
    }];
}

- (void)test_nil_signals_recieved_and_signals_sent_before_token_returned {
    
    _signalReaderMock.signals = nil;
    [self checkWithStrategy:_strategyToTest original:_originalMock stepAfterGetTokenTriggered:^ {
        [self.signalReaderMock triggerSignalCompletion];
        [self checkSenderCallHistoryCountIsOne:self.signalSenderMock withUUID:self.baseIdGeneratorMock.expectedValue];
        XCTAssertEqualObjects(self.signalSenderMock.callHistory[0].signals, nil, @"signals are set to nil");
    } getTokenReturn:^ (UADSHeaderBiddingToken *_Nullable token) {
        XCTAssertNotEqualObjects(token.uuidString, self.idGeneratorMock.expectedValue, @"token uuid should not have been overridden, the signals are not valid");
    }];
}

- (void)test_signals_recieved_and_signals_sent_before_nil_token_returned {
    
    _originalMock.expectedToken = nil;
    [self checkWithStrategy:_strategyToTest original:_originalMock stepAfterGetTokenTriggered:^ {
        [self.signalReaderMock triggerSignalCompletion];
        [self checkSenderCallHistoryCountIsOne:self.signalSenderMock withUUID:self.baseIdGeneratorMock.expectedValue];
    } getTokenReturn:^ (UADSHeaderBiddingToken *_Nullable token) {
        XCTAssertNotEqualObjects(token.uuidString, self.idGeneratorMock.expectedValue, @"token uuid should not have been overridden, the signals are not valid");
    }];
}

- (void)test_x_signals_recieved_and_signals_sent_before_x_token_returned {
    int iterations = 500;
    self.signalReaderMock.shouldAutoComplete = true;
    self.originalMock.shoudSkipCompletion = false;
    self.idGeneratorMock.expectedValue = @"uuid";
    [self asyncExecuteTimes:iterations block:^(XCTestExpectation *_Nonnull expectation, int index) {
        [self.strategyToTest getToken:^(UADSHeaderBiddingToken *_Nullable token) {
            [expectation fulfill];
        }];
    }];
    XCTAssertTrue(self.signalSenderMock.callHistory.count == iterations, @"Signals should have the same count as the iterations");
}

- (void)test_signals_recieved_and_signals_sent_before_token_returned_with_mock_compressor {
    NSString* expectedValue = [self expectedValue];
    
    NSMutableDictionary* info = [NSMutableDictionary new];
    _originalMock.info = info;
    [self checkWithStrategy:_strategyToTest original:_originalMock stepAfterGetTokenTriggered:^ {
        [self.signalReaderMock triggerSignalCompletion];
        [self checkSenderCallHistoryCountIsOne:self.signalSenderMock withUUID:self.baseIdGeneratorMock.expectedValue];
    } getTokenReturn:^ (UADSHeaderBiddingToken *_Nullable token) {
        XCTAssertEqualObjects(token.uuidString, self.baseIdGeneratorMock.expectedValue, @"token uuid should have been overridden");
        NSString* tokenValues = token.value;
        XCTAssertEqualObjects(tokenValues, expectedValue);
    }];
}

-(NSString*) expectedValue {
    NSMutableDictionary *expectedDictionary = [NSMutableDictionary dictionaryWithDictionary:_readerMock.expectedInfo];
    [expectedDictionary setObject:_baseIdGeneratorMock.expectedValue forKey:@"tid"];
    NSString* expectedValue = [_compressor compressedIntoString:expectedDictionary];
    return expectedValue;
}

@end
